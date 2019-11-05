
# format of the ouput yaml or json are supported
if [ "$#" -lt "1" ]; then
  echo "### No target directory defined, will use . as default"
  TARGET_DIR="."
else
  TARGET_DIR=$1
  if [ ! -d "$TARGET_DIR" ]; then
    echo "### ERROR: ($1) is not a directory !"
    exit 1
  fi
fi
if [ "$#" -lt "2" ]; then
  echo "### No format defined, will use json as default"
  FORMAT="json"
else
  FORMAT=$2
fi
if [ "$#" -lt "3" ]; then
  echo "### No namespace defined, will use all as default"
else
  NAMESPACE=$3
fi
K8S_CONFIG=("deployments" "services" "secrets")

for CONFIG in "${K8S_CONFIG[@]}"
do
  if [ -z ${NAMESPACE} ]; then
    DEP_LIST=$(kubectl get $CONFIG --all-namespaces)
  else
    DEP_LIST=$(kubectl get $CONFIG --namespace=$NAMESPACE)
  fi
  #For debug
  #echo "$DEP_LIST"
  LINE_NB=1
  while IFS= read -r LINE;
  do
    # don't do anything on first line as it is header
    # extract deployment and service configuration for other lines
    if [[ $LINE_NB -gt 1 ]]; then
      read -r -a array <<< "$LINE"
      #For debug
      #echo "kubectl get $CONFIG ${array[1]} --namespace=${array[0]} -o=$FORMAT > $TARGET_DIR/${array[1]}-$CONFIG.$FORMAT"
      if [ -z ${NAMESPACE} ]; then
        kubectl get $CONFIG ${array[1]} --namespace=${array[0]} -o=$FORMAT > $TARGET_DIR/${array[1]}-$CONFIG.$FORMAT
      else
        kubectl get $CONFIG ${array[0]} --namespace=${NAMESPACE} -o=$FORMAT > $TARGET_DIR/${array[0]}-$CONFIG.$FORMAT
      fi
    fi
    LINE_NB=$(( $LINE_NB + 1 ))
  done < <(printf '%s\n' "$DEP_LIST")
done

#kubectl get deployment k8s-nginx-ingress-controller --namespace=webportal1-k8s -o=yaml > deployment.yaml
