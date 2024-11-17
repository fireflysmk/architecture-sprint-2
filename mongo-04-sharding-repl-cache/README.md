
# pymongo-api

## Схема 

https://drive.google.com/file/d/1PTFq_9RRvGcDfHXvE4B7UUScDB3wk-KD/view?usp=sharing

## Как запустить

### Запускаем приложение и инфру вокруг

```shell
docker compose up -d
```
### Инициализируем config server

```shell
./scripts/01-mongo-config-srv-init.sh
```

<details>
<summary>Output</summary>

```
MongoDB shell version v4.4.18
connecting to: mongodb://127.0.0.1:27018/?compressors=disabled&gssapiServiceName=mongodb
Implicit session: session { "id" : UUID("0a8b2ba6-c328-4a05-9c56-55ac4c58111f") }
MongoDB server version: 4.4.18
{
	"ok" : 1,
	"$gleStats" : {
		"lastOpTime" : Timestamp(1731862883, 1),
		"electionId" : ObjectId("000000000000000000000000")
	},
	"lastCommittedOpTime" : Timestamp(0, 0)
}
bye
```

</details>

### Инициализируем шарды и их реплики

```shell
./scripts/02-mongo-shards-init.sh
```

<details>
<summary>Output</summary>

```
MongoDB shell version v4.4.18
connecting to: mongodb://127.0.0.1:27019/?compressors=disabled&gssapiServiceName=mongodb
Implicit session: session { "id" : UUID("c0b7b756-dc01-4860-8bc6-5c715b672b1f") }
MongoDB server version: 4.4.18
{ "ok" : 1 }
bye

MongoDB shell version v4.4.18
connecting to: mongodb://127.0.0.1:27023/?compressors=disabled&gssapiServiceName=mongodb
Implicit session: session { "id" : UUID("831bf9ec-ea32-4827-bb0f-571c76dd6642") }
MongoDB server version: 4.4.18
{ "ok" : 1 }
bye
```

</details>

### Инициализируем роутер и шардинг бд

```shell
./scripts/03-mongo-router-init.sh 
```

<details>
<summary>Output</summary>

```
MongoDB shell version v4.4.18
connecting to: mongodb://127.0.0.1:27017/?compressors=disabled&gssapiServiceName=mongodb
Implicit session: session { "id" : UUID("d0a9f415-1e77-4b24-aefe-9940a78946a1") }
MongoDB server version: 4.4.18
{
	"shardAdded" : "shard1",
	"ok" : 1,
	"operationTime" : Timestamp(1731863002, 6),
	"$clusterTime" : {
		"clusterTime" : Timestamp(1731863002, 6),
		"signature" : {
			"hash" : BinData(0,"AAAAAAAAAAAAAAAAAAAAAAAAAAA="),
			"keyId" : NumberLong(0)
		}
	}
}
{
	"shardAdded" : "shard2",
	"ok" : 1,
	"operationTime" : Timestamp(1731863004, 5),
	"$clusterTime" : {
		"clusterTime" : Timestamp(1731863004, 5),
		"signature" : {
			"hash" : BinData(0,"AAAAAAAAAAAAAAAAAAAAAAAAAAA="),
			"keyId" : NumberLong(0)
		}
	}
}
{
	"ok" : 1,
	"operationTime" : Timestamp(1731863004, 11),
	"$clusterTime" : {
		"clusterTime" : Timestamp(1731863004, 11),
		"signature" : {
			"hash" : BinData(0,"AAAAAAAAAAAAAAAAAAAAAAAAAAA="),
			"keyId" : NumberLong(0)
		}
	}
}
{
	"collectionsharded" : "somedb.helloDoc",
	"collectionUUID" : UUID("87a420c0-2fb4-4b0d-828c-4c06a461d1e5"),
	"ok" : 1,
	"operationTime" : Timestamp(1731863007, 2),
	"$clusterTime" : {
		"clusterTime" : Timestamp(1731863007, 2),
		"signature" : {
			"hash" : BinData(0,"AAAAAAAAAAAAAAAAAAAAAAAAAAA="),
			"keyId" : NumberLong(0)
		}
	}
}

--- Sharding Status --- 
  sharding version: {
  	"_id" : 1,
  	"minCompatibleVersion" : 5,
  	"currentVersion" : 6,
  	"clusterId" : ObjectId("673a2163cf242eecba53ae70")
  }
  shards:
        {  "_id" : "shard1",  "host" : "shard1/mongo_shard1:27019,mongo_shard1_replica:27020",  "state" : 1 }
        {  "_id" : "shard2",  "host" : "shard2/mongo_shard2:27023,mongo_shard2_replica:27024",  "state" : 1 }
  active mongoses:
        "4.4.18" : 1
  autosplit:
        Currently enabled: yes
  balancer:
        Currently enabled:  yes
        Currently running:  no
        Failed balancer rounds in last 5 attempts:  0
        Migration Results for the last 24 hours: 
                No recent migrations
  databases:
        {  "_id" : "config",  "primary" : "config",  "partitioned" : true }
        {  "_id" : "somedb",  "primary" : "shard1",  "partitioned" : true,  "version" : {  "uuid" : UUID("efb3035b-0a56-4fe3-b91a-5b2e6b29846d"),  "lastMod" : 1 } }
                somedb.helloDoc
                        shard key: { "name" : "hashed" }
                        unique: false
                        balancing: true
                        chunks:
                                shard1	2
                                shard2	2
                        { "name" : { "$minKey" : 1 } } -->> { "name" : NumberLong("-4611686018427387902") } on : shard1 Timestamp(1, 0) 
                        { "name" : NumberLong("-4611686018427387902") } -->> { "name" : NumberLong(0) } on : shard1 Timestamp(1, 1) 
                        { "name" : NumberLong(0) } -->> { "name" : NumberLong("4611686018427387902") } on : shard2 Timestamp(1, 2) 
                        { "name" : NumberLong("4611686018427387902") } -->> { "name" : { "$maxKey" : 1 } } on : shard2 Timestamp(1, 3) 
bye
```

</details>

### Заполняем базу данными

```shell
./scripts/04-mongo-init.sh
```

<details>
<summary>Output</summary>

```
MongoDB shell version v4.4.18
connecting to: mongodb://127.0.0.1:27017/?compressors=disabled&gssapiServiceName=mongodb
Implicit session: session { "id" : UUID("35265622-af2d-4910-858d-a779f3ce68b2") }
MongoDB server version: 4.4.18
switched to db somedb
{
	"acknowledged" : true,
	"insertedId" : ObjectId("673a21f3dc1e92bbb704a8a4")
}
bye
```

</details>
 
### Проверяем количество данных в шардах

```shell
./scripts/05-mongo-check-shards.sh 
```

```
MongoDB shell version v4.4.18
connecting to: mongodb://127.0.0.1:27019/?compressors=disabled&gssapiServiceName=mongodb
Implicit session: session { "id" : UUID("01f0ede5-a141-43c1-8dbb-05ce9fd287cf") }
MongoDB server version: 4.4.18
switched to db somedb
508
bye

MongoDB shell version v4.4.18
connecting to: mongodb://127.0.0.1:27023/?compressors=disabled&gssapiServiceName=mongodb
Implicit session: session { "id" : UUID("bdf42b86-ef3f-48ec-9eed-7df9a270defa") }
MongoDB server version: 4.4.18
switched to db somedb
492
bye
```

### Проверяем статус и количество данных в репликах

```shell
./scripts/06-mongo-check-replicas.sh 
```

<details>
<summary>Output</summary>

