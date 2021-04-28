# Configure the Azure Provider
provider "azurerm" {
  subscription_id = var.azure_subscription_id
  tenant_id       = var.azure_tenant_id
  features{}
}

# Configure RKE provider
provider "rke" {
  log_file = "rke_debug.log"
}

# Create a Resource Group
resource "azurerm_resource_group" "k8s-rsc-grp" {
    name     = "k8s-rsc-grp"
    location = var.azure_region
}

# Create a vnet
resource "azurerm_virtual_network" "k8s-vnet" {
    name                = "k8s-vnet"
    address_space       = ["10.0.0.0/16"]
    location            = var.azure_region
    resource_group_name = azurerm_resource_group.k8s-rsc-grp.name
}

# Create a subnet
resource "azurerm_subnet" "k8s-subnet" {
    name                 = "k8s-subnet"
    resource_group_name  = azurerm_resource_group.k8s-rsc-grp.name
    virtual_network_name = azurerm_virtual_network.k8s-vnet.name
    address_prefixes     = ["10.0.1.0/24"]
}

# Create a public IPs
resource "azurerm_public_ip" "k8s-public-ip-controlplane" {
    name                         = "k8s-public-ip-controlplane"
    location                     = var.azure_region
    resource_group_name          = azurerm_resource_group.k8s-rsc-grp.name
    allocation_method            = "Dynamic"
    domain_name_label            = "k8s-controlplane"
}
resource "azurerm_public_ip" "k8s-public-ip-worker1" {
    name                         = "k8s-public-ip-worker1"
    location                     = var.azure_region
    resource_group_name          = azurerm_resource_group.k8s-rsc-grp.name
    allocation_method            = "Dynamic"
    domain_name_label            = "k8s-worker1"
}

# Setting the Network Security Groups for Sweagle
resource "azurerm_network_security_group" "k8s-nsg" {
    name                = "k8s-nsg"
    location            = var.azure_region
    resource_group_name = azurerm_resource_group.k8s-rsc-grp.name

    security_rule {
        name                       = "ssh"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "Internet"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "http"
        priority                   = 200
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "Internet"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "https"
        priority                   = 300
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "Internet"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "controlplane"
        priority                   = 400
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "6443"
        source_address_prefix      = "Internet"
        destination_address_prefix = "*"
    }
}

# Create the network interfaces
resource "azurerm_network_interface" "k8s-nic-controlplane" {
    name                        = "k8s-nic-controlplane"
    location                    = var.azure_region
    resource_group_name         = azurerm_resource_group.k8s-rsc-grp.name

    ip_configuration {
        name                          = "k8s-nic-controlplane"
        subnet_id                     = azurerm_subnet.k8s-subnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.k8s-public-ip-controlplane.id
    }
}
resource "azurerm_network_interface" "k8s-nic-worker1" {
    name                        = "k8s-nic-worker1"
    location                    = var.azure_region
    resource_group_name         = azurerm_resource_group.k8s-rsc-grp.name

    ip_configuration {
        name                          = "k8s-nic-worker1"
        subnet_id                     = azurerm_subnet.k8s-subnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.k8s-public-ip-worker1.id
    }
}

# Connect the security group to the networks interfaces
resource "azurerm_network_interface_security_group_association" "k8s-nic-controlplane-nsg" {
    network_interface_id      = azurerm_network_interface.k8s-nic-controlplane.id
    network_security_group_id = azurerm_network_security_group.k8s-nsg.id
}
resource "azurerm_network_interface_security_group_association" "k8s-nic-worker1-nsg" {
    network_interface_id      = azurerm_network_interface.k8s-nic-worker1.id
    network_security_group_id = azurerm_network_security_group.k8s-nsg.id
}
resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = azurerm_resource_group.k8s-rsc-grp.name
    }

    byte_length = 8
}

# Creating the Cloud config file at startup
data "local_file" "cloud-config" {
    filename = "${path.module}/files/cloud-config.yaml"
}

resource "azurerm_storage_account" "k8s-storageaccount" {
    name                        = "diag${random_id.randomId.hex}"
    resource_group_name         = azurerm_resource_group.k8s-rsc-grp.name
    location                    = var.azure_region
    account_replication_type    = "LRS"
    account_tier                = "Standard"
}

