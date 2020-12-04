# Creation of a Cloud Pack Sandbox

This folder contains the Infrastructure as Code or Terraform code to create a **Sandbox** with an **Openshift** (ROKS) cluster on IBM Cloud **Classic** or **VPC** Gen 2, with **Multi Cloud Management Cloud Pak** (CP4MCM) or **Applications Cloud Pak** (CP4App)

This documentation includes instructions to provision the sandbox using makefiles, a local Terraform client, Schematics, the IBM Cloud CLI and using a Private Catalog on IBM Cloud Web Console.
- [Creation of a Cloud Pack Sandbox](#creation-of-a-cloud-pack-sandbox)
  - [Requirements](#requirements)
  - [Configure Access to IBM Cloud](#configure-access-to-ibm-cloud)
    - [Create an IBM Cloud API Key](#create-an-ibm-cloud-api-key)
    - [Create an IBM Cloud Classic Infrastructure API Key](#create-an-ibm-cloud-classic-infrastructure-api-key)
    - [Export the following environment variables to let the IBM Provider to retrieve the credentials.](#export-the-following-environment-variables-to-let-the-ibm-provider-to-retrieve-the-credentials)
  - [Provisioning a sandbox using Makefiles](#provisioning-a-sandbox-using-makefiles)
    - [Provisioning a ROKS cluster with Classic Infrastructure](#provisioning-a-roks-cluster-with-classic-infrastructure)
      - [Helpful Cloud commands to determine specific options](#helpful-cloud-commands-to-determine-specific-options)
    - [Installing CP4MCM and/or CP4Apps](#installing-cp4mcm-andor-cp4apps)
  - [Provisioning a sandbox using local Terraform](#provisioning-a-sandbox-using-local-terraform)
  - [Provisioning a sandbox using Schematics](#provisioning-a-sandbox-using-schematics)
    - [Using IBM Cloud CLI](#using-ibm-cloud-cli)
    - [Using IBM Cloud Web Console](#using-ibm-cloud-web-console)
  - [Provisioning a sandbox using IBM Cloud CLI](#provisioning-a-sandbox-using-ibm-cloud-cli)
  - [Private Catalog Deployment](#private-catalog-deployment)
  - [Input/Output/Validation for ROKS Cluster](#inputoutputvalidation-for-roks-cluster)
    - [ROKS Input Variables](#roks-input-variables)
    - [ROKS Output Variables](#roks-output-variables)
    - [ROKS Cluster Validation](#roks-cluster-validation)
  - [Input/Output/Validation for Cloud Paks](#inputoutputvalidation-for-cloud-paks)
    - [Cloud Pak Entitlement Key](#cloud-pak-entitlement-key)
    - [Cloud Pak for Multi Cloud Management (CP4MCM)](#cloud-pak-for-multi-cloud-management-cp4mcm)
    - [CP4MCM Input Variables](#cp4mcm-input-variables)
    - [CP4MCM Output Variables](#cp4mcm-output-variables)
    - [CP4MCM Validation](#cp4mcm-validation)
    - [Cloud Pak for Applications (CP4Apps)](#cloud-pak-for-applications-cp4apps)
    - [CP4APP Input Variables](#cp4app-input-variables)
    - [CP4APP Output Variables](#cp4app-output-variables)
    - [CP4Apps Validation](#cp4apps-validation)

## Requirements

The development and testing of the sandbox setup code requires the following elements:

- Have an IBM Cloud account with required privileges
- [Install IBM Cloud CLI](https://ibm.github.io/cloud-enterprise-examples/iac/setup-environment#install-ibm-cloud-cli)
- [Install the IBM Cloud CLI Plugins](https://ibm.github.io/cloud-enterprise-examples/iac/setup-environment#ibm-cloud-cli-plugins) `schematics` and `container-service/kubernetes-service`.
- [Login to IBM Cloud with the CLI](https://ibm.github.io/cloud-enterprise-examples/iac/setup-environment#login-to-ibm-cloud)
- [Install Terraform](https://ibm.github.io/cloud-enterprise-examples/iac/setup-environment#install-terraform)
- [Install IBM Cloud Terraform Provider](https://ibm.github.io/cloud-enterprise-examples/iac/setup-environment#configure-access-to-ibm-cloud)
- [Configure Access to IBM Cloud](#configure-access-to-ibm-cloud)
- Install some utility tools such as:
  - [jq](https://stedolan.github.io/jq/download/) (_Optional_)
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

Terraform requires the IBM Cloud credentials to access IBM Cloud Classics or VPC, we choose to set the credentials in environment variables.

### Create an IBM Cloud API Key

Follow these instructions to setup the **IBM Cloud API Key**, for more information read [Creating an API key](https://cloud.ibm.com/docs/account?topic=account-userapikey#create_user_key).

In a terminal window, execute following commands:

```bash
ibmcloud login --sso
ibmcloud resource groups
ibmcloud target -g RESOURCE_GROUP_NAME
```
If you have an IBM Cloud API Key that is either not set or you don't have the JSON file when it was created, you must recreate the key. Delete the old one if it won't be in use anymore.

```bash
# Delete the old one, if won't be in use anymore
ibmcloud iam api-keys       # Identify your old API Key Name
ibmcloud iam api-key-delete NAME
```
Create new key
```
ibmcloud iam api-key-create TerraformKey -d "API Key for Terraform" --file ~/.ibm_api_key.json
export IC_API_KEY=$(grep '"apikey":' ~/.ibm_api_key.json | sed 's/.*: "\(.*\)".*/\1/')
```
### Create an IBM Cloud Classic Infrastructure API Key

Follow these instructions to get the **Username** and **API Key** to access **IBM Cloud Classic**, for more information read [Managing classic infrastructure API keys](https://cloud.ibm.com/docs/account?topic=account-classic_keys).

1. At the IBM Cloud web console, go to **Manage** > **Access (IAM)** > **API keys**, and select **Classic infrastructure API keys** in the dropdown menu.
2. Click Create a classic infrastructure key. If you don't see this option, check to see if you already have a classic infrastructure API key that is created because you're only allowed to have one in the account per user.
3. Go to the actions menu (3 vertical dots) to select **Details**, then **Copy** the API Key.
4. Go to **Manage** > **Access (IAM)** > **Users**, then search and click on your user's name. Select **Details** at the right top corner to copy the **User ID** from the users info (it may be your email address).

### Export the following environment variables to let the IBM Provider to retrieve the credentials.

```bash
export IAAS_CLASSIC_USERNAME="< Your IBM Cloud Username/Email here >"
export IAAS_CLASSIC_API_KEY="< Your IBM Cloud Classic API Key here >"
export IC_API_KEY="< IBM Cloud API Key >"
```
So as to not have to define them for every new terminalYou can create the file `credentials.sh` containing the above credentials.
Execute the file like so:

```bash
source credentials.sh
```

Additionally, you can append the `export` commands in your shell profile or config file (i.e. `~/.bashrc` or `~/.zshrc`) and they will be executed on every new terminal.

**IMPORTANT**: If you use a different filename different to `credentials.sh` make sure to not commit the file to GitHub. The filename `credentials.sh` is in the `.gitignore` file so it's safe to use it, it won't be committed to GitHub.

## Provisioning a sandbox using Makefiles

The following instructions are to provision a sandbox using [makefiles which invoke Terraform](#provisioning-a-sandbox-using-makefiles).

Check the other sections to know how to get the cluster using [Terraform](#provisioning-a-sandbox-using-local-terraform) directly, [Schematics](#provisioning-a-sandbox-using-schematics), the [IBM Cloud CLI](#provisioning-a-sandbox-using-ibm-cloud-cli) or the [Private Catalog](#private-catalog-deployment)

Make sure you have all the [Requirements](#requirements), including [Configure Access to IBM Cloud](#configure-access-to-ibm-cloud). This section sets the input variables in the `./cloud-paks/terraform.tfvars` file but you can also set them using environment variables.

Clone this repo on your local machine and 
```
cd <cloned repo>/terraform
```
### Provisioning a ROKS cluster with Classic Infrastructure

To see what inputs are required/optional to provision a ROKS cluster go to [ROKS Input Variables](#roks-input-variables)

By default a cluster is created with these values. To change them, edit the file `./cloud-paks/terraform.tfvars`:
```hcl
infra               = "classic"
project_name        = "cloud-pack"
owner               = "anonymous"
environment         = "sandbox"
region              = "us-south"
resource_group      = "cloud-pak-sandbox"
k8s_version         = "4.4_openshift"
kubeconfig_dir      = "./.kube/config"
datacenter          = "dal10"
size                = "5"
flavor              = "c3c.16x32"
private_vlan_number = ""
public_vlan_number  = ""
```
#### Helpful Cloud commands to determine specific options
```
ibmcloud ls regions
ibmcloud ks versions | grep _OpenShift
ibmcloud ks zone ls --provider classic
ibmcloud ks flavors --zone $ZONE
ibmcloud ks vlan ls --zone {datacenter}
```

### Installing CP4MCM and/or CP4Apps

-  To install on an existing cluster, set the following environment variable with the cluster id
```
export TF_VAR_cluster_id="************"
```
- To provision a fresh ROKS cluster with MCM or Apps installed, make sure the options specified in the `./cloud-paks/terraform.tfvars` in the [Provisioning a sandbox using Makefiles](#provisioning-a-sandbox-using-makefiles) section are set.

All cloud paks require an entitlement key located here: https://myibm.ibm.com/products-services/containerlibrary. Save the key to the file `./entitlement.key`. 

Ensure the following defaults are set in `./cloud-paks/terraform.tfvars`.
```
// Set the entitled_registry_user_email with the docker email address to login to the registry
entitled_registry_user_email = "first.last_name@ibm.com"
```
Set the defaults in `./cloud-paks/terraform.tfvars` according to [Cloud Pak for Multi Cloud Management (CP4MCM)](#cloud-pak-for-multi-cloud-management-cp4mcm) and [Cloud Pak for Applications (CP4Apps)](#cloud-pak-for-applications-cp4apps) for the input variables required to install  Cloud Paks.

After setting all the input parameters execute the following commands to create the cluster

1. After the requirements are set and - every time - before applying/executing the code or committing to GitHub any change, validate your code executing the following commands:

```bash
make init
make validate
```
2. Execute `make`. This command will generate all the input parameters, generate the plan and apply it. When complete, the output parameters to access the Cloud Pak are printed out and some tests are executed.
  ```
  make
  ```
3. To print the output parameters to access the ROKS Cluster and Cloud Paks, execute: 
  ```
  make output-tf
  ```
4. To destroy the cluster, execute: 
  ```
  make destroy-tf
  ```
5. Cleanup everything executing: 
  ```
  make clean-tf
  ```
**IMPORTANT**: Do not execute `clean-tf` before executing `destroy-tf` or you'll have to delete the cluster manually.

After around _20 to 30 minutes_ the Openshift cluster is up and running so you can configure `kubectl` or `oc` to access the cluster either executing the following `ibmcloud` or `export` command:

```bash
ibmcloud ks cluster config -cluster $(terraform output cluster_id)
# Or
export KUBECONFIG=$(terraform output kubeconfig)
```

If CP4MCM was enabled, open the CP4MCM Endpoint using the following URL and credentials:

```bash
terraform output cp4mcm_user
terraform output cp4mcm_password

open "http://$(terraform output cp4mcm_endpoint)"
```

If CP4APP was enabled, ...

**TODO**: Provide instructions to access CP4APP

## Provisioning a sandbox using local Terraform

You can use Terraform commands directly to execute the code locally for testing or if you are the only administrator of this infrastructure. 

1. Ensure that Terraform is set up on your local system according to [Requirements](#requirements).

2. Update the file `./cloud-paks/terraform.tfvars` according to 
desired input values listed in [ROKS Input Variables](#roks-input-variables)

3. Execute the following commands:

```bash
terraform init
terraform plan
terraform apply
```

The cluster should be available in about **20 to 30 minutes**. Then execute the validation commands or actions documented in the [Validation](#validation) section below.

4. Finally, when you finish using the infrastructure, cleanup everything you created with the execution of:

```bash
terraform destroy
```

The cluster destruction should finish in about **10 minutes**.

## Provisioning a sandbox using Schematics

For group development and testing it is recommended to use Schematics to provision the OpenShift cluster. The Terraform state of the cluster is shared with the team and the management of the cluster can be done in the IBM Web Console by any team member.

There are two ways to create and execute the Schematics workspace, using [IBM Cloud Web Console](#using-ibm-cloud-web-console) or [IBM Cloud CLI](#using-ibm-cloud-cli). However, to automate the process and facilitate maintenance it is recommended to use the CLI for the creation of the workspace.

### Using IBM Cloud CLI

1. set the following required values (`OWNER`, `PROJECT`, `ENV`, `ENTITLED_KEY` and `ENTITLED_KEY_EMAIL`) in the the `workspace.tmpl.json` file and rename it `workspace.json`:

```bash
PROJECT=cp-mcm
OWNER=$USER
ENV=sandbox
ENTITLED_KEY_EMAIL=<Email Address owner of the Entitled Key >
ENTITLED_KEY=< Your Entitled Key >
```
  or
```bash
ENTITLED_KEY=$(cat entitlement.key)

sed \
  -e "s|{{ PROJECT }}|$PROJECT|" \
  -e "s|{{ OWNER }}|$OWNER|" \
  -e "s|{{ ENV }}|$ENV|" \
  -e "s|{{ ENTITLED_KEY }}|$ENTITLED_KEY|" \
  -e "s|{{ ENTITLED_KEY_EMAIL }}|$ENTITLED_KEY_EMAIL|" \
  workspace.tmpl.json > workspace.json
```

Also modify (if needed) the value of the parameters located in `.template_data[].variablestore[]`. Use the `ibmcloud` command to identify the values, as explained in the [ROKS Input Variables](#roks-input-variables) section and on each variable description.

Confirm the GitHub URL to the Terraform code in `.template_repo.url` in the `workspace.json` file. This URL could be in a the master branch, a different branch, tag or folder.

2. Create the workspace executing the following commands:

```bash
ibmcloud schematics workspace list
ibmcloud schematics workspace new --file workspace.json
ibmcloud schematics workspace list
```

Wait until the workspace status is set to **INACTIVE**. If something goes wrong you can update the workspace or delete it and create it with the correct parameters. To delete it use the command:

```bash
ibmcloud schematics workspace delete --id WORKSPACE_ID
```

3. Once the workspace is created and with status **INACTIVE**, it's ready to apply the terraform code

```bash
# Get list of workspaces
ibmcloud schematics workspace list  

# Set the WORKSPACE_ID
export WORKSPACE_ID=<name of workspace>

# (Optional) Plan:
ibmcloud schematics plan --id $WORKSPACE_ID  # Identify the Activity_ID
ibmcloud schematics logs --id $WORKSPACE_ID --act-id Activity_ID

# Apply:
ibmcloud schematics apply --id $WORKSPACE_ID # Identify the Activity_ID
ibmcloud schematics logs  --id $WORKSPACE_ID --act-id Activity_ID
```
4. Cleanup

To destroy the Schematics created resources and the workspace execute the following commands:

```bash
ibmcloud schematics destroy --id $WORKSPACE_ID # Identify the Activity_ID
ibmcloud schematics logs  --id $WORKSPACE_ID --act-id Activity_ID

# ... wait until it's done

ibmcloud schematics workspace delete --id $WORKSPACE_ID
ibmcloud schematics workspace list
```
### Using IBM Cloud Web Console

1. In the IBM Cloud Web Console go to: **Navigation Menu** (_top left corner_) > **Schematics**. Click **Create Workspace** in upper right corner of list of workspaces
2. Provide a name, tags, location. Choose **schematics** resource group
3. Once workspace is created, add **https://github.com/ibm-hcbt/cloud-pak-sandboxes/tree/master/terraform** as the github URL
4. Leave **Personal access token** blank
5. Change **Terraform version** to 0.12
6. Click **Save template information**
7. Click on **Generate plan** button at the top, then click on **View log** link and wait until it's completed.
8. Click on the **Apply plan** button, then click on the **View log** link.
9. On the left side menu check the **Resources** item, to see all the resources created or modified from the workspace.

## Provisioning a sandbox using IBM Cloud CLI

The creation of the cluster using the IBM Cloud CLI may not be the best option but you can use it if there is a problem with Terraform or Schematics.

Using the `ibmcloud` command and the `kubernetes-service` plugin, execute:

- On **IBM Cloud Classic**:

  ```bash
  export IAAS_CLASSIC_USERNAME="< Your IBM Cloud Username/Email here >"
  export IAAS_CLASSIC_API_KEY="< Your IBM Cloud Classic API Key here >"

  export PROJECT_NAME="cp-sandbox"

  ibmcloud ks versions | grep _OpenShift
  export VERSION="4.4"

  ibmcloud ks zone ls --provider classic
  export ZONE="dal10"

  ibmcloud ks flavors --zone $ZONE
  export FLAVOR="b3c.4x16"

  export CLUSTER_NAME="${PROJECT_NAME}-cluster"
  export SIZE=1

  ibmcloud ks cluster create classic \
            --name $CLUSTER_NAME \
            --version $VERSION \
            --zone $ZONE \
            --flavor $FLAVOR \
            --workers $SIZE \
            --entitlement cloud_pak

  ibmcloud ks cluster config --cluster $CLUSTER_NAME

  kubectl cluster-info
  ```

- On **IBM Cloud VPC Gen 2**:

  ```bash
  export PROJECT_NAME="cp-sandbox"

  export IC_API_KEY="< IBM Cloud API Key >"

  ibmcloud ks zone ls --provider vpc-gen2 --show-flavors
  export ZONE="us-south-1"

  ibmcloud ks flavors --provider vpc-gen2 --zone $ZONE
  export FLAVOR="b3c.4x16"

  VPC_NAME=${PROJECT_NAME}-vpc
  ibmcloud is vpc-create $VPC_NAME
  export VPC_ID=$(ibmcloud is vpcs --json | jq -r ".[] | select(.name==\"$VPC_NAME\").id")

  SUBNET_NAME=${PROJECT_NAME}-subnet
  ibmcloud is subnet-create $SUBNET_NAME $VPC_ID --zone $ZONE --ipv4-address-count 16
  export SUBNET_ID=$(ibmcloud is subnets --json | jq -r ".[] | select(.name==\"$SUBNET_NAME\").id")

  export DEFAULT_SG_ID=$(ibmcloud is vpc-default-security-group $VPC_ID --json | jq -r ".id")
  ibmcloud is security-group-rule-add $DEFAULT_SG_ID inbound tcp --port-min 30000 --port-max 32767

  ibmcloud ks versions
  export VERSION="4.4"

  export CLUSTER_NAME=${PROJECT_NAME}-cluster
  export SIZE=3

  ibmcloud ks cluster create vpc-gen2 \
    --name $CLUSTER_NAME \
    --zone $ZONE \
    --vpc-id $VPC_ID \
    --subnet-id $SUBNET_ID \
    --flavor $FLAVOR \
    --version $VERSION \
    --workers $SIZE
    --entitlement cloud_pak \
    # --service-subnet $SUBNET_CIDR \
    # --pod-subnet $POD_CIDR \
    # --disable-public-service-endpoint \

  ibmcloud ks cluster config --cluster $CLUSTER_NAME

  kubectl cluster-info
  ```

To destroy the cluster, execute the following commands:

```bash
ibmcloud ks cluster rm --cluster $CLUSTER_NAME

# If created on VPC
ibmcloud is subnet-delete $SUBNET_ID
ibmcloud is vpc-delete $VPC_ID
```

## Private Catalog Deployment

To release a new version of the Private Catalog execute the `make` command to create the file `product/CPS-MCM-1.x.y.tgz` file with all the code required for the Catalog Product.

```bash
make
```

Then, follow these instructions on the IBM Cloud Web Console:

1. Create a [release](https://github.com/ibm-hcbt/cloud-pak-sandboxes/releases) in GitHub, assign a version and upload the created `.tgz` to the attached binaries.
2. Copy the binary URL
3. Go to **IBM Cloud Console** > **Manage** > **Catalogs** > **Private catalogs**, create or select the catalog "_Cloud Pak Cluster Sandbox_", then go to **Private products**
4. Add a product, select **Private repository**, and paste the release binary link previously copied
5. Add **ALL** the Deployment values, except the followings:
   1. **flavors**
   2. **vpc_zone_names**
   3. **workers_count**
6. **Edit** the parameters for the following Deployment values:
   1. **TF_VERSION**: Hidden
   2. **infra**: Required
   3. **owner**: Required
   4. **project_name**: Required
7. Click on **Update** and go to **Validate product**, enter the values for the parameters:
   1. **resource group** (at the header and in section **Parameters with default values**): example: `cloud-pak-sandbox`
   2. **owner**, **project_name**: example: `johandry` and `cp-sandbox`
   3. **infra**: enter either `classic` or `vpc`
8. Double check the other deployment values, use the `ibmcloud` commands in the description if required.
9. Click on **Validate** and wait. It's recommended to check the logs (click on **View logs** link) in the created Schematics workspace
10. Once validated, you can **Publish to account** the Catalog, then to staging and production. (so far just to account until it's validated by the team and ready to be released)

_NOTE_: All these manual process will be automated by a CI/CD pipeline

**TODO**: Complete the instructions to install CP4App



## Input/Output/Validation for ROKS Cluster

### ROKS Input Variables 

Besides the access credentials the Terraform script requires the following input parameters, for some variables are instructions to get the possible values using `ibmcloud`.

| Name             | Description   | Default    | Required |
| ---------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------- | -------- |
| `infra`          | IBM Cloud infrastructure to install the cluster. The available options are `classic` or `vpc`                                                                                                                           | `classic`  | Yes      |
| `project_name`   | The project name is used to name the cluster with the environment name. It's also used to label the cluster and other resources                                                                                         |            | Yes      |
| `owner`          | Use your user name or team name. The owner is used to label the cluster and other resources                                                                                                                             |            | Yes      |
| `environment`    | The environment name is used to label the cluster and other resources                                                                                                                                                   | `dev`      | No       |
| `region`         | IBM Cloud region to host the cluster. List all available zones with: `ibmcloud is regions`                                                                                                                              | `us-south` | No       |
| `resource_group` | Resource Group in your account to host the cluster. List all available resource groups with: `ibmcloud resource groups`                                                                                                 | `Default`  | No       |
| `roks_version`   | OpenShift version to install. List all available versions: `ibmcloud ks versions`, make sure it ends with `_OpenShift` otherwise you'll be installing an IKS cluster. Compare versions at: https://ibm.biz/iks-versions | `4.4`      | No       |
| `datacenter`     | On IBM Cloud Classic this is the datacenter or Zone in the region to provision the cluster. List all available zones with: `ibmcloud ks zone ls --provider classic`                                                     | `dal10`    | No       |

Check the sections [Cloud Pak for Multi Cloud Management (CP4MCM)](#cloud-pak-for-multi-cloud-management-cp4mcm) and [Cloud Pak for Applications (CP4Apps)](#cloud-pak-for-applications-cp4apps) for the input variables required to install such Cloud Paks.

To set the input parameters you can export the environment variables with the prefix `TF_VARS_`, like in the following example:

```bash
export TF_VAR_infra=vpc
```

The environment variables have preference over the variables in the `terraform.tfvars` file. Also, there is no need to set the value if you are ok with the variable default value.

### ROKS Output Variables

The module return the following output parameters.

| Name               | Description                                                                                                                         |
| ------------------ | ----------------------------------------------------------------------------------------------------------------------------------- |
| `cluster_endpoint` | The URL of the public service endpoint for your cluster                                                                             |
| `cluster_id`       | The unique identifier of the cluster.                                                                                               |
| `kubeconfig`       | File path to the kubernetes cluster configuration file. Execute `export KUBECONFIG=$(terraform output kubeconfig)` to use `kubectl` |

Check the sections [Cloud Pak for Multi Cloud Management (CP4MCM)](#cloud-pak-for-multi-cloud-management-cp4mcm) and [Cloud Pak for Applications (CP4Apps)](#cloud-pak-for-applications-cp4apps) for the output variables result of the installation such Cloud Paks.
### ROKS Cluster Validation

If you have not setup `kubectl` to access the cluster, execute:

```bash
# If created with Terraform:
ibmcloud ks cluster config --cluster $(terraform output cluster_id)

# If created with Schematics:
ibmcloud ks cluster config --cluster $(ibmcloud schematics workspace output --id $WORKSPACE_ID --json | jq -r '.[].output_values[].cluster_id.value')

# If created with IBM Cloud CLI:
ibmcloud ks cluster config --cluster $CLUSTER_NAME
```

Verify the cluster is up and running executing these commands:

```bash
kubectl cluster-info
kubectl get nodes
kubectl get pods --all-namespaces
```
## Input/Output/Validation for Cloud Paks
### Cloud Pak Entitlement Key

Each Cloud Pak requires an Entitlement Key. It can be retreived from https://myibm.ibm.com/products-services/containerlibrary and copied into the variable `entitled_registry_key` or save into a file (i.e. `entitlement.key`) and set the file path into the variable `entitled_registry_key_file`. Edit the `./cloud-paks/terraform.tfvars` file with the following lines. The IBM Cloud user email address is required in the variable `entitled_registry_user_email` to access the IBM Cloud Container Registry (ICR), set the user email address of the account used to generate the Entitlement Key into this variable.

For example:

```hcl
entitled_registry_user_email = "johandry.amador@ibm.com"

entitled_registry_key        = "< Your Entitled Key here>"
// Or:
entitled_registry_key_file   = "./entitlement.key"
```

**IMPORTANT**: Make sure to not commit the Entitlement Key file or content to the github repository.

### Cloud Pak for Multi Cloud Management (CP4MCM)

Cloud Pak for Multi Cloud Management is disabled by default, if you want to install it, set the variable `with_cp4mcm` to `true`, like this in the `./cloud-paks/terraform.tfvars`.

```hcl
with_cp4mcm = true
```

Make sure you have the [Cloud Pak Entitlement Key](#cloud-pak-entitlement-key) variables with the correct value.

Other set of variables to assign values are the MCM modules to enable or disable. Set `true` or `false` to the following MCM modules variables:

```hcl
infr_mgt_install      = false
monitoring_install    = false
security_svcs_install = false
operations_install    = false
tech_prev_install     = false
```

The following table contain the input variables required to install CP4MCM:

### CP4MCM Input Variables

| Name                           | Description                                                                                                                                                      | Default              | Required |
| ------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------- | -------- |
| `with_cp4mcm`                  | If false, do not install CP4MCM on the ROKS cluster. By default it's disabled                                                                                    | `false`              | No       |
| `entitled_registry_key`        | Get the entitlement key from: https://myibm.ibm.com/products-services/containerlibrary, copy and paste the key to this variable                                  |                      | No       |
| `entitled_registry_key_file`   | Get the entitlement key from: https://myibm.ibm.com/products-services/containerlibrary, save the key to a file and enter the relative file path to this variable | `./entitlement.key"` | No       |
| `entitled_registry_user_email` | Email address of the user owner of the Entitled Registry Key                                                                                                     |                      | Yes      |
| `infr_mgt_install`             | Enable or disable the CP4MCM Module Infrastructure Management                                                                                                    | `false`              | No       |
| `monitoring_install`           | Enable or disable the CP4MCM Module Monitoring                                                                                                                   | `false`              | No       |
| `security_svcs_install`        | Enable or disable the CP4MCM Module Security Services                                                                                                            | `false`              | No       |
| `operations_install`           | Enable or disable the CP4MCM Module Operations                                                                                                                   | `false`              | No       |
| `tech_prev_install`            | Enable or disable the CP4MCM Module Tech Prev                                                                                                                    | `false`              | No       |

**TODO**: Update the CP4MCM modules names if needed. Provide more information about them or a link with their description.

If you are using Schematics directly or the Private Catalog, set the variable `entitled_registry_key` with the content of the Entitlement Key. The variable `entitled_registry_key_file` is not available.

### CP4MCM Output Variables

Once the Terraform code finish (either using Terraform, Schematics or the Catalog) use the following output variables to access CP4MCM Dashboard:

| Name               | Description                                                     |
| ------------------ | --------------------------------------------------------------- |
| `cp4mcm_endpoint`  | URL of the CP4MCM dashboard                                     |
| `cp4mcm_user`      | Username to login to the CP4MCM dashboard                       |
| `cp4mcm_password`  | Password to login to the CP4MCM dashboard                       |
| `cp4mcm_namespace` | Kubernetes namespace where all the CP4MCM objects are installed |

### CP4MCM Validation

Execute the following commands to validate MCM:

```bash
export KUBECONFIG=$(terraform output config_file_path)

kubectl cluster-info

# Namespace
kubectl get namespaces $(terraform output cp4mcm_namespace)

# All resources
kubectl get all --namespace $(terraform output cp4mcm_namespace)
```

Using the following credentials:

```bash
terraform output cp4mcm_user
terraform output cp4mcm_password
```

Open the following URL:

```bash
open "http://$(terraform output cp4mcm_endpoint)"
```

To clean up or remove CP4MCM and its dependencies from a cluster, execute the following commands:

```bash
kubectl delete -n openshift-operators subscription.operators.coreos.com ibm-management-orchestrator
kubectl delete -n openshift-marketplace catalogsource.operators.coreos.com ibm-management-orchestrator opencloud-operators
kubectl delete namespace cp4mcm
```

**Note**: The uninstall/cleanup up process is a work in progress at this time, we are identifying the objects that needs to be deleted in order to have a successfully re-installation.

### Cloud Pak for Applications (CP4Apps)

CloudPak for Applications is disabled by default, if you want to install it, set the variable `with_cp4app` to `true`, like this in the `./cloud-paks/terraform.tfvars`.

```hcl
with_cp4app = true
```

Make sure you have the [Cloud Pak Entitlement Key](#cloud-pak-entitlement-key) variables with the correct value.

### CP4APP Input Variables

| Name          | Description                                                                   | Default | Required |
| ------------- | ----------------------------------------------------------------------------- | ------- | -------- |
| `with_cp4app` | If false, do not install CP4APP on the ROKS cluster. By default it's disabled | `false` | No       |

### CP4APP Output Variables

Once the Terraform code finish (either using Terraform, Schematics or the Catalog) use the following output variables to use CP4APP:

| Name                 | Description    |
| -------------------- | -------------- |
| `some variable here` | Something here |

### CP4Apps Validation

Execute the following commands to validate MCM:

```bash
export KUBECONFIG=$(terraform output config_file_path)

kubectl cluster-info

# Namespace
kubectl get namespaces $(terraform output cp4app_namespace)
```

