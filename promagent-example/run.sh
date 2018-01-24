#!/bin/bash

java -javaagent:./target/promagent.jar=port=9300 -jar ../legacy-java-application/target/legacy-java-application-0.0.1-SNAPSHOT.jar
