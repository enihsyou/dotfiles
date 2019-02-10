APACHE_HOME=~/Apache
export HADOOP_HOME=$APACHE_HOME/hadoop
export HIVE_HOME=$APACHE_HOME/hive
export HBASE_HOME=$APACHE_HOME/hbase
export KAFKA_HOME=$APACHE_HOME/kafka
export FLUME_HOME=$APACHE_HOME/flume
export SPARK_HOME=$APACHE_HOME/spark
export SQOOP_HOME=$APACHE_HOME/sqoop
export ZOOKEEPER_HOME=$APACHE_HOME/zookeeper

export HADOOP_CONF_DIR=$APACHE_HOME/conf

# 注意，有些设置会因为是通过SSH执行而导致在slaves中无法体现，应在hadoop-env.sh中设置
BASE_LOG_DIR=/Volumes/RAM/Temp/logs/Apache
export HADOOP_LOG_DIR=$BASE_LOG_DIR/hadoop
export YARN_LOG_DIR=$BASE_LOG_DIR/yarn
export HBASE_LOG_DIR=$BASE_LOG_DIR/hbase
export SPARK_LOG_DIR=$BASE_LOG_DIR/spark

export PATH=$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$HIVE_HOME/bin:$HBASE_HOME/bin:$KAFKA_HOME/bin:$FLUME_HOME/bin:$SPARK_HOME/bin:$SQOOP_HOME/bin:$ZOOKEEPER_HOME/bin:$PATH

export HADOOP_HEAPSIZE=150
export YARN_HEAPSIZE=150