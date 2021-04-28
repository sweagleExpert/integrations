# Create your Kubernetes cluster with Rancher Kubernetes Engine on Azure

## Objective

1. Provision 2 nodes: first node for the controlplane and etcd. The seconde one as a worker.
2. Create a Kubernetes cluster with RKE


## Prerequisites

- Install Terraform 0.13 or later
- Install manually the Provider RKE  if you face any error during `terraform init`. 
Instructions: https://github.com/rancher/terraform-provider-rke#installing-the-provider
`````
$ curl -L https://github.com/rancher/terraform-provider-rke/releases/download/vX.Y.Z/terraform-provider-rke_X.Y.Z_<OS>_<ARCH>.zip | unzip -
$ chmod 755 terraform-provider-rke_vX.Y.Z
$ mv terraform-provider-rke_vX.Y.Z ~/.terraform.d/plugins/registry.terraform.io/hashicorp/rke/<X.Y.Z>/<OS>_<ARCH>
`````
 

## Instructions

1. Complete the list of variables in *./variables.tf* file:
2. Deploy the infrastructure by executing the commands: `terraform init`, `terraform plan`, `terraform apply` and `terraform destroy`.
    ```console
    $ terraform init
    $ terraform plan
    $ terraform apply
    ```

## Sources links

- Terraform Provider for RKE: [**https://github.com/rancher/terraform-provider-rke**](https://github.com/rancher/terraform-provider-rke)

