jar=$(ls -lt /opt/SWEAGLE/bin/core/core*.jar|head -n 1|awk -F' ' '{print $9}')
mysql_jar=$(ls -lt /opt/SWEAGLE/bin/core/mysql*.jar|head -n 1|awk -F' ' '{print $9}')

if [ -z "${mysql_jar}" ]; then
  echo "ERROR: Missing JDBC JAR library"
  exit 1
fi

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
# Add JDBC Driver and application.yaml to JAVA_OPTS
JAVA_OPTS="${JAVA_OPTS} -Dloader.path=${mysql_jar} -Dspring.config.location=/opt/SWEAGLE/bin/core/application.yml"

echo "### STARTING JAR ${jar} WITH JAVA OPTIONS: ${JAVA_OPTS}"
cd /opt/SWEAGLE/bin/core
java ${JAVA_OPTS} -jar $jar
