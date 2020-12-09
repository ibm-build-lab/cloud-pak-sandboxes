# Creation of a Cloud Pak Sandbox (for Developers)

This folder contains the Infrastructure as Code or Terraform code to create a **Sandbox** with an **Openshift** (ROKS) cluster on IBM Cloud Classic with a Cloud Pak. At this time the supported Cloud Paks are:

- Cloud Pak for Multi Cloud Management (CP4MCM)
- Cloud Pak for Applications (CP4A)
- Cloud Pak for Data (CP4D)

NOTE: that this documentation is **<u>only for developers or advanced users</u>**. 

Sandbox **users** please refer to [Installer Script](../installer/README.md) documentation.

Everything is automated with Makefiles. However, instructions to get the same results manually are provided.

- [Creation of a Cloud Pak Sandbox (for Developers)](#creation-of-a-cloud-pak-sandbox-for-developers)
  - [Requirements](#requirements)
  - [Configure Access to IBM Cloud](#configure-access-to-ibm-cloud)
    - [Create an IBM Cloud API Key](#create-an-ibm-cloud-api-key)
    - [Create an IBM Cloud Classic Infrastructure API Key](#create-an-ibm-cloud-classic-infrastructure-api-key)
    - [Exporting the credentials](#exporting-the-credentials)
  - [Provisioning the Cloud Pak Sandbox](#provisioning-the-cloud-pak-sandbox)
  - [Cloud Pak Inputs/Outputs and Validation](#cloud-pak-inputsoutputs-and-validation)
  - [Cloud Pak External Terraform Modules](#cloud-pak-external-terraform-modules)

## Requirements

The development and testing of the sandbox setup code requires the following elements:

- Have an IBM Cloud account with required privileges
- [Install IBM Cloud CLI](https://ibm.github.io/cloud-enterprise-examples/iac/setup-environment#install-ibm-cloud-cli)
- [Install the IBM Cloud CLI Plugins](https://ibm.github.io/cloud-enterprise-examples/iac/setup-environment#ibm-cloud-cli-plugins) `schematics` and `kubernetes-service`.
- [Login to IBM Cloud with the CLI](https://ibm.github.io/cloud-enterprise-examples/iac/setup-environment#login-to-ibm-cloud)
- [Install Terraform](https://ibm.github.io/cloud-enterprise-examples/iac/setup-environment#install-terraform)
- [Install IBM Cloud Terraform Provider](https://ibm.github.io/cloud-enterprise-examples/iac/setup-environment#configure-access-to-ibm-cloud)
- [Configure Access to IBM Cloud](#configure-access-to-ibm-cloud)
- Install some utility tools such as:
  - [jq](https://stedolan.github.io/jq/download/)
  - [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
  - `oc`

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

### Exporting the credentials

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

## Provisioning the Cloud Pak Sandbox

 To build the Sandbox with a selected Cloud Pak on IBM Cloud Classic the available methods are:

- **[Using Make](./Using_Make.md)**: With the use of `make` and the existing `Makefiles` it is possible to provision the Cloud Pak locally with Terraform, or remotely with Schematics. Make is the recommended way if this is your first time or to get things done quickly. Instructions for using `make` are [here](./Using_Make.md).
- **[Using Terraform](./Using_Terraform.md)**: The Makefile contains all the Terraform actions/commands to run, however you can execute them manually whenever you want, even after using `make` initially. This option allows you to customize the input parameters and offers more control of the process. Instructions for using Terraform directly are [here](./Using_Terraform.md).
- **[Using Schematics](./Using_Schematics.md)**: The Makefile contains all the commands to provision a Cloud Pak using IBM Cloud Schematics, however you can do it manually using `ibmcloud` cli or the IBM Cloud Web Console to create and manage a Schematics workspace. Consider using `make` to - at least - create the workspace, it can save you some time. Instructions for using Schematics are [here](./Using_Schematics.md).
- **[Using IBM Cloud CLI](./Using_IBMCloud_CLI.md)**: The existing Terraform code provisions an OpenShift cluster then installs the requested Cloud Pak on it. With the IBM Cloud CLI you cannot install a Cloud Pak but you can provision an OpenShift cluster to install the Cloud Pak on using any of the above methods. Instructions to provision an OpenShift cluster are [here](./Using_IBMCloud_CLI.md).
- **[Using a Private Catalog](./Using_Private_Catalog.md)**: (Deprecated) It's possible to have a Private Catalog as a user interface with the Schematics and Terraform code, however this option may be more complex than creating a Schematics workspace. This option is not supported anymore. Instructions to create a Private Catalog are [here](./Using_Private_Catalog.md).

## Cloud Pak Inputs/Outputs and Validation

[Cloud Pak for Applications](./cp4app/README.md)

[Cloud Pak for Data](./cp4data/README.md)

[Cloud Pak for Multicloud Management](./cp4mcm/README.md)

## Cloud Pak External Terraform Modules

[Terraform modules for the Cloud Pak Sandbox environment](https://github.com/ibm-hcbt/terraform-ibm-cloud-pak)



