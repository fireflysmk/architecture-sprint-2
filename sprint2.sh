#!/usr/bin/env bash

TOP=`dirname $0`
TASK_DIRS=(mongo-single mongo-sharding mongo-sharding-repl sharding-repl-cache sharding-repl-cache-apisix sharding-repl-cache-cdn)
TASK=""
MODE=""
BENCHMARK=0
COUNT=0
LIST_CONTAINERS=0
INIT_COLLECTION=""
AB=`which ab`
TEST_TIME=20
TEST_CONC=25
DB_NAME=somedb
COLLECTION_NAME=helloDoc

CONFIG_NAME=config_server
CONFIG_SRV=configSrv
ROUTER_SRV=mongos_router
SHARD1_SRV=shard1
SHARD2_SRV=shard2

# Could use yq, but there is guarantee that everyone has it
ROUTER_PORT=27017
SHARD1_PORT=27018
SHARD2_PORT=27019
CONFIG_PORT=27020

TOP_URL="http://localhost:8080"


usage() {
    echo "Usage:"
    echo "  $0 -t <task_num> [-m <mode>] [-h] [-b] [-c] [-i] [-l] [-r num_doc]"
    echo "Where"
    echo "  -t task_num       -            task number from this sprint (1..6)"
    echo "  -m mode           - (optional) containers' mode (one of 'up' or 'down')"
    echo "  -b                - (optional) conduct benchmarks"
    echo "  -c                - (optional) count number of documents in DB"
    echo "  -i                - (optional) init DB configuration"
    echo "  -l                - (optional) list container names"
    echo "  -r num_doc        - (optional) recreate collection with num_doc documents"

    echo "  -h                - (optional) this help"
}

error() {
    echo $1
    exit 2
}

start_containers() {
    echo "Staring containers..."
    cd $TASK_DIR
    docker compose up -d
    cd - > /dev/null
}

stop_containers() {
    echo "Stopping containers..."
    cd $TASK_DIR
    docker compose down
    cd - > /dev/null
}

list_containers() {
    echo "This compose.yaml defines following containers:"
    grep "container_name" ${TASK_DIR}/compose.yaml | awk -F: '{print $2}'
}

init_db_config() {
    echo "Init DB config..."
    docker ps
    cd $TASK_DIR
    docker compose exec -T $CONFIG_SRV mongosh --port $CONFIG_PORT --quiet <<- EOF
        rs.initiate(
            {
                _id : "$CONFIG_NAME",
                configsvr: true,
                members: [
                    { _id : 0, host : "$CONFIG_SRV:$CONFIG_PORT" }
                ]
            }
        );
EOF
    echo "Give few seconds to $CONFIG_SRV to digest the change in its config..."
    sleep 10
    docker compose exec -T $SHARD1_SRV mongosh --port $SHARD1_PORT --quiet <<- EOF
        rs.initiate(
            {
                _id : "$SHARD1_SRV",
                members: [
                    { _id : 0, host : "$SHARD1_SRV:$SHARD1_PORT" },
                    // { _id : 1, host : "$SHARD2_SRV:$SHARD2_PORT" }
                ]
            }
        );
        use $DB_NAME;
        db.dropDatabase()
EOF
    docker compose exec -T $SHARD2_SRV mongosh --port $SHARD2_PORT --quiet <<- EOF
        rs.initiate(
            {
                _id : "$SHARD2_SRV",
                members: [
                    //{ _id : 0, host : "$SHARD1_SRV:$SHARD1_PORT" },
                    { _id : 1, host : "$SHARD2_SRV:$SHARD2_PORT" }
                ]
            }
        );
        use $DB_NAME;
        db.dropDatabase()
EOF
    docker compose exec -T $ROUTER_SRV mongosh --port $ROUTER_PORT <<- EOF
        sh.addShard( "$SHARD1_SRV/$SHARD1_SRV:$SHARD1_PORT");
        sh.addShard( "$SHARD2_SRV/$SHARD2_SRV:$SHARD2_PORT");

        sh.enableSharding("$DB_NAME");
        sh.shardCollection("$DB_NAME.$COLLECTION_NAME", { "name" : "hashed" } )
EOF
    cd - > /dev/null
    echo "Server configuration is complete!"
    docker ps
}

init_collection() {
    echo "Initialize DB with ${INIT_COLLECTION} documents..."
    cd $TASK_DIR
    [ "$TASK" == "1" ] && ROUTER_SRV=mongodb1

    OUTPUT=`docker compose exec -T $ROUTER_SRV mongosh --port 27017 --quiet <<- EOF
        use $DB_NAME
        db.$COLLECTION_NAME.drop()
EOF`

    if [ "$TASK" != 1 ]; then
        OUTPUT=`docker compose exec -T $ROUTER_SRV mongosh --port 27017 --quiet <<- EOF
            sh.enableSharding("$DB_NAME");
            sh.shardCollection("$DB_NAME.$COLLECTION_NAME", { "name" : "hashed" } )
EOF`
    fi

    OUTPUT=`docker compose exec -T $ROUTER_SRV mongosh --port 27017 --quiet <<- EOF
        use $DB_NAME
        for(var i = 0; i < ${INIT_COLLECTION}; i++) db.$COLLECTION_NAME.insertOne({age:i, name:"ly"+i})
        print("Count: " + db.$COLLECTION_NAME.countDocuments())
EOF`
    echo $OUTPUT | awk -F'Count: ' '{split($2, a, " "); print "This collection has ", a[1], " documents"}'
    cd - > /dev/null
}

