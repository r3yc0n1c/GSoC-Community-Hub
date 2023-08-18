#!/bin/sh
ERR_FILE=open-event-server/log/err_log.txt
INIT_DB=open-event-server/seed/init_db


echo "--Starting the Open Event server--"
cd open-event-server
sh startOes.sh $1 $2

cd ..

OES_CONTAINER_ID=$( docker ps -q -f name=opev-web )

if [ -s $ERR_FILE ];then
    echo "\033[31m***Some error occurred while starting the Open Event Server please check open-event-server/$ERR_FILE , resolve them, and then re-run the init command***\e[0m"
    exit 1
fi
if [ -z $OES_CONTAINER_ID ]; then
    echo "\033[31m***Open-event-server Docker container was unable to install and start, please rerun the script***\e[0m"    
    exit 1
else
    cd open-event-server
    docker ps
    sleep 30
    docker exec -i opev-postgres /bin/sh /var/log/seed/seed.sh
    docker-compose logs postgres

    cd ..
    if [ ! -e $INIT_DB ];then
        echo "\033[31m***Open-event-server DB was not seeded with demo event, please check pg logs***\e[0m"
        exit 1
    else
        echo "--Successfully seeded the database with demo data--"
    fi
fi