```
MongoDB shell version v4.4.18
connecting to: mongodb://127.0.0.1:27020/?compressors=disabled&gssapiServiceName=mongodb
Implicit session: session { "id" : UUID("024b49e2-b691-4e42-8aca-52e4898241fc") }
MongoDB server version: 4.4.18
{
	"set" : "shard1",
	"date" : ISODate("2024-11-17T17:04:14.699Z"),
	"myState" : 2,
	"term" : NumberLong(1),
	"syncSourceHost" : "mongo_shard1:27019",
	"syncSourceId" : 0,
	"heartbeatIntervalMillis" : NumberLong(2000),
	"majorityVoteCount" : 2,
	"writeMajorityCount" : 2,
	"votingMembersCount" : 2,
	"writableVotingMembersCount" : 2,
	"optimes" : {
		"lastCommittedOpTime" : {
			"ts" : Timestamp(1731863052, 1),
			"t" : NumberLong(1)
		},
		"lastCommittedWallTime" : ISODate("2024-11-17T17:04:12.598Z"),
		"readConcernMajorityOpTime" : {
			"ts" : Timestamp(1731863052, 1),
			"t" : NumberLong(1)
		},
		"readConcernMajorityWallTime" : ISODate("2024-11-17T17:04:12.598Z"),
		"appliedOpTime" : {
			"ts" : Timestamp(1731863052, 1),
			"t" : NumberLong(1)
		},
		"durableOpTime" : {
			"ts" : Timestamp(1731863052, 1),
			"t" : NumberLong(1)
		},
		"lastAppliedWallTime" : ISODate("2024-11-17T17:04:12.598Z"),
		"lastDurableWallTime" : ISODate("2024-11-17T17:04:12.598Z")
	},
	"lastStableRecoveryTimestamp" : Timestamp(1731863027, 566),
	"electionParticipantMetrics" : {
		"votedForCandidate" : true,
		"electionTerm" : NumberLong(1),
		"lastVoteDate" : ISODate("2024-11-17T17:01:52.521Z"),
		"electionCandidateMemberId" : 0,
		"voteReason" : "",
		"lastAppliedOpTimeAtElection" : {
			"ts" : Timestamp(1731862902, 1),
			"t" : NumberLong(-1)
		},
		"maxAppliedOpTimeInSet" : {
			"ts" : Timestamp(1731862902, 1),
			"t" : NumberLong(-1)
		},
		"priorityAtElection" : 1,
		"newTermStartDate" : ISODate("2024-11-17T17:01:52.554Z"),
		"newTermAppliedDate" : ISODate("2024-11-17T17:01:53.775Z")
	},
	"members" : [
		{
			"_id" : 0,
			"name" : "mongo_shard1:27019",
			"health" : 1,
			"state" : 1,
			"stateStr" : "PRIMARY",
			"uptime" : 152,
			"optime" : {
				"ts" : Timestamp(1731863052, 1),
				"t" : NumberLong(1)
			},
			"optimeDurable" : {
				"ts" : Timestamp(1731863052, 1),
				"t" : NumberLong(1)
			},
			"optimeDate" : ISODate("2024-11-17T17:04:12Z"),
			"optimeDurableDate" : ISODate("2024-11-17T17:04:12Z"),
			"lastAppliedWallTime" : ISODate("2024-11-17T17:04:12.598Z"),
			"lastDurableWallTime" : ISODate("2024-11-17T17:04:12.598Z"),
			"lastHeartbeat" : ISODate("2024-11-17T17:04:13.817Z"),
			"lastHeartbeatRecv" : ISODate("2024-11-17T17:04:12.714Z"),
			"pingMs" : NumberLong(0),
			"lastHeartbeatMessage" : "",
			"syncSourceHost" : "",
			"syncSourceId" : -1,
			"infoMessage" : "",
			"electionTime" : Timestamp(1731862912, 1),
			"electionDate" : ISODate("2024-11-17T17:01:52Z"),
			"configVersion" : 2,
			"configTerm" : 1
		},
		{
			"_id" : 1,
			"name" : "mongo_shard1_replica:27020",
			"health" : 1,
			"state" : 2,
			"stateStr" : "SECONDARY",
			"uptime" : 177,
			"optime" : {
				"ts" : Timestamp(1731863052, 1),
				"t" : NumberLong(1)
			},
			"optimeDate" : ISODate("2024-11-17T17:04:12Z"),
			"lastAppliedWallTime" : ISODate("2024-11-17T17:04:12.598Z"),
			"lastDurableWallTime" : ISODate("2024-11-17T17:04:12.598Z"),
			"syncSourceHost" : "mongo_shard1:27019",
			"syncSourceId" : 0,
			"infoMessage" : "",
			"configVersion" : 2,
			"configTerm" : 1,
			"self" : true,
			"lastHeartbeatMessage" : ""
		}
	],
	"ok" : 1,
	"$gleStats" : {
		"lastOpTime" : Timestamp(0, 0),
		"electionId" : ObjectId("000000000000000000000000")
	},
	"lastCommittedOpTime" : Timestamp(1731863052, 1),
	"$configServerState" : {
		"opTime" : {
			"ts" : Timestamp(1731863030, 1),
			"t" : NumberLong(1)
		}
	},
	"$clusterTime" : {
		"clusterTime" : Timestamp(1731863052, 1),
		"signature" : {
			"hash" : BinData(0,"AAAAAAAAAAAAAAAAAAAAAAAAAAA="),
			"keyId" : NumberLong(0)
		}
	},
	"operationTime" : Timestamp(1731863052, 1)
}
switched to db somedb
508
bye

MongoDB shell version v4.4.18
connecting to: mongodb://127.0.0.1:27024/?compressors=disabled&gssapiServiceName=mongodb
Implicit session: session { "id" : UUID("44e541cc-dbc9-4ee0-ab81-2cd374df5357") }
MongoDB server version: 4.4.18
{
	"set" : "shard2",
	"date" : ISODate("2024-11-17T17:04:15.205Z"),
	"myState" : 2,
	"term" : NumberLong(1),
	"syncSourceHost" : "mongo_shard2:27023",
	"syncSourceId" : 0,
	"heartbeatIntervalMillis" : NumberLong(2000),
	"majorityVoteCount" : 2,
	"writeMajorityCount" : 2,
	"votingMembersCount" : 2,
	"writableVotingMembersCount" : 2,
	"optimes" : {
		"lastCommittedOpTime" : {
			"ts" : Timestamp(1731863053, 1),
			"t" : NumberLong(1)
		},
		"lastCommittedWallTime" : ISODate("2024-11-17T17:04:13.784Z"),
		"readConcernMajorityOpTime" : {
			"ts" : Timestamp(1731863053, 1),
			"t" : NumberLong(1)
		},
		"readConcernMajorityWallTime" : ISODate("2024-11-17T17:04:13.784Z"),
		"appliedOpTime" : {
			"ts" : Timestamp(1731863053, 1),
			"t" : NumberLong(1)
		},
		"durableOpTime" : {
			"ts" : Timestamp(1731863053, 1),
			"t" : NumberLong(1)
		},
		"lastAppliedWallTime" : ISODate("2024-11-17T17:04:13.784Z"),
		"lastDurableWallTime" : ISODate("2024-11-17T17:04:13.784Z")
	},
	"lastStableRecoveryTimestamp" : Timestamp(1731863027, 563),
	"electionParticipantMetrics" : {
		"votedForCandidate" : true,
		"electionTerm" : NumberLong(1),
		"lastVoteDate" : ISODate("2024-11-17T17:01:53.706Z"),
		"electionCandidateMemberId" : 0,
		"voteReason" : "",
		"lastAppliedOpTimeAtElection" : {
			"ts" : Timestamp(1731862902, 1),
			"t" : NumberLong(-1)
		},
		"maxAppliedOpTimeInSet" : {
			"ts" : Timestamp(1731862902, 1),
			"t" : NumberLong(-1)
		},
		"priorityAtElection" : 1,
		"newTermStartDate" : ISODate("2024-11-17T17:01:53.738Z"),
		"newTermAppliedDate" : ISODate("2024-11-17T17:01:54.699Z")
	},
	"members" : [
		{
			"_id" : 0,
			"name" : "mongo_shard2:27023",
			"health" : 1,
			"state" : 1,
			"stateStr" : "PRIMARY",
			"uptime" : 151,
			"optime" : {
				"ts" : Timestamp(1731863053, 1),
				"t" : NumberLong(1)
			},
			"optimeDurable" : {
				"ts" : Timestamp(1731863053, 1),
				"t" : NumberLong(1)
			},
			"optimeDate" : ISODate("2024-11-17T17:04:13Z"),
			"optimeDurableDate" : ISODate("2024-11-17T17:04:13Z"),
			"lastAppliedWallTime" : ISODate("2024-11-17T17:04:13.784Z"),
			"lastDurableWallTime" : ISODate("2024-11-17T17:04:13.784Z"),
			"lastHeartbeat" : ISODate("2024-11-17T17:04:14.953Z"),
			"lastHeartbeatRecv" : ISODate("2024-11-17T17:04:14.892Z"),
			"pingMs" : NumberLong(0),
			"lastHeartbeatMessage" : "",
			"syncSourceHost" : "",
			"syncSourceId" : -1,
			"infoMessage" : "",
			"electionTime" : Timestamp(1731862913, 1),
			"electionDate" : ISODate("2024-11-17T17:01:53Z"),
			"configVersion" : 2,
			"configTerm" : 1
		},
		{
			"_id" : 1,
			"name" : "mongo_shard2_replica:27024",
			"health" : 1,
			"state" : 2,
			"stateStr" : "SECONDARY",
			"uptime" : 178,
			"optime" : {
				"ts" : Timestamp(1731863053, 1),
				"t" : NumberLong(1)
			},
			"optimeDate" : ISODate("2024-11-17T17:04:13Z"),
			"lastAppliedWallTime" : ISODate("2024-11-17T17:04:13.784Z"),
			"lastDurableWallTime" : ISODate("2024-11-17T17:04:13.784Z"),
			"syncSourceHost" : "mongo_shard2:27023",
			"syncSourceId" : 0,
			"infoMessage" : "",
			"configVersion" : 2,
			"configTerm" : 1,
			"self" : true,
			"lastHeartbeatMessage" : ""
		}
	],
	"ok" : 1,
	"$gleStats" : {
		"lastOpTime" : Timestamp(0, 0),
		"electionId" : ObjectId("000000000000000000000000")
	},
	"lastCommittedOpTime" : Timestamp(1731863053, 1),
	"$configServerState" : {
		"opTime" : {
			"ts" : Timestamp(1731863032, 1),
			"t" : NumberLong(1)
		}
	},
	"$clusterTime" : {
		"clusterTime" : Timestamp(1731863053, 1),
		"signature" : {
			"hash" : BinData(0,"AAAAAAAAAAAAAAAAAAAAAAAAAAA="),
			"keyId" : NumberLong(0)
		}
	},
	"operationTime" : Timestamp(1731863053, 1)
}
switched to db somedb
492
bye
```

