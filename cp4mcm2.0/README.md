# Description

This script prompts for inputs to install an OCP cluster if necessary on the IBM Cloud.  It waits for the cluster to provision and then it installs the Multi Cloud Management Cloud Pak version 2.0

# Files

install.sh: runs through installation

resources.yaml: contains the yaml necessary to create the CatalogSource resources for MCM

installation.yaml: contains yaml to create the installation

Note, the `ibmc-block-retain-gold` storage class is used.  If you want to use a different storage class, change it in the installation.yaml file.

# Running from Cloud Shell on IBM Cloud

Launch a cloud shell by clicking on the terminal icon a the top right area onced you have logged into IBM Cloud.

Clone this directory using https:

`https://github.com/ibm-pett/cloud-pak-sandboxes.git`

# Script Instructions

```
cd cd cloud-pak-sandboxes/cp4mcm2.0
chmod +x install.sh
./install.sh
```

# Details
- User is prompted for entitlement key, email, and to provide existing OCP Cluster or create one
- If creating 

  - user is prompted for cluster name, flavor, number of nodes, zone, private vlan and public vlan details
  - User is prompted to locate their entitlement key and their docker email address to be used to connect to the docker registry
  - Cluster is provisioned
  
- When cluster is complete, operator resources are installed and invoked to install MCM 2.0
