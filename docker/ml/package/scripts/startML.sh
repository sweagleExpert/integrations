#!/bin/bash
jar=$(ls -lt /opt/SWEAGLE/bin/ml/ml*.jar|head -n 1|awk -F' ' '{print $9}')

if [[ -z ${JAVA_OPTS} ]]; then
  # If no JAVA_OPTS defined, we use the old mode with Xms and Xmx
  if [[ -z ${Xms} && -z ${Xmx} ]]; then
    Xms=512m
    Xmx=512m
  elif [[ -z ${Xms} || -z ${Xmx} ]]; then
    if [[ -z ${Xms} ]]; then
      Xms=${Xmx}
    else
      Xmx=${Xms}
    fi
  fi
  JAVA_OPTS="-Xms${Xms} -Xmx${Xmx}"
fi

echo "### STARTING JAR ${jar} WITH JAVA OPTIONS: ${JAVA_OPTS}"
cd /opt/SWEAGLE/bin/ml
java ${JAVA_OPTS} -jar $jar