</details>

### Проверяем топологию

```shell
curl localhost:8080/ | jq
```

```json
{
  "mongo_topology_type": "Sharded",
  "mongo_replicaset_name": null,
  "mongo_db": "somedb",
  "read_preference": "Primary()",
  "mongo_nodes": [
    [
      "mongo_router",
      27017
    ]
  ],
  "mongo_primary_host": null,
  "mongo_secondary_hosts": [],
  "mongo_address": [
    "mongo_router",
    27017
  ],
  "mongo_is_primary": true,
  "mongo_is_mongos": true,
  "collections": {
    "helloDoc": {
      "documents_count": 1000
    }
  },
  "shards": {
    "shard1": "shard1/mongo_shard1:27019,mongo_shard1_replica:27020",
    "shard2": "shard2/mongo_shard2:27023,mongo_shard2_replica:27024"
  },
  "cache_enabled": true,
  "status": "OK"
}
```

### Проверяем работу кэша

```shell
curl -o /dev/null -s -w 'Total: %{time_total}s\n' http://localhost:8080/helloDoc/users
# Total: 1.031265s
```

```shell
curl -o /dev/null -s -w 'Total: %{time_total}s\n' http://localhost:8080/helloDoc/users
# Total: 0.008453s
```

## Доступные эндпоинты

Список доступных эндпоинтов, swagger http://localhost:8080/docs
