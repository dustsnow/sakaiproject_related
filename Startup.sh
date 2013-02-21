#!/bin/bash
#Program:
#	This program runs the dependences of HIlary: 
#		cassandra 
#		redis 
#		elasticsearch
#		rabbitmq 
#
#Installtion:
# 	run this file as sudo user using bash command
#		sudo bash Startup.sh
#	This script will generate log file for every application in folder /tmp
#		/tmp/cassandra.log
#		/tmp/redis-server.log
#		/tmp/elasticsearch.log
#		/tmp/rabbitmq.log
#
#Author: 
#	Peng Hou

function startApp {
	case $1 in
		"cassandra")
			#echo $2"bin/cassandra -f"
			echo $2'bin/cassandra -f' | sudo -s  > /tmp/cassandra.log 2>&1 &
			;;
		"redis")
			#echo $2"src/redis-server"
			echo $2"src/redis-server" | sudo -s > /tmp/redis-server.log 2>&1 &  
			;;
		"elasticsearch")
			#echo $2"bin/elasticsearch"
			echo $2"bin/elasticsearch"| sudo -s > /tmp/elasticsearch.log 2>&1 & 
			;;
	esac
}
function getPath {
	echo "Please type in the path to $1 folder"
	echo "Example: ~/Documents/$1"
	read -p "Path: " appfolder
	if [ "$appfolder" == "" ]; then
		echo "No path input!? type in again"
		getPath $1
	fi
	if [  "${appfolder:0:1}" == "~" ]; then
	    appFolder=${appfolder/\~/$HOME}"/"
	fi
	folderCheck="FALSE" 
	case $1 in
		"cassandra")
			test -d $appFolder"bin/" && folderCheck="TRUE"
			;;
		"redis")
			test -d $appFolder"src/" && folderCheck="TRUE"
			;;
		"elasticsearch")
			test -d $appFolder"bin/" && folderCheck="TRUE"
			;;
	esac
	if [ "$folderCheck" == "TRUE" ]; then
		echo -e $1'\t'$appFolder >> ~/.config/HilaryConfig.conf
	else
		echo "Cannot find folder. $appFolder Wrong Path"
		getPath $1
	fi
}
function config {
	echo "Config the path to cassandra, redis, elasticsearch, rabbitmq"
	getPath cassandra
	getPath redis
	getPath elasticsearch
}

#Must Run as root user to avoid problem of password prompting
if [[ $EUID -ne 0 ]]; then
	echo "You must run this as a root user"
	exit 1
fi

#The Default folder storing the configuration file
configFolder=$HOME"/.config/HilaryConfig.conf"
#fileCheck indicate whether the configuration file exist
fileCheck="FALSE"
#test whether conf file exit, set fileCheck to true if exist
test -e $configFolder && fileCheck="TRUE"

#if conf file doesn't exist, go to configration
if [ "$fileCheck" == "FALSE" ]; then
	echo "The default config file '$configFolder' DO NOT EXIST"	
	config
else
	echo "The config file '$configFolder' EXIST"	
	echo "Read From $configFolder"
fi

#Read configuraions from conf file
#Get the name and path, start the application
while read line
do
	appName=`echo $line | awk '{print $1}'`
	appPath=`echo $line | awk '{print $2}'`
	startApp $appName $appPath
done < $configFolder

sudo rabbitmq-server -detached > /tmp/rabbitmq.log 2>&1 & 
##sleep 20
##cd ./Hilary
##sudo node app.js | node_modules/.bin/bunyan
#
