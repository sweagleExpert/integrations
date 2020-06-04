#!/bin/bash
echo "########################################################"
echo "#####    YOU ARE ENTERING SWEAGLE CLI CONTAINER    #####"
echo "########################################################"

if [[ -n ${ENV} ]]; then sweagle options --newenv "${ENV}" > /dev/null; fi
if [[ -n ${USERNAME} ]]; then sweagle options --newusername "${USERNAME}" > /dev/null; fi
if [[ -n ${TOKEN} ]]; then sweagle options --newtoken "${TOKEN}" > /dev/null; fi
if [[ -n ${PROVY_HOST} ]]; then sweagle options --host "${PROVY_HOST}" > /dev/null; fi
if [[ -n ${PROXY_PORT} ]]; then sweagle options --port "${PROXY_PORT}" > /dev/null; fi
if [[ -n ${PROXY_USER} ]]; then sweagle options --proxyName "${PROXY_USER}" > /dev/null; fi
if [[ -n ${PROXY_PASSWORD} ]]; then sweagle options --proxyKey "${PROXY_PASSWORD}" > /dev/null; fi
if [[ -n ${IGNORE_SSL} ]]; then sweagle settings --ignoreSSL > /dev/null; fi

/bin/bash
