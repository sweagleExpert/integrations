
# format of the ouput yaml or json are supported
if [ "$#" -lt "1" ]; then
  echo "### No format defined, will use json as default"
  FORMAT="json"
else
  FORMAT=$1
fi
TARGET_DIR="."
K8S_CONFIG=("deployments" "services")

for CONFIG in "${K8S_CONFIG[@]}"
do
  DEP_LIST=$(kubectl get $CONFIG --all-namespaces)
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
      kubectl get $CONFIG ${array[1]} --namespace=${array[0]} -o=$FORMAT > $TARGET_DIR/${array[1]}-$CONFIG.$FORMAT
    fi
    LINE_NB=$(( $LINE_NB + 1 ))
  done < <(printf '%s\n' "$DEP_LIST")
done

#kubectl get deployment k8s-nginx-ingress-controller --namespace=webportal1-k8s -o=yaml > deployment.yaml
