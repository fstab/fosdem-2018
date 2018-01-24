#!/bin/bash

LEGACY_JAVA_APPLICATION=$(find $HOME/demo -name legacy-java-application-0.0.1-SNAPSHOT.jar)
JMX_EXPORTER_AGENT_JAR=$(find $HOME/tools -name jmx_prometheus_javaagent-0.2.1-SNAPSHOT.jar)

java \
    -javaagent:${JMX_EXPORTER_AGENT_JAR}=1234:$HOME/demo/jmx-exporter/tomcat.yml \
    -Dcom.sun.management.jmxremote=true \
    -Dcom.sun.management.jmxremote.port=9999 \
    -Dcom.sun.management.jmxremote.rmi.port=9999 \
    -Dcom.sun.management.jmxremote.authenticate=false \
    -Dcom.sun.management.jmxremote.ssl=false \
    -Dcom.sun.management.jmxremote.local.only=false \
    -Djava.rmi.server.hostname=localhost \
    -jar ${LEGACY_JAVA_APPLICATION}
