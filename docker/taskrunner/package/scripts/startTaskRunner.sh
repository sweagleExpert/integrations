#!/bin/sh
echo "###############################################################"
echo "### BEGIN SWEAGLE TASKRUNNER START SCRIPT V1"
echo "###############################################################"

##########################################################
#                    MAIN
##########################################################
jar=$(ls -lt /opt/SWEAGLE/bin/taskRunner/task*.jar|head -n 1|awk -F' ' '{print $9}')
yaml="/opt/SWEAGLE/bin/taskRunner/application.yml"

echo "### VALIDATE INPUTS PROVIDED"

if [[ -z ${SWEAGLE_CORE} ]]; then
  echo " No SWEAGLE CORE host provided, using default"
  export SWEAGLE_CORE="sweagle-core"
fi

if [[ -z ${SWEAGLE_TOKEN} ]]; then
  echo " No SWEAGLE TOKEN provided, using default"
  export SWEAGLE_TOKEN="XXX"
fi

if [[ -z ${SWEAGLE_USER} ]]; then
  echo " No SWEAGLE USER provided, using default"
  export SWEAGLE_USER="taskrunner_user"
fi

if [[ -z ${SWEAGLE_PASSWORD} ]]; then
  echo " No SWEAGLE PASSWORD provided, using default"
  export SWEAGLE_PASSWORD="taskrunner_password"
fi

echo "### REPLACING VALUES IN application.yml"
sed -E -i "s/http:\/\/.+:8081/http:\/\/${SWEAGLE_CORE}:8081/" "${yaml}"
sed -E -i "s/token: .+/token: ${SWEAGLE_TOKEN}/" "${yaml}"
sed -E -i "s/username: .+/username: ${SWEAGLE_USER}/" "${yaml}"
sed -E -i "s/password: .+/password: ${SWEAGLE_PASSWORD}/" "${yaml}"
#eval "echo \"$(cat /opt/SWEAGLE/bin/taskRunner/applicationYaml.template)\"" > "${yaml}"

echo "### STARTING JAR ${jar} WITH JAVA OPTIONS: ${JAVA_OPTS}"
cd /opt/SWEAGLE/bin/taskRunner
java ${JAVA_OPTS} -jar $jar
