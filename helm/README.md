# SWEAGLE INTEGRATION TO HELM

## DESCRIPTION

This folder provides an example of configuration to include SWEAGLE into a Helm.
SWEAGLE will become the configuration data provider for Helm while  deploying your cloud-native application to your Kubernetes cluster.

## PRE-REQUISITES
### A Kubernetes cluster

- You must have a Kubernetes (K8S) cluster. If you do not have it please follow the instructions to build your [K8S cluster with RKE](./k8s-rke/README.md).
- You should also have a local configured copy of `kubectl`.

### Install and configure Helm
- Connect to the master node and install Helm :
````
$ curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
$ chmod 700 get_helm.sh
$ ./get_helm.sh
````
- Initialize the Bitnami Chart Repository and list the charts
````
$ helm repo add bitnami https://charts.bitnami.com/bitnami
$ helm search repo stable
````
- Install Wordpress and list Kubernetes resources created. Then uninstall the application.
````
$ helm install bitnami/wordpress --generate-name
$ helm ls
$ kubectl get all
$ helm uninstall <app-name>
````

## Generate your first chart

- Create a freash chart
````
$ helm create mywebserver
````
- Once validated,   package the chart up for distribution
````
$ helm lint
$ helm package mywebserver
Successfully packaged chart and saved it to: /PATH/TO/CHART/helm/mywebserver-0.1.0.tgz
````
- Then install it!
````
$ helm install mywebserver ./mywebserver-0.1.0.tgz
$ helm status mywebserver
$ helm uninstall mywebserver
````
- Create a Chart Repository in GitHub
Follow the steps detailed here: https://helm.sh/docs/topics/chart_repository/#github-pages-example
- Push your chart to your GitHub Chart Repository. Upload the `ìndex.yaml` and `*.tgz` files to `docs` folder under your GitHub chart repo.
````
mkdir docs
$ mv mywebserver-0.1.0.tgz docs
$ helm repo index docs --url https://cyr-riv.github.io/charts
````



## Use the Helm plugin 

- Install the Sweagle plugin and list them
````
$ helm plugin install plugins/sweagle
$ helm plugin list
````
- Check the environment variables of Helm, especially the variable `HELM_PLUGINS` (the path to the plugins directory).
`````
$ helm env | grep PLUGIN
HELM_PLUGINS="~/Documents/Sweagle/cyri_dev/git/sweagleExpert/integrations/helm/plugins"
`````
- Use the Sweagle plugin. Update the file `sweagle.env` with your tenant URL and TokenId.
`````
$ helm sweagle helm-charts ReturnData4Node args=mywebserver format=YAML output=PATH/TO/values.yaml
`````

## Flux Helm Operator
The Helm Operator is a Kubernetes operator, allowing one to declaratively manage Helm chart releases. Combined with FluxCD this can be utilized to automate releases in a GitOps manner.
### Install the Helm Operator
- Install the HelmRelease CRD (Custom Resource Definition)
`````
kubectl apply -f https://raw.githubusercontent.com/fluxcd/helm-operator/1.2.0/deploy/crds.yaml
`````
- Create a new namespace
`````
kubectl create ns flux
`````
- Using helm, first add the Flux CD Helm repository
````
helm repo add fluxcd https://charts.fluxcd.io
````
- Install the Helm Operator
`````
helm upgrade -i helm-operator fluxcd/helm-operator \
    --namespace flux \
    --set helm.versions=v3
`````
### Create your first HelmRelease
- Install a Helm chart using the Helm Operator, create a HelmRelease resource on the cluster.
````
kubectl apply -f flux-helm-operator/mywebserver-deploy.yaml
````
- Confirm the chart has been installed
````
$ flux-helm-operator % kubectl describe helmrelease mywebserver
Name:         podinfo
Namespace:    default
Labels:       <none>
Annotations:  <none>
API Version:  helm.fluxcd.io/v1
Kind:         HelmRelease

$ flux-helm-operator % kubectl get pods
NAME                                      READY   STATUS    RESTARTS   AGE
default-nginx-5f55f67c9b-2htwz            1/1     Running   0          6m16s
````
- Check that Nginx is and running from the controlplane node directly
````
curl http://localhost:32583
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
````

## Sources
- Helm: https://helm.sh/docs/
- Helm plugin: https://helm.sh/docs/topics/plugins/
- Flux Helm Operator: https://docs.fluxcd.io/projects/helm-operator/en/stable/
- Create a Chart Repository on GitHub: https://helm.sh/docs/topics/chart_repository/#github-pages-example
