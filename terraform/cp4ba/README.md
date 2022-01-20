Everything is automated with Makefiles. However, instructions to get the
same results manually are provided.

- [Creation of a Partner Sandbox](https://github.com/ibm-hcbt/cloud-pak-sandboxes/blob/master/terraform/cp4ba/README.md#creation-of-a-partner-sandbox)
  - [Requirements](https://github.com/ibm-hcbt/cloud-pak-sandboxes/blob/master/terraform/cp4ba/README.md#requirements)
  - [Configure Access to IBM Cloud](https://github.com/ibm-hcbt/cloud-pak-sandboxes/blob/master/terraform/cp4ba/README.md#configure-access-to-ibm-cloud)
    - [Create an IBM Cloud API Key](https://github.com/ibm-hcbt/cloud-pak-sandboxes/blob/master/terraform/cp4ba/README.md#create-an-ibm-cloud-api-key)
    - [Create an IBM Cloud Classic Infrastructure API Key](https://github.com/ibm-hcbt/cloud-pak-sandboxes/blob/master/terraform/cp4ba/README.md#create-an-ibm-cloud-classic-infrastructure-api-key)
    - [Create the credentials file](https://github.com/ibm-hcbt/cloud-pak-sandboxes/blob/master/terraform/cp4ba/README.md#create-the-credentials-file)
  - [Provisioning the Sandbox](https://github.com/ibm-hcbt/cloud-pak-sandboxes/blob/master/terraform/cp4ba/README.md#provisioning-the-sandbox)
  - [Design](https://github.com/ibm-hcbt/cloud-pak-sandboxes/blob/master/terraform/cp4ba/README.md#design)
    - [External Terraform Modules](https://github.com/ibm-hcbt/cloud-pak-sandboxes/blob/master/terraform/cp4ba/README.md#external-terraform-modules)

## Requirements

The development and testing of the sandbox setup code requires the following elements:

- Have an IBM Cloud account with required privileges
- [Install IBM Cloud CLI](https://ibm.github.io/cloud-enterprise-examples/iac/setup-environment#install-ibm-cloud-cli)
- [Install the IBM Cloud CLI Plugins](https://ibm.github.io/cloud-enterprise-examples/iac/setup-environment#ibm-cloud-cli-plugins) `schematics` and `kubernetes-service`.
- [Login to IBM Cloud with the CLI](https://ibm.github.io/cloud-enterprise-examples/iac/setup-environment#login-to-ibm-cloud)
- [Install Terraform](https://cloud.ibm.com/docs/ibm-cloud-provider-for-terraform?topic=ibm-cloud-provider-for-terraform-setup_cli#install-terraform) **version 0.13**
- [Install IBM Cloud Terraform Provider](https://ibm.github.io/cloud-enterprise-examples/iac/setup-environment#configure-access-to-ibm-cloud)
- [Configure Access to IBM Cloud](https://github.com/ibm-hcbt/cloud-pak-sandboxes/blob/master/terraform/cp4ba/README.md#configure-access-to-ibm-cloud)
- Install some utility tools such as:
  - [jq](https://stedolan.github.io/jq/download/) (optional)
  - [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
  - [oc](https://docs.openshift.com/container-platform/3.6/cli_reference/get_started_cli.html)

Execute these commands to validate some of these requirements:

```bash
ibmcloud --version
ibmcloud plugin show schematics | head -3
ibmcloud plugin show kubernetes-service | head -3
ibmcloud target
terraform version
ls ~/.terraform.d/plugins/terraform-provider-ibm_*
```

## Configure Access to IBM Cloud

Terraform requires the IBM Cloud credentials to access IBM Cloud. The credentials can be set using environment variables or - optionally and recommended - in your own `credentials.sh` file.

### Create an IBM Cloud API Key

Follow these instructions to setup the **IBM Cloud API Key**, for more information read [Creating an API key](https://cloud.ibm.com/docs/account?topic=account-userapikey#create_user_key).

In a terminal window, execute following commands replacing `<RESOURCE_GROUP_NAME>` with the resource group where you are planning to work and install everything:

```bash
ibmcloud login --sso
ibmcloud resource groups
ibmcloud target -g <RESOURCE_GROUP_NAME>
```

If you have an IBM Cloud API Key that is either not set or you don't have the JSON file when it was created, you must recreate the key. Delete the old one if it won't be in use anymore.

```bash
ibmcloud iam api-keys       # Identify your old API Key Name
ibmcloud iam api-key-delete NAME
```

Create new key

```bash
ibmcloud iam api-key-create TerraformKey -d "API Key for Terraform" --file ~/.ibm_api_key.json
export IC_API_KEY=$(grep '"apikey":' ~/.ibm_api_key.json | sed 's/.*: "\(.*\)".*/\1/')
```

### Create an IBM Cloud Classic Infrastructure API Key

Follow these instructions to get the **Username** and **API Key** to access **IBM Cloud Classic**, for more information read [Managing classic infrastructure API keys](https://cloud.ibm.com/docs/account?topic=account-classic_keys).

1. At the IBM Cloud web console, go to **Manage** > **Access (IAM)** > **API keys**, and select **Classic infrastructure API keys** in the dropdown menu.
2. Click Create a classic infrastructure key. If you don't see this option, check to see if you already have a classic infrastructure API key that is created because you're only allowed to have one in the account per user.
3. Go to the actions menu (3 vertical dots) to select **Details**, then **Copy** the API Key.
4. Go to **Manage** > **Access (IAM)** > **Users**, then search and click on your user's name. Select **Details** at the right top corner to copy the **User ID** from the users info (it may be your email address).

### Create the credentials file

In the terminal window, export the following environment variables to let the IBM Provider to retrieve the credentials.

```bash
export IAAS_CLASSIC_USERNAME="< Your IBM Cloud Username/Email here >"
export IAAS_CLASSIC_API_KEY="< Your IBM Cloud Classic API Key here >"
export IC_API_KEY="< IBM Cloud API Key >"
```

So as to not have to define them for every new terminal, you can create the file `credentials.sh` containing the above credentials.

Execute the file like so:

```bash
source credentials.sh
```

Additionally, you can append the above `export` commands in your shell profile or config file (i.e. `~/.bashrc` or `~/.zshrc`) and they will be executed on every new terminal.

**IMPORTANT**: If you use a different filename than `credentials.sh` make sure to not commit the file to GitHub. The filename `credentials.sh` is in the `.gitignore` file so it is safe to use it..

## Provisioning the Sandbox

To build the Sandbox with a selected Cloud Pak on IBM Cloud Classic the available methods are:

- **[Using Make](./Using_Make.md)**: With the use of `make` and the existing `Makefiles` it is possible to provision the Cloud Pak locally with Terraform, or remotely with Schematics. Make is the recommended way if this is your first time or to get things done quickly. Refer to [Using Make](./Using_Make.md) for instructions.
- **[Using Terraform](./Using_Terraform.md)**: The Makefile contains all the Terraform actions/commands to run, however you can execute them manually whenever you want, even after using `make` initially. This option allows you to customize the input parameters and offers more control of the process. Refer to [Using Terraform](./Using_Terraform.md) for instructions.
- **[Using Schematics](./Using_Schematics.md)**: The Makefile contains all the commands to provision a Cloud Pak using IBM Cloud Schematics, however you can do it manually using `ibmcloud` cli or the IBM Cloud Web Console to create and manage a Schematics workspace. Consider using `make` to - at least - create the workspace, it can save you some time. Refer to [Using Schematics](./Using_Schematics.md) for instructions.
- **[Using IBM Cloud CLI](./Using_IBMCloud_CLI.md)**: The existing Terraform code provisions an OpenShift cluster then installs the requested Cloud Pak on it. With the IBM Cloud CLI you cannot install a Cloud Pak but you can provision an OpenShift cluster to install the Cloud Pak on using any of the above methods. Instructions to provision an OpenShift cluster using the CLI are in the [Using IBM Cloud CLI](./Using_IBMCloud_CLI.md) document.
- **[Using a Private Catalog](./Using_Private_Catalog.md)**: (Deprecated) It's possible to have a Private Catalog as a user interface with the Schematics and Terraform code, however this option may be more complex than creating a Schematics workspace. This option is not supported anymore. Instructions to create a Private Catalog are in the [Using Private Catalog](./Using_Private_Catalog.md) document.

## Design

This directory contains the Terraform HCL code to execute/apply by Terraform either locally or by remotely, by IBM Cloud Schematics. The code to provision each specific Cloud Pak is located in a separate subdirectory. They each have almost the same design, input and output parameters and very similar basic validation.

Each Cloud Pak subdirectory contains the following files:

- `main.tf`: contains the code provision the Cloud Pak, you should start here to know what Terraform does. This uses two Terraform modules: the ROKS module and a Cloud Pak module. The ROKS module is used to provision an OpenShift cluster where the Cloud Pak will be installed. Then the Cloud Pak module is applied to install the Cloud Pak. To know more about these Terraform modules refer to the following section [Cloud Pak External Terraform Modules](https://github.com/ibm-hcbt/cloud-pak-sandboxes/blob/master/terraform/cp4ba/README.md#cloud-pak-external-terraform-modules).
- `variables.tf`: contains all the input parameters. The input parameters are explained below but you can get additional information about them in the README of each Cloud Pak directory.
- `outputs.tf`: contains all the output parameters. The output parameters are explained below but you can get additional information about them in the README of each Cloud Pak directory.
- `terraform.tfvars`: although the `variables.tf` defines the input variables and the default values, the `terraform.tfvars` also contains default values to access and modify. If you'd like to customize your resources try to modify the values in this file first.
- `workspace.tmpl.json`: this is a template file used by the `terraform/Schematics.mk` makefile to generate the `workspace.json` file which is used to create the IBM Cloud Schematics workspace. The template contains, among other data, the URL of the repository where the Terraform is located and the input parameters with default values. The generated JSON file contains the entitlement key. This file is not included in the repo and is ignored by GitHub (listed it in the `.gitignore` file).
- `Makefile`: most of the Makefile logic is located in the `terraform/` makefiles (`Makefile` and `*.mk` files) however some specific actions for the Cloud Pak are required, for example, the Cloud Pak validations. All these specific actions are in this `Makefile`.


# Terraform Modules to create a ROKS Cluster, install Db2 and Cloud Pak for Business Automation

If there is not an existing ROKS cluster, this Terraform modules will create a new ROKS Cluster, then install Db2 and Cloud Pak for Business Automation.

installs **Cloud Pak for Business Automation** on an Openshift (ROKS)
cluster on IBM Cloud.

**Module Source**: `git::https://github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//modules/cp4ba`

## Set up access to IBM Cloud

If running these modules from your local terminal, you need to set the credentials to access IBM Cloud.

Go [here](https://github.com/ibm-hcbt/cloud-pak-sandboxes/blob/master/terraform/CREDENTIALS.md) for details.

## Provisioning this module in a Terraform Script

In your Terraform version script (`versions.tf`), define `terraform`
block as follow:
```hcl
terraform {
  required_version = ">= 0.13"
  required_providers {
    ibm = {
      source  = "ibm-cloud/ibm"
      version = "1.34"
    }
    external = {
      source = "hashicorp/external"
    }
    null = {
      source = "hashicorp/null"
    }
  }
}
```

Then in the `main.tf` Terraform script, define the `ibm` provider block
as follow:
```hcl
provider "ibm" {
  region           = "us-south"
  ibmcloud_api_key = "*************************"
}
```

### Setting up the OpenShift cluster

NOTE: an OpenShift cluster is required to install the Cloud Pak. This can be an existing cluster or can be provisioned using our `roks` Terraform module.

To provision a new cluster, refer [here](https://github.com/ibm-hcbt/terraform-ibm-cloud-pak/tree/main/modules/roks#building-a-new-roks-cluster) for the code to add to your Terraform script. The recommended size for an OpenShift 4.7 cluster on IBM Cloud Classic contains `5` workers of flavor `b3c.16x64`, however read the [Cloud Pak for Business Automation documentation](https://www.ibm.com/docs/en/cloud-paks/cp-biz-automation) to confirm these parameters.

Add the following code to get the OpenShift cluster (new or existing) configuration:

```hcl
data "ibm_resource_group" "group" {
  name = var.resource_group
}

resource "null_resource" "mkdir_kubeconfig_dir" {
  triggers = { always_run = timestamp() }

  provisioner "local-exec" {
    command = "mkdir -p ./.kube/config"
  }
}

data "ibm_container_cluster_config" "cluster_config" {
  depends_on = [null_resource.mkdir_kubeconfig_dir]
  cluster_name_id   = var.cluster_name_id
  resource_group_id = data.ibm_resource_group.group.id
  config_dir        = "./.kube/config"
}
```
Input:

- `cluster_name_id`: either the cluster name or ID.

- `ibm_resource_group`:  resource group where the cluster is running

Output:

`ibm_container_cluster_config` used as input for the `cp4ba` module

### Using the CP4BA Module

Use a `module` block assigning the `source` parameter to the location of this module `git::https://github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//modules/cp4ba`. Then set the [input variables](https://github.com/ibm-hcbt/cloud-pak-sandboxes/blob/master/terraform/cp4ba/README.md#input-variables) required to install the Cloud Pak for Business Automation.

```hcl
module "cp4ba" {
  source = "../../modules/cp4ba"
  enable = true

  # ---- Cluster settings ----
  cluster_config_path = data.ibm_container_cluster_config.cluster_config.config_file_path
  ingress_subdomain = var.ingress_subdomain

  # ---- Cloud Pak settings ----
  cp4ba_project_name      = "cp4ba"
  entitled_registry_user  = var.entitled_registry_user
  entitlement_key         = var.entitlement_key

  # ----- DB2 Settings -----
  db2_host_name           = var.db2_host_name
  db2_host_port           = var.db2_host_port
  db2_admin               = var.db2_admin
  db2_user                = var.db2_user
  db2_password            = var.db2_password

  # ----- LDAP Settings -----
  ldap_admin              = var.ldap_admin
  ldap_password           = var.ldap_password
  ldap_host_ip            = var.ldap_host_ip
}
```

## Input Variables

| Name                               | Description                                                                                                                                                                                                                | Default                     | Required |
| ---------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------- | -------- |
| `enable`                           | If set to `false` does not install the cloud pak on the given cluster. By default it's enabled  | `true`                      | No       |
| `cluster_config_path`              | Path to the Kubernetes configuration file to access your cluster | `./.kube/config`                      | No       |
| `ingress_subdomain`                | Run the command `ibmcloud ks cluster get -c <cluster_name_or_id>` to get the Ingress Subdomain value |  | No       |
| `cp4ba_project_name`               | Namespace to install for Cloud Pak for Integration | `cp4ba`                      | No       |
| `entitled_registry_key`            | Get the entitlement key from https://myibm.ibm.com/products-services/containerlibrary and assign it to this variable. Optionally you can store the key in a file and use the `file()` function to get the file content/key |                             | Yes      |
| `entitled_registry_user_email`     | IBM Container Registry (ICR) username which is the email address of the owner of the Entitled Registry Key |  | Yes      |
| `ldap_admin`     | LDAP Admin user name | `cn=root`  | Yes      |
| `ldap_password`     | LDAP Admin password | `Passw0rd` | Yes      |
| `ldap_host_ip`     | LDAP server IP address |  | Yes      |
| `db2_host_name`     | Host for DB2 instance |  | Yes      |
| `db2_host_port`     | Port for DB2 instance |  | Yes      |
| `db2_admin`     | Admin user name defined in associated LDAP| `cpadmin` | Yes      |
| `db2_user`     | User name defined in associated LDAP | `db2inst1` | Yes      |
| `db2_password`     | Password defined in associated LDAP | `passw0rd` | Yes      |

For an example of how to put all this together, refer to our [Cloud Pak for Business Automation Terraform example](https://github.com/ibm-hcbt/cloud-pak-sandboxes/tree/master/terraform/cp4ba).

## Executing the Terraform Script

Execute the following commands to install the Cloud Pak:

```bash
terraform init
terraform plan
terraform apply
```


## Output Parameters

The Terraform code return the following output parameters.

| Name               | Description                                                                                                                         |
| ------------------ | ----------------------------------------------------------------------------------------------------------------------------------- |
| `cp4ba_endpoint`  | URL of the CP4BA dashboard                                                                                                         |
| `cp4ba_user`      | Username to login to the CP4BA dashboard                                                                                           |
| `cp4ba_password`  | Password to login to the CP4BA dashboard                                                                                           |

## Validation

### Namespace
```
kubectl get namespaces cp4ba
```
### All resources
```
kubectl get all --namespace cp4ba
```
### Get route
```
oc get route |grep "^cpd"
```

Using the following credentials:

```bash
terraform output cp4ba_user
terraform output cp4ba_password
```

Log into the
## Uninstall

To uninstall CP4BA and its dependencies from a cluster, execute the following commands:

```bash
kubectl get ICP4ACluster
kubectl get subscription ibm-common-service-operator -n openshift-operators
kubectl get subscription ibm-common-service-operator -n opencloud-operators
kubectl delete namespace cp4ba
```

## Clean up

When you finish using the cluster, release the resources by executing the following command:

```bash
terraform destroy
```

**Note**: The uninstall/cleanup process is a work in progress at this time, we are identifying the objects that need to be deleted in order to have a successful re-installation.

### External Terraform Modules

As mentioned above, the `main.tf` file in each subdirectory uses two Terraform modules: the ROKS and the Cloud Pak module. To know more about these modules refer to their [GitHub repository](https://github.com/ibm-hcbt/terraform-ibm-cloud-pak).

Note: All these modules will be registered in the Terraform Registry so they will be easy to access. This will be part of a future release that will include the Terraform 0.13/0.14 upgrade.