# Provisioning the Master
resource "azurerm_linux_virtual_machine" "k8s-controlplane" {
    name                  = "k8s-controlplane"
    location              = var.azure_region
    resource_group_name   = azurerm_resource_group.k8s-rsc-grp.name
    network_interface_ids = [azurerm_network_interface.k8s-nic-controlplane.id]
    size                  = var.azure_instance_type
    custom_data           = data.local_file.cloud-config.content_base64

    os_disk {
        name              = "k8s-controlplane-disk"
        caching           = "ReadWrite"
        storage_account_type = var.azure_storage_type
    }

    source_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }

    computer_name  = "controlplane"
    admin_username = "azureuser"
    admin_password = var.azure_admin_password
    disable_password_authentication = false

    boot_diagnostics {
        storage_account_uri = azurerm_storage_account.k8s-storageaccount.primary_blob_endpoint
    }

    # Waiting for Docker components up and running 
    provisioner "remote-exec" {
      inline = [
        # Wait until Docker is installed.
        "until [ `sudo systemctl is-active docker` = 'active' ]; do echo docker not yet ready; sleep 1; done",
        # Enable the remote API for dockerd
        "sudo sed \"s/^ExecStart=\\/usr\\/bin\\/dockerd\\ -H unix:\\/\\//ExecStart=\\/usr\\/bin\\/dockerd\\ -H unix:\\/\\/\\ -H tcp:\\/\\/0.0.0.0:2376/g\" /lib/systemd/system/docker.service > docker.service",
        "sudo cp docker.service /lib/systemd/system/docker.service",
        "sudo systemctl daemon-reload",
        "sudo systemctl restart docker"
      ]
    }
    connection {
      type  = "ssh"
      host  = azurerm_public_ip.k8s-public-ip-controlplane.fqdn
      user  = "azureuser"
      password = var.azure_admin_password
      private_key = file(var.azure_ssh_key_local_path)
      timeout = "3m"
      agent = false
    }
}
resource "azurerm_linux_virtual_machine" "k8s-worker1" {
    name                  = "k8s-worker1"
    location              = var.azure_region
    resource_group_name   = azurerm_resource_group.k8s-rsc-grp.name
    network_interface_ids = [azurerm_network_interface.k8s-nic-worker1.id]
    size                  = var.azure_instance_type
    custom_data           = data.local_file.cloud-config.content_base64

    os_disk {
        name              = "k8s-worker1-disk"
        caching           = "ReadWrite"
        storage_account_type = var.azure_storage_type
    }

    source_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }

    computer_name  = "worker"
    admin_username = "azureuser"
    admin_password = var.azure_admin_password
    disable_password_authentication = false

    boot_diagnostics {
        storage_account_uri = azurerm_storage_account.k8s-storageaccount.primary_blob_endpoint
    }

    # Waiting for Docker components up and running 
    provisioner "remote-exec" {
      inline = [
        # Wait until Docker is installed.
        "until [ `sudo systemctl is-active docker` = 'active' ]; do echo docker not yet ready; sleep 1; done"
      ]
    }
    connection {
      type  = "ssh"
      host  = azurerm_public_ip.k8s-public-ip-worker1.fqdn
      user  = "azureuser"
      password = var.azure_admin_password
      private_key = file(var.azure_ssh_key_local_path)
      timeout = "3m"
      agent = false
    }
}

# Create the Kubernetes cluster
resource "rke_cluster" "cluster" {
  nodes {
    address = azurerm_public_ip.k8s-public-ip-controlplane.ip_address
    internal_address = azurerm_linux_virtual_machine.k8s-controlplane.private_ip_address
    user    = "azureuser"
    role    = ["controlplane", "etcd"]
    ssh_key = file("~/.ssh/id_rsa")
    hostname_override = "master"
  }
  nodes {
    address = azurerm_public_ip.k8s-public-ip-worker1.ip_address
    internal_address = azurerm_linux_virtual_machine.k8s-worker1.private_ip_address
    user    = "azureuser"
    role    = ["worker"]
    ssh_key = file("~/.ssh/id_rsa")
    hostname_override = "worker1"
  }
}

resource "local_file" "kube_cluster_yaml" {
   filename = "${path.root}/kube_config_cluster.yml"
   content  = rke_cluster.cluster.kube_config_yaml
}