count_documents() {
    echo "Count documents in DB..."
    cd $TASK_DIR
    [ "$TASK" == "1" ] && ROUTER_SRV=mongodb1

    OUTPUT=`docker compose exec -T $ROUTER_SRV mongosh --port 27017 --quiet <<- EOF
        use $DB_NAME
        print("Count: " + db.$COLLECTION_NAME.countDocuments())
EOF`
    echo $OUTPUT | awk -F'Count: ' '{split($2, a, " "); print "This collection has ", a[1], " documents in total"}'

    if [ "$TASK" != "1" ]; then
        OUTPUT=`docker compose exec -T $SHARD1_SRV mongosh --port $SHARD1_PORT --quiet <<- EOF
            use $DB_NAME
            print("Count: " + db.$COLLECTION_NAME.countDocuments())
EOF`
        echo $OUTPUT | awk -v srv_name=$SHARD1_SRV -F'Count: ' '{split($2, a, " "); print "This collection has ", a[1], " documents on ", srv_name}'
        OUTPUT=`docker compose exec -T $SHARD2_SRV mongosh --port $SHARD2_PORT --quiet <<- EOF
            use $DB_NAME
            print("Count: " + db.$COLLECTION_NAME.countDocuments())
EOF`
        echo $OUTPUT | awk -v srv_name=$SHARD2_SRV -F'Count: ' '{split($2, a, " "); print "This collection has ", a[1], " documents on ", srv_name}'
    fi
    cd - > /dev/null
}

benchmark() {
    echo "Benchmarking..."
    URL1=$TOP_URL/
    URL2=$TOP_URL/$COLLECTION_NAME/users
    if [ "a$AB" != "a" ]; then
        BENCH1="ab -c ${TEST_CONC} -t ${TEST_TIME} $URL1"
        BENCH2="ab -c ${TEST_CONC} -t ${TEST_TIME} $URL2"
    else
        echo "Can't find benchmark tool. No 'ab' or 'siege' found"
        exit 1
    fi
    echo $BENCH1; $BENCH1 | egrep "Requests|90%"
    echo
    echo $BENCH2; $BENCH2 | egrep "Requests|90%"
}


if [ $# -eq 0 ]; then
    usage
    exit 1
fi
while getopts ":t:m:bchilr:" opt; do
    case ${opt} in
        b) # benchmark
            BENCHMARK=1
            ;;
        c) # count number of documents in DB
            COUNT=1
            ;;
        h) # help
            usage
            exit 1
            ;;
        i) # init db config
            INIT_DB_CONFIG=1
            ;;
        l) # list container names
            LIST_CONTAINERS=1
            ;;
        m) # mode
            MODE=${OPTARG}
            ;;
        r) # rebuild collection
            INIT_COLLECTION=${OPTARG}
            ;;
        t) # task
            TASK=${OPTARG}
            ;;
        :)
            echo "Option -${OPTARG} requires an argument"
            exit 1
            ;;
        ?)
            echo "Invalid option: -${OPTARG}"
            usage
            exit 1
            ;;
        *)
            usage
            exit 1
            ;;
    esac
done

#set -x
# Validate parameters
[ "a${TASK}" == "a" ] && error "-t parameter is missing"
[ ${TASK} -lt 1 -o ${TASK} -gt 6 ] && error "invalid task number, out of range 1..6"
[ "a${MODE}" != "a" -a "${MODE}" != "up" -a "${MODE}" != "down" ] && error "-m should be supplied with 'up' or 'down'"
[ "$BENCHMARK" == "1" -a "a${MODE}" != "a" ] && error "Can't specify -b and -m at the same time"
[ "$COUNT" == "1" -a "a${MODE}" != "a" ] && error "Can't specify -c and -m at the same time"
[ "a$INIT_COLLECTION" != "a" -a "a${MODE}" != "a" ] && error "Can't specify -r and -m at the same time"
[ "$BENCHMARK" == "1" -a "$COUNT" == "1" ] && error "Can't specify -b and -c at the same time"
[ "$BENCHMARK" == "1" -a "a$INIT_COLLECTION" != "a" ] && error "Can't specify -b and -r at the same time"
[ "$COUNT" == "1" -a "a$INIT_COLLECTION" != "a" ] && error "Can't specify -c and -r at the same time"


TASK_DIR=${TASK_DIRS[$(($TASK-1))]}
echo "Executing Task #${TASK}, working directory '${TASK_DIR}'"

[ "$MODE" == "up" ]            && start_containers
[ "$MODE" == "down" ]          && stop_containers
[ "a$INIT_DB_CONFIG" != "a" ]  && init_db_config
[ "a$INIT_COLLECTION" != "a" ] && init_collection
[ "$COUNT" == "1" ]            && count_documents
[ "$BENCHMARK" == "1" ]        && benchmark
[ "$LIST_CONTAINERS" == "1" ]  && list_containers

echo "Done"
exit 0