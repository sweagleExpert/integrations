
# format of the ouput yaml or json are supported
FORMAT=$1
TARGET_DIR="."
K8S_CONFIG=("deployments" "services")

for CONFIG in "${K8S_CONFIG[@]}"
do
  #DEP_LIST=$(<"./kube-$CONFIG.txt")
  DEP_LIST=$(kubectl get $CONFIG --all-namespaces)
  #echo "$DEP_LIST"
  LINE_NB=1
  while IFS= read -r LINE;
  do
    # don't do anything on first line
    # extract deployment and service configuration for other lines
    if [[ $LINE_NB -gt 1 ]];
    then
      read -r -a array <<< "$LINE"
      #echo "kubectl get $CONFIG ${array[1]} --namespace=${array[0]} -o=$FORMAT > $TARGET_DIR/${array[1]}-$CONFIG.$FORMAT"
      kubectl get $CONFIG ${array[1]} --namespace=${array[0]} -o=$FORMAT > $TARGET_DIR/${array[1]}-$CONFIG.$FORMAT
    fi
    LINE_NB=$(( $LINE_NB + 1 ))
  done < <(printf '%s\n' "$DEP_LIST")
done




#kubectl get deployment k8s-nginx-ingress-controller --namespace=webportal1-k8s -o=yaml > deployment.yaml
