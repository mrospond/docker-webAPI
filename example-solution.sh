#!/bin/bash

function restart() {
        # restart $1 container
        curl --data "t=0" http://172.17.0.1:2375/containers/$1/restart

        if [ $? -ne 0 ]; then
                echo "ERROR restart"
                exit -1
        fi
}

function test2_handler() {
        local container_down=$(curl -s http://172.17.0.1:2375/containers/test2/json | grep -io 'No such container\|"Running":false')

        if [ "$container_down" == "No such container" ]; then
                # create test2 container with /test2 dir mounted to the container
                echo "test2 create..."
                curl -s -H 'Content-Type: application/json' -X POST -d "$(cat ~/test2.json)" http://172.17.0.1:2375/containers/create?name=test2 > /dev/null
        fi

        if [ -n "$container_down" ]; then
                # start the container
                echo "test2 start..."
                curl -d "t=0" http://172.17.0.1:2375/containers/test2/start
        fi


        if [ $? -ne 0 ]; then
                echo "ERROR test2_handler"
                exit -1
        fi
}

while 'true'; do
       sleep 1800
#        sleep 3

        echo "test2 check..."
        test2_handler
        echo "OK"

       sleep 1800
#        sleep 3

        echo "test2 check..."
        test2_handler
        echo "OK"

        echo "test1 restart..."
        restart test1
        echo "OK"
done
