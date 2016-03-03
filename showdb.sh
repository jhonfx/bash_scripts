#!/bin/bash
while true;do echo .;sleep 1;done &
sleep 1 # or do something else here
kill $!; trap 'kill $!' SIGTERM

#echo "$(mysql -u root -Bse '\n show databases')"
	#mysql -u root -e "drop database venezuelai"
	mysql -u root -e "create database venezuelai"
	mysql venezuelai < venezuelai.sql -u root
echo done

#echo "$(mysql -u root -p -Bse 'create database foo')"