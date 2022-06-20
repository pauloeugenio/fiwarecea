#!/bin/bash


set -e

if (( $# != 1 )); then
    echo "Illegal number of parameters"
    echo "usage: services [create|start|stop]"
    exit 1
fi

command="$1"
case "${command}" in
	"help")
        echo "usage: services [create|start|stop]"
        ;;
    "start")
		
		echo ""
		docker compose -p fiware up -d --remove-orphans
		echo ""
		;;
	"stop")
		echo "stopping containers"
		docker compose -p fiware down -v --remove-orphans
		;;
	"create")
		echo "Obtaining Mongo DB image"
		docker pull mongo:3.6

		echo "Obtaining Latest Orion Image"
		docker pull fiware/orion:latest
		echo "Obtaining MySQL DB image"
		docker pull mysql
		echo "Obtaining Latest UltraLight IoT Agent"
		docker pull fiware/iotagent-ul:latest
		echo "Obtaining Latest Mosquitto Message Broker"
		docker pull eclipse-mosquitto:latest
		echo "Obtaining Latest Cygnus"
		docker pull fiware/cygnus-ngsi:latest
		echo "Obtaining Latest Portainer"
		docker pull portainer/portainer
		#echo "Obtaining Latest Httpd"
		#docker pull httpd
		;;
	*)
		echo "Command not Found."
		echo "usage: services [create|start|stop]"
		exit 127;
		;;
esac



