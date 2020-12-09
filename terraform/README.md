# Creation of a Cloud Pak Sandbox

This folder contains the Infrastructure as Code or Terraform code to create a **Sandbox** with an **Openshift** (ROKS) cluster on IBM Cloud Classic with a Cloud Pak. At this time the Cloud Paks to install are:

- Cloud Pak for Multi Cloud Management (CP4MCM)
- Cloud Pak for Applications (CP4A)
- Cloud Pak for Data (CP4D)

Notice that this documentation is **<u>only for developers or advance users</u>**. The regular users will be using [this documentation](../installer/README.md).

Everything is automated using in the Makefile however, instructions to get the same results manually are provided.

- [Creation of a Cloud Pak Sandbox](#creation-of-a-cloud-pak-sandbox)
  - [Requirements](#requirements)
  - [Configure Access to IBM Cloud](#configure-access-to-ibm-cloud)
    - [Create an IBM Cloud API Key](#create-an-ibm-cloud-api-key)
    - [Create an IBM Cloud Classic Infrastructure API Key](#create-an-ibm-cloud-classic-infrastructure-api-key)
    - [Create a `credentials.sh` file](#create-a-credentialssh-file)
  - [Provisioning the Cloud Pak Sandbox](#provisioning-the-cloud-pak-sandbox)

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

Executing these commands you are validating part of these requirements:

```bash
ibmcloud --version
ibmcloud plugin show schematics | head -3
ibmcloud plugin show kubernetes-service | head -3
ibmcloud target
terraform version
ls ~/.terraform.d/plugins/terraform-provider-ibm_*
```

## Configure Access to IBM Cloud

Terraform requires the IBM Cloud credentials to access IBM Cloud Classics, we choose to set the credentials in environment variables and - optionally and recommended - in your own `credentials.sh` file.

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

### Create a `credentials.sh` file

Export the following environment variables to let the IBM Provider to retrieve the credentials.

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

**IMPORTANT**: If you use a different filename different to `credentials.sh` make sure to not commit the file to GitHub. The filename `credentials.sh` is in the `.gitignore` file so it's safe to use it, it won't be committed to GitHub.

## Provisioning the Cloud Pak Sandbox

The provisioning or to build the Sandbox with a selected Cloud Pak on IBM Cloud Classic can be done and is recommended to use `make` however other methods can be used as well. The available methods are:

- **[Using Make](./Using_Make.md)**: With the use of `make` and the existing `Makefiles` it is possible to provision the Cloud Pak locally with Terraform, or remotely with Schematics. Make is the recommended way if this is your first time or to get things done quickly. Get all the instructions reading the [Using_Make.md](./Using_Make.md) document.
- **[Using Terraform](./Using_Terraform.md)**: The Makefile contain all the Terraform actions/commands to run, however you can execute them manually whenever you want, even after use `make` initially. This option allows you to customize the input parameters and give you more control of the process. Get all the instructions reading the [Using_Terraform.md](./Using_Terraform.md) document.
- **[Using Schematics](./Using_Schematics.md)**: The Makefile contain all the commands to provision a Cloud Pak using IBM Cloud Schematics, however you do it manually using `ibmcloud` to create and manage a Schematics workspace or directly on the IBM Cloud Web Console. Consider to use the `make` to - at least - create the workspace, it can safe you some time. Get all the instructions reading the [Using_Schematics.md](./Using_Schematics.md) document.
- **[Using IBM Cloud CLI](./Using_IBMCloud_CLI.md)**: The existing Terraform code provision an OpenShift cluster then install the requested Cloud Pak on it. With the IBM Cloud CLI you cannot install a Cloud Pak but you can provision an OpenShift cluster to install the Cloud Pak using any of the above methods. To get the instructions to provision an OpenShift cluster, read the [Using_IBMCloud_CLI.md](./Using_IBMCloud_CLI.md) document.
- **[Using_Private_Catalog](./Using_Private_Catalog.md)**: (Deprecated) It's possible to have a Private Catalog as user interface with the Schematics and Terraform code, however this option may be more complex than creating a Schematics workspace. This option is not supported anymore. To know the outdated instructions to create a Private Catalog, read the [Using_Private_Catalog.md](./Using_Private_Catalog.md) document.
