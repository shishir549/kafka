#!/bin/bash
   updateConfig() {
        key=$1
        value=$2
        file=$3

        # Omit $value here, in case there is sensitive information
        echo "[Configuring] '$key' in '$file'"

        # If config exists in file, replace it. Otherwise, append to file.
        if grep -E -q "^#?$key=" "$file"; then
            sed -r -i "s@^#?$key=.*@$key=$value@g" "$file" #note that no config values may contain an '@' char
        else
            echo "$key=$value" >> "$file"
        fi
    }

    EXCLUSIONS="|KAFKA_VERSION|KAFKA_HOME|KAFKA_DEBUG|KAFKA_GC_LOG_OPTS|KAFKA_HEAP_OPTS|KAFKA_JMX_OPTS|KAFKA_JVM_PERFORMANCE_OPTS|KAFKA_LOG|KAFKA_OPTS|"

    # Read in env as a new-line separated array. This handles the case of env variables have spaces and/or carriage returns. See #313
    IFS=$'\n'
    for VAR in $(env)
    do
        env_var=$(echo "$VAR" | cut -d= -f1)
        if [[ "$EXCLUSIONS" = *"|$env_var|"* ]]; then
            echo "Excluding $env_var from broker config"
            continue
        fi

        if [[ $env_var =~ ^KAFKA_ ]]; then
            kafka_name=$(echo "$env_var" | cut -d_ -f2- | tr '[:upper:]' '[:lower:]' | tr _ .)
            updateConfig "$kafka_name" "${!env_var}" "$KAFKA_HOME/config/server.properties"
        fi

        if [[ $env_var =~ ^LOG4J_ ]]; then
            log4j_name=$(echo "$env_var" | tr '[:upper:]' '[:lower:]' | tr _ .)
            updateConfig "$log4j_name" "${!env_var}" "$KAFKA_HOME/config/log4j.properties"
        fi
    done
# Start the ZooKeeper service
# Note: Soon, ZooKeeper will no longer be required by Apache Kafka.
  if [ $# -eq 0 ]
  then
    bin/zookeeper-server-start.sh config/zookeeper.properties &
    sleep 10
    bin/kafka-server-start.sh config/server.properties
  elif [ "$1" == "zookeeper" ]
  then
     bin/zookeeper-server-start.sh config/zookeeper.properties
# Wait for few seconds
     sleep 5
  else
# Start the Kafka broker service
     bin/kafka-server-start.sh config/server.properties
  fi
