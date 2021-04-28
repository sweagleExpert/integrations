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

## Use the Helm plugin 

- Install the Sweagle plugin and list them
````
$ helm plugin install https://github.com/sweagleExpert/integrations/helm/plugins/sweagle
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


## Sources
- Helm: https://helm.sh/docs/
- Helm plugin: https://helm.sh/docs/topics/plugins/
