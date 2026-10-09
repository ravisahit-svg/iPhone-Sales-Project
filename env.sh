export JAVA_HOME=/home/takeo/jsdk
export HADOOP_HOME=/home/takeo/hadoop
export HADOOP_CONF_DIR=/home/takeo/hadoop/etc/hadoop
export HIVE_HOME=/home/takeo/hive
export SPARK_HOME=/home/takeo/spark
export PATH=$HIVE_HOME/bin:$SPARK_HOME/bin:$HADOOP_HOME/bin:$JAVA_HOME/bin:$PATH
export HADOOP_CLIENT_OPTS="${HADOOP_CLIENT_OPTS:-} -Djdk.lang.Process.launchMechanism=FORK"
