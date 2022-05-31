#!/bin/bash

##########################

MYSQL_ROOT_PASSWORD="f1w@rec3a2022"
MYSQL_FIWARE_PASSWORD="f1wArec3a2022"
DEVICE_IDS=( "SM000" "SM001" "SM002" "SM003" "SM004" "SM005" "SM006" )
DEVICE_NAMES=( "SM:000" "SM:001" "SM:002" "SM:003" "SM:004" "SM:005" )

##########################



#Exit immediately if a command exits with a non-zero status.
set -e

#Print commands and their arguments as they are executed.
set -x

#Stop all running containers
#docker stop $(docker ps -q)

#Create and start containers
./services start

#Wait for services to start
sleep 10


###########   Add service group

curl -iX POST \
  'http://127.0.0.1:4041/iot/services' \
  -H 'Content-Type: application/json' \
  -H 'fiware-service: openiot' \
  -H 'fiware-servicepath: /' \
  -d '{
 "services": [
   {
     "apikey":      "4jggokgpepnvsb2uv4s40d59ov",
     "cbroker":     "http://orion:1026",
     "entity_type": "Thing",
     "resource":    "/iot/d"
   }
 ]
}'



############   Add sensors 


for i in "${!DEVICE_IDS[@]}"
do

	curl -iX POST \
	'http://127.0.0.1:4041/iot/devices' \
	  -H 'Content-Type: application/json' \
	  -H 'fiware-service: openiot' \
	  -H 'fiware-servicepath: /' \
	  -d '{
	 "devices": [
	   {
	     "device_id":   "'${DEVICE_IDS[$i]}'",
	     "entity_name": "'${DEVICE_NAMES[$i]}'",
	     "entity_type": "Sensor",
	     "protocol":    "PDI-IoTA-UltraLight",
	     "transport":   "MQTT",
	     "timezone":    "America/Fortaleza",
	     "attributes": [
	       { "object_id": "voltA", "name": "voltA", "type": "float" },
	       { "object_id": "correnteA", "name": "correnteA", "type": "float" },
	       { "object_id": "potenciaAtiva", "name": "potenciaAtiva", "type": "float" },
	       { "object_id": "voltTHDA", "name": "voltTHDA", "type": "float" },
	       { "object_id": "correnteTHDA", "name": "correnteTHDA", "type": "float" },
	       { "object_id": "potenciaReativa", "name": "potenciaReativa", "type": "float" },
	       { "object_id": "potenciaAparente", "name": "potenciaAparente", "type": "float" },
	       { "object_id": "fatorDePotencia", "name": "fatorDePotencia", "type": "float" },
	       { "object_id": "frequencia", "name": "frequencia", "type": "float" },
	       { "object_id": "anguloVoltAB", "name": "anguloVoltAB", "type": "float" },
	       { "object_id": "voltB", "name": "voltB", "type": "float" },
	       { "object_id": "correnteB", "name": "correnteB", "type": "float" },
	       { "object_id": "voltTHDB", "name": "voltTHDB", "type": "float" },
	       { "object_id": "correnteTHDB", "name": "correnteTHDB", "type": "float" },
	       { "object_id": "anguloVoltBC", "name": "anguloVoltBC", "type": "float" },
	       { "object_id": "voltC", "name": "voltC", "type": "float" },
	       { "object_id": "correnteC", "name": "correnteC", "type": "float" },
	       { "object_id": "voltTHDC", "name": "voltTHDC", "type": "float" },
	       { "object_id": "correnteTHDC", "name": "correnteTHDC", "type": "float" },
	       { "object_id": "anguloVoltAC", "name": "anguloVoltAC", "type": "float" },
	       { "object_id": "energiaAtiva", "name": "energiaAtiva", "type": "float" },
	       { "object_id": "energiaReativa", "name": "energiaReativa", "type": "float" },
	       { "object_id": "energiaAparente", "name": "energiaAparente", "type": "float" },
	       { "object_id": "timestamp", "name": "timestamp", "type": "float" },
	       { "object_id": "RSSI", "name": "RSSI", "type": "float" },
	       { "object_id": "NTP", "name": "NTP", "type": "float" }
	     ]
	   }
	 ]
	}'

done

###########   Setting up mysql

#sleep 30

#echo "
#	CREATE USER 'fiware'@'%' IDENTIFIED BY '"$MYSQL_FIWARE_PASSWORD"';
#	GRANT ALL PRIVILEGES ON *.* TO 'fiware'@'%';
#	FLUSH PRIVILEGES;
#" | docker exec -i db-mysql bash -c 'mysql -u root -p'$MYSQL_ROOT_PASSWORD' '

#sleep 1


###########   Subscription - Notify Cygnus of all context changes to mysql

curl -iX POST \
  'http://localhost:1026/v2/subscriptions' \
  -H 'Content-Type: application/json' \
  -H 'fiware-service: openiot' \
  -H 'fiware-servicepath: /' \
  -d '{
  "description": "Notify Cygnus of all context changes",
  "subject": {
	"entities": [
  	{
    	"idPattern": ".*"
  	}
	]
  },
  "notification": {
	"http": {
  	"url": "http://cygnus:5050/notify"
	},
	"attrsFormat": "legacy"
  },
  "throttling": 5
}'


curl -iX POST \
  'http://localhost:1026/v2/subscriptions' \
  -H 'Content-Type: application/json' \
  -H 'fiware-service: openiot' \
  -H 'fiware-servicepath: /' \
  -d '{
  "description": "Notify Cygnus of all context changes",
  "subject": {
	"entities": [
  	{
    	"idPattern": ".*"
  	}
	]
  },
  "notification": {
	"http": {
  	"url": "http://cygnus:5080/notify"
	},
	"attrsFormat": "legacy"
  },
  "throttling": 5
}'


docker restart fiware-cygnus
sleep 10


echo "OK"

###########   Setting up mysql

sleep 30


echo "setup mysql manually"
# manually type what is commented below

#docker exec -it db-mysql bash
#'mysql -u root -p'f1w@rec3a2022';
#CREATE USER 'fiware'@'%' IDENTIFIED BY '"f1wArec3a2022"';
#GRANT ALL PRIVILEGES ON *.* TO 'fiware'@'%';
#FLUSH PRIVILEGES;

#sleep 1

#ALTER USER 'fiware'@'%' IDENTIFIED WITH mysql_native_password BY 'f1wArec3a2022';

#cat openiot.sql | docker exec -i db-mysql bash -c 'mysql -u fiware -p'f1wArec3a2022' '


=======
>>>>>>> 5fea83a1c63707685a1e44dc552b3ca34825e43e
docker ps

