#!/usr/bin/env bash

TOP_DIR=`pwd`/`dirname $0`
TASK_DIRS=(mongo-single mongo-sharding mongo-sharding-repl sharding-repl-cache sharding-repl-cache-apisix sharding-repl-cache-cdn)
TASK=""
MODE=""
BENCHMARK=0
COUNT=0
SELECT=0
INIT_COLLECTION=""
WHAT_IS=""

AB=`which ab`
SIEGE=`which siege`
TEST_TIME=60
TEST_CONC=5
URLS_FILE=${TOP_DIR}/urls.lst

DB_NAME=somedb
COLLECTION_NAME=helloDoc

CONFIG_NAME=config_server
CONFIG_SRV=configSrv
ROUTER_SRV=mongos_router
SHARD1_SRV=shard1
SHARD2_SRV=shard2
SHARD1A_SRV=shard1a
SHARD1B_SRV=shard1b
SHARD2A_SRV=shard2a
SHARD2B_SRV=shard2b

# Could use yq here, but there is no guarantee that everyone has it
ROUTER_PORT=27017
SHARD1_PORT=27018
SHARD2_PORT=27019
CONFIG_PORT=27020
SHARD1A_PORT=27028
SHARD1B_PORT=27038
SHARD2A_PORT=27029
SHARD2B_PORT=27039

TOP_URL="http://127.0.0.1:8080"


function usage() {
    echo
    echo "Usage:"
    echo "  $0 -t <task_num> [-m <mode>] [-h] [-b <seconds>] [-c] [-i] [-r <num_doc>] [-s <num_doc>] [-w <what_is>]"
    echo "Where"
    echo "  -t task_num -            task number from this sprint (1..6)"
    echo "  -m mode     - (optional) containers' mode (one of 'start' or 'stop')"
    echo "  -b seconds  - (optional) conduct benchmarks with duration of specified number of seconds"
    echo "  -c          - (optional) count number of documents in DB"
    echo "  -i          - (optional) init DB configuration"
    echo "  -r num_doc  - (optional) recreate collection with num_doc documents"
    echo "  -s num_doc  - (optional) select num_doc from each shard for better benchmarking"
    echo "  -w what_is  - (optional) get an answer for 'what is'-kind of question"
    echo
    echo "  -h          - (optional) this help"
    echo
    echo "Supported 'what is'-kind of questions:"
    echo "  rs_status   - replica set(s) status"
    echo "  sh_status   - sharding status, according to router_server"
    echo
}


function error() {
    echo $1
    exit 2
}


function start_containers() {
    echo "Staring containers..."
    cd $TASK_DIR
    docker compose up -d
    cd - > /dev/null
}


function stop_containers() {
    echo "Stopping containers..."
    cd $TASK_DIR
    docker compose down
    cd - > /dev/null
}


function init_db_config() {
    echo "Init DB config..."
    docker ps
    [ "$TASK" == "1" ] && return

    if [ "$TASK" == "2" ]; then
        SHARD1_MEMBERS="{ _id : 0, host : \"$SHARD1_SRV:$SHARD1_PORT\" }"
        SHARD2_MEMBERS="{ _id : 1, host : \"$SHARD2_SRV:$SHARD2_PORT\" }"
        SHARD1_LIST="$SHARD1_SRV/$SHARD1_SRV:$SHARD1_PORT"
        SHARD2_LIST="$SHARD2_SRV/$SHARD2_SRV:$SHARD2_PORT"
    else
        SHARD1_MEMBERS="{ _id : 0, host : \"$SHARD1_SRV:$SHARD1_PORT\" },{ _id : 1, host : \"$SHARD1A_SRV:$SHARD1A_PORT\" },{ _id : 2, host : \"$SHARD1B_SRV:$SHARD1B_PORT\" }"
        SHARD2_MEMBERS="{ _id : 3, host : \"$SHARD2_SRV:$SHARD2_PORT\" },{ _id : 4, host : \"$SHARD2A_SRV:$SHARD2A_PORT\" },{ _id : 5, host : \"$SHARD2B_SRV:$SHARD2B_PORT\" }"
        SHARD1_LIST="$SHARD1_SRV/$SHARD1_SRV:$SHARD1_PORT,$SHARD1A_SRV:$SHARD1A_PORT,$SHARD1B_SRV:$SHARD1B_PORT"
        SHARD2_LIST="$SHARD2_SRV/$SHARD2_SRV:$SHARD2_PORT,$SHARD2A_SRV:$SHARD2A_PORT,$SHARD2B_SRV:$SHARD2B_PORT"
    fi

    cd $TASK_DIR
    docker compose exec -T $CONFIG_SRV mongosh --port $CONFIG_PORT --quiet > /dev/null <<- EOF
        rs.initiate(
            {
                _id : "$CONFIG_NAME",
                configsvr: true,
                members: [ { _id : 0, host : "$CONFIG_SRV:$CONFIG_PORT" } ]
            }
        );
EOF
    echo "Give few seconds to $CONFIG_SRV to digest the change in its config..."
    sleep 10

    docker compose exec -T $SHARD1_SRV mongosh --port $SHARD1_PORT --quiet > /dev/null <<- EOF
        rs.initiate(
            {
                _id : "$SHARD1_SRV",
                members: [ $SHARD1_MEMBERS ]
            }
        );
        use $DB_NAME;
        db.dropDatabase()
EOF
    docker compose exec -T $SHARD2_SRV mongosh --port $SHARD2_PORT --quiet > /dev/null <<- EOF
        rs.initiate(
            {
                _id : "$SHARD2_SRV",
                members: [ $SHARD2_MEMBERS ]
            }
        );
        use $DB_NAME;
        db.dropDatabase()
EOF
    docker compose exec -T $ROUTER_SRV mongosh --port $ROUTER_PORT > /dev/null <<- EOF
        sh.addShard("$SHARD1_LIST");
        sh.addShard("$SHARD2_LIST");

        sh.enableSharding("$DB_NAME");
        sh.shardCollection("$DB_NAME.$COLLECTION_NAME", { "name" : "hashed" } )
EOF
    cd - > /dev/null
    echo "Server configuration is complete!"
    docker ps
}


