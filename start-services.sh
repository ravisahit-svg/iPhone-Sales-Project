#!/usr/bin/env bash
set -e
source /home/takeo/ravi-iphone-project/env.sh
if ! jps | grep -q ' NameNode'; then hdfs --daemon start namenode; fi
if ! jps | grep -q ' DataNode'; then hdfs --daemon start datanode; fi
if ! pgrep -f 'org.apache.hadoop.hive.metastore.HiveMetaStore' >/dev/null; then
  nohup hive --service metastore > /home/takeo/ravi-iphone-project/logs/metastore.log 2>&1 < /dev/null &
fi
if ! pgrep -f 'hive.server2.thrift.port=10004' >/dev/null; then
  HADOOP_HEAPSIZE=2048 nohup hive --service hiveserver2 --hiveconf hive.server2.thrift.port=10004 --hiveconf hive.server2.webui.port=10005 --hiveconf hive.server2.enable.doAs=false --hiveconf hive.notification.event.poll.interval=0ms --hiveconf mapreduce.framework.name=local --hiveconf mapreduce.task.io.sort.mb=16 --hiveconf hive.exec.mode.local.auto=true --hiveconf hive.fetch.task.conversion=more > /home/takeo/ravi-iphone-project/logs/hiveserver2.log 2>&1 < /dev/null &
fi
echo 'Ravi project services requested in the existing takeo account'
