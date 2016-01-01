#!/bin/sh

# Amount of space before.
echo "BEFORE STATS"
hdfs dfs -du -h /apps/hbase
hdfs dfs -du -h /tmp | grep phoenix

# Do the load.
yarn jar /usr/hdp/current/phoenix-client/phoenix-client.jar \
        org.apache.phoenix.mapreduce.CsvBulkLoadTool \
        -Dmapreduce.reduce.memory.mb=2048 \
        -Dmapred.reduce.child.java.opts=-Xmx1800m \
        --table bulkload_test \
        --input /tmp/phoenix_data \
        -d '|' &
child_pid=$!

not_dead=0
while [ $not_dead -eq 0 ]; do
	sleep 5
	sudo du -hs /var/lib/hadoop/yarn/node/usercache/hbase/appcache
	kill -0 $child_pid
	not_dead=$?
done

# Amount of HDFS space after.
echo "AFTER STATS"
hdfs dfs -du -h /apps/hbase