function init_collection() {
    echo "Initialize DB with ${INIT_COLLECTION} documents..."
    cd $TASK_DIR
    [ "$TASK" == "1" ] && ROUTER_SRV=mongodb1

    docker compose exec -T $ROUTER_SRV mongosh --port $ROUTER_PORT --quiet > /dev/null <<- EOF
        use $DB_NAME
        db.$COLLECTION_NAME.drop()
EOF

    if [ "$TASK" != 1 ]; then
        docker compose exec -T $ROUTER_SRV mongosh --port $ROUTER_PORT --quiet > /dev/null <<- EOF
            sh.enableSharding("$DB_NAME");
            sh.shardCollection("$DB_NAME.$COLLECTION_NAME", { "name" : "hashed" } )
EOF
    fi

    OUTPUT=`docker compose exec -T $ROUTER_SRV mongosh --port $ROUTER_PORT --quiet <<- EOF
        use $DB_NAME
        for(var i = 0; i < ${INIT_COLLECTION}; i++) db.$COLLECTION_NAME.insertOne({age:i, name:"ly"+i})
        print("Count: " + db.$COLLECTION_NAME.countDocuments())
EOF`
    echo $OUTPUT | awk -F'Count: ' '{split($2, a, " "); print "This collection has ", a[1], " documents"}'
    cd - > /dev/null
}


function count_documents() {
    echo "Count documents in DB..."
    cd $TASK_DIR
    [ "$TASK" == "1" ] && ROUTER_SRV=mongodb1

    OUTPUT=`docker compose exec -T $ROUTER_SRV mongosh --port $ROUTER_PORT --quiet <<- EOF
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


function select_data() {
    echo "Selecting data sample from each shard..."
    cd $TASK_DIR
    if [ "$TASK" == "1" ]; then
        ROUTER_SRV=mongodb1
        OUTPUT=`docker compose exec -T $ROUTER_SRV mongosh --port $ROUTER_PORT --quiet <<- EOF
            use $DB_NAME;
            db.$COLLECTION_NAME.find({}).limit($SELECT).forEach(function(a){print('$TOP_URL/$COLLECTION_NAME/users/'+a.name)});
EOF`
        echo $OUTPUT | awk '{for (i=1; i<=NF; i++) if ($i ~ /http/) print $i}' | tee $URLS_FILE
    else
        echo "Some documents on $SHARD1_SRV:"
        OUTPUT=`docker compose exec -T $SHARD1_SRV mongosh --port $SHARD1_PORT --quiet <<- EOF
            use $DB_NAME;
            db.$COLLECTION_NAME.find({}).limit($SELECT).forEach(function(a){print('$TOP_URL/$COLLECTION_NAME/users/'+a.name)});
EOF`
        echo $OUTPUT | awk '{for (i=1; i<=NF; i++) if ($i ~ /http/) print $i}' | tee $URLS_FILE

        echo "Some documents on $SHARD2_SRV:"
        OUTPUT=`docker compose exec -T $SHARD2_SRV mongosh --port $SHARD2_PORT --quiet <<- EOF
            use $DB_NAME;
            db.$COLLECTION_NAME.find({}).limit($SELECT).forEach(function(a){print('$TOP_URL/$COLLECTION_NAME/users/'+a.name)});
EOF`
        echo $OUTPUT | awk '{for (i=1; i<=NF; i++) if ($i ~ /http/) print $i}' | tee -a $URLS_FILE
    fi
    cd - > /dev/null
}


function rs_status() {
    cd $TASK_DIR
    echo "Replicaset status"
    echo "On ${SHARD1_SRV}..."
    docker compose exec -T $SHARD1_SRV mongosh --port $SHARD1_PORT --quiet <<- EOF
        var prompt=">"
        rs.status().members.forEach( function (z) { print(z.name + ' -> ' + z.stateStr) } )
EOF
    echo
    echo "On ${SHARD2_SRV}..."
    docker compose exec -T $SHARD2_SRV mongosh --port $SHARD2_PORT --quiet <<- EOF
        var prompt=">"
        rs.status().members.forEach( function (z) { print(z.name + ' -> ' + z.stateStr) } )
EOF
    cd - > /dev/null
}


function sh_status() {
    echo "Cheking status of sharding in the Mongo cluster at ${ROUTER_SRV}..."
    cd $TASK_DIR
    docker compose exec -T $ROUTER_SRV mongosh --port $ROUTER_PORT --quiet <<- EOF
        sh.status();
EOF
    cd - > /dev/null
}


function benchmark() {
    echo "Benchmarking..."
    URL1=$TOP_URL/
    URL2=$TOP_URL/$COLLECTION_NAME/users
    if [ "a$SIEGE" != "a" ]; then
        GREP="Transaction|Throughput|Response"
        SIEGE_LOG="./siege.log"
        BENCH1="siege -b -c ${TEST_CONC} -t ${TEST_TIME}s --rc=/dev/null $URL1"
        echo $BENCH1; $BENCH1 > $SIEGE_LOG 2>&1; egrep -i "$GREP" $SIEGE_LOG
        BENCH2="siege -b -c ${TEST_CONC} -t ${TEST_TIME}s --rc=/dev/null $URL2"
        echo $BENCH2; $BENCH2 > $SIEGE_LOG 2>&1; egrep -i "$GREP" $SIEGE_LOG
        BENCH3="siege -b -c ${TEST_CONC} -t ${TEST_TIME}s --rc=/dev/null --file=$URLS_FILE"
        echo $BENCH3; $BENCH3 > $SIEGE_LOG 2>&1; egrep -i "$GREP" $SIEGE_LOG
        rm $SIEGE_LOG
    elif [ "a$AB" != "a" ]; then
        GREP="Requests|90%"
        BENCH1="ab -c ${TEST_CONC} -t ${TEST_TIME} $URL1"
        echo $BENCH1; $BENCH1 2>/dev/null | egrep -i "$GREP"
        BENCH2="ab -c ${TEST_CONC} -t ${TEST_TIME} $URL2"
        echo $BENCH2; $BENCH2 2>/dev/null | egrep -i "$GREP"
    else
        echo "Can't find benchmark tool. No 'ab' or 'siege' found"
        exit 1
    fi
}


# ================================= MAIN =====================================
if [ $# -eq 0 ]; then
    usage
    exit 1
fi

while getopts ":t:m:b:chir:s:w:" opt; do
    case ${opt} in
        b) # benchmark
            BENCHMARK=1
            TEST_TIME=${OPTARG}
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
        m) # mode
            MODE=${OPTARG}
            ;;
        r) # rebuild collection
            INIT_COLLECTION=${OPTARG}
            ;;
        s) # select sample data
            SELECT=${OPTARG}
            ;;
        t) # task
            TASK=${OPTARG}
            ;;
        w) # 'what is' question
            WHAT_IS=${OPTARG}
            ;;
        :)
            echo "Option -${OPTARG} requires an argument"
            usage
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
[ "a${MODE}" != "a" -a "${MODE}" != "start" -a "${MODE}" != "stop" ] && error "-m should be supplied with 'start' or 'stop'"
[ "$BENCHMARK" == "1" -a "a${MODE}" != "a" ] && error "Can't specify -b and -m at the same time"
[ "$COUNT" == "1" -a "a${MODE}" != "a" ] && error "Can't specify -c and -m at the same time"
[ "a$INIT_COLLECTION" != "a" -a "a${MODE}" != "a" ] && error "Can't specify -r and -m at the same time"
[ "$BENCHMARK" == "1" -a "$COUNT" == "1" ] && error "Can't specify -b and -c at the same time"
[ "$BENCHMARK" == "1" -a "a$INIT_COLLECTION" != "a" ] && error "Can't specify -b and -r at the same time"
[ "$COUNT" == "1" -a "a$INIT_COLLECTION" != "a" ] && error "Can't specify -c and -r at the same time"


TASK_DIR=${TASK_DIRS[$(($TASK-1))]}
echo "Executing Task #${TASK}, working directory '${TASK_DIR}'"

[ "$MODE" == "start" ]         && start_containers
[ "$MODE" == "stop" ]          && stop_containers
[ "a$INIT_DB_CONFIG" != "a" ]  && init_db_config
[ "a$INIT_COLLECTION" != "a" ] && init_collection
[ "$COUNT" == "1" ]            && count_documents
[ "$BENCHMARK" == "1" ]        && benchmark
[ "$SELECT" != "0" ]           && select_data
if [ "a$WHAT_IS" != "a" ]; then
    case $WHAT_IS in
        rs_status)
            rs_status
            ;;
        sh_status)
            sh_status
            ;;
    esac
fi

echo "Done"
exit 0