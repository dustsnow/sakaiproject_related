#!/bin/bash
sudo ./cassandra/bin/cassandra -f > /tmp/cassandra.log 2>&1 &
sudo ./redis/src/redis-server > /tmp/redis-server.log 2>&1 &  
sudo ./elasticsearch/bin/elasticsearch > /tmp/elasticsearch.log 2>&1 & 
sudo rabbitmq-server -detached > /tmp/rabbitmq.log 2>&1 & 
sleep 20
cd ./Hilary
sudo node app.js | node_modules/.bin/bunyan



