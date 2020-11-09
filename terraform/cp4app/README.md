# Development of the Private Catalog to create a Cloud Pack Sandbox

This folder contain the Infrastructure as Code or Terraform code to create an IBM Cloud Catalog to create a **Sandbox** with an **Openshift** (ROKS) cluster on IBM Cloud **Classic** or **VPC** Gen 2, with **Multi Cloud Management Cloud Pak** (CP4MCM) or **Applications Cloud Pak** (CP4App)

The sandbox Openshift cluster with CP4MCM or CP4App is provisioned using the Private Catalog on IBM Cloud Web Console, however this documentation include instructions to get the cluster on the CLI using Terraform, Schematics or the IBM Cloud CLI.

- [Development of the Private Catalog to create a Cloud Pack Sandbox](#development-of-the-private-catalog-to-create-a-cloud-pack-sandbox)
  - [Private Catalog Deployment](#private-catalog-deployment)
  - [Getting Started with Terraform](#getting-started-with-terraform)
  - [Requirements](#requirements)
  - [Configure Access to IBM Cloud](#configure-access-to-ibm-cloud)
    - [Setup Access to IBM Cloud Classic](#setup-access-to-ibm-cloud-classic)
    - [Setup Access to IBM Cloud VPC](#setup-access-to-ibm-cloud-vpc)
    - [Using the `credentials.sh` file](#using-the-credentialssh-file)
  - [Input Variables](#input-variables)
  - [Output Variables](#output-variables)
  - [Provisioning with Terraform](#provisioning-with-terraform)
  - [Provisioning with Schematics](#provisioning-with-schematics)
    - [Using the IBM Cloud Web Console](#using-the-ibm-cloud-web-console)
    - [Using the IBM Cloud CLI](#using-the-ibm-cloud-cli)
    - [Cleanup](#cleanup)
  - [Provisioning with IBM Cloud CLI](#provisioning-with-ibm-cloud-cli)
  - [Validation](#validation)
  - [Cloud Pak Entitlement Key](#cloud-pak-entitlement-key)
  - [Cloud Pak for Multi Cloud Management (CP4MCM)](#cloud-pak-for-multi-cloud-management-cp4mcm)
    - [CP4MCM Input Variables](#cp4mcm-input-variables)
    - [CP4MCM Output Variables](#cp4mcm-output-variables)
    - [CP4MCM Validation](#cp4mcm-validation)
  - [Cloud Pak for Applications (CP4Apps)](#cloud-pak-for-applications-cp4apps)
    - [CP4APP Input Variables](#cp4app-input-variables)
    - [CP4APP Output Variables](#cp4app-output-variables)
    - [CP4MCM Validation](#cp4mcm-validation-1)

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

## Getting Started with Terraform

The following instructions are to provision an Openshift cluster with Multi Cloud Management Cloud Pak using [Terraform](#provisioning-with-terraform), check the other sections to know how to get the cluster using [Schematics](#provisioning-with-schematics), the [Private Catalog](./CATALOG.md) or the [IBM Cloud CLI](#provisioning-with-ibm-cloud-cli).

Make sure you have all the [Requirements](#requirements), including [Configure Access to IBM Cloud](#configure-access-to-ibm-cloud). This section sets the input variables in the `terraform.tfvars` file but you can also set them using environment variables.

After the requirements are set and - every time - before applying/executing the code or committing to GitHub any change, validate your code executing the following commands:

```bash
make init
make validate
```

The quickest way to have a ROKS cluster up and running either empty, with CP4MCM or with CP4APP, on IBM Cloud Classic, Dallas region and _cloud-pak-sandbox_ resource group, is executing `make with-terraform` like that or appending the suffix `-mcm` or `-app` respectively, like so:

```bash
# Empty cluster:
make with-terraform

# ROKS with CP4MCM
make with-terraform-mcm

# ROKS with CP4APP
make with-terraform-app
```

By default the owner is the user or the `$USER` environment variable. You can choose the project name using the _variables_ `NAME`, like so:

```bash
make with-terraform-app NAME=cp-app-$USER
```

After the cluster is built and tested, you may destroy it and cleanup your directory running:

```bash
make clean-all
```

The following instructions are recommended to build a custom cluster, on a different region, Kubernetes/Openshift version, resource group, etc...

Identify the region and Openshift version to use executing:

```bash
# (Optional) Select a resource group. Default value: Default
ibmcloud is regions

# (Recommended) Select an OpenShift version. Default value: check `variables.tf` we try to get the latest version as default
ibmcloud ks versions | grep _OpenShift
```

Set the following variables in the `terraform.tfvars` file, using the `region` and Openshift version (`k8s_version`) from the previously executed commands.

```hcl
project_name   = "cp-sandbox"
region         = "us-south"
resource_group = "cloud-pak-sandbox"
k8s_version    = "4.4_openshift"
```

If you are on Linux or macOS, it's recommended to set the `owner` variable as your User Name, execute this command if you are on Linux or macOS:

```bash
export TF_VAR_owner=$USER
```

If you'd like a different `owner` open the `terraform.tfvars` again to set the variable like so:

```hcl
owner          = "my_user_name_or_id"
```

Follow the instructions to set the parameters for **Classic** or **VPC** infrastructure:

- On **IBM Cloud Classic**

  Export the credentials for IBM Cloud Classic, identify the zone (datacenter) to install the cluster, then the machine type (flavor) and VLAN numbers from the selected zone.

  ```bash
  # Credentials required for IBM Cloud Classic
  export IAAS_CLASSIC_USERNAME="< Your IBM Cloud Username/Email here >"
  export IAAS_CLASSIC_API_KEY="< Your IBM Cloud Classic API Key here >"
  export IC_API_KEY="< IBM Cloud API Key >"

  # (Optional) Select a zone. Default value: dal10
  ibmcloud ks zone ls --provider classic
  ZONE="dal10"

  # (Optional) Select a machine type. Default value: b3c.4x16
  ibmcloud ks flavors --zone $ZONE

  # (Required) Select the private and public VLAN ID's
  ibmcloud ks vlan ls --zone $ZONE
  ```

  Set the following variables in the `terraform.tfvars` file, using the `datacenter`, `flavor`, `private_vlan_number` and `public_vlan_number` from the previously executed commands. The `size` is the number of workers to create:

  ```hcl
  infra               = "classic"

  datacenter          = "dal10"
  size                = "1"
  flavor              = "b3c.4x16"
  private_vlan_number = "2832804"
  public_vlan_number  = "2832802"
  ```

- On **IBM Cloud VPC Gen 2**:

  Export the credentials for IBM Cloud VPC, identify the sub-zone to install the cluster and then the machine types (flavors) from the selected sub-zone. Make sure the selected sub-zones are in the `region` previously selected.

  ```bash
  # Credentials required for IBM Cloud VPC
  export IC_API_KEY="< IBM Cloud API Key >"

  # (Optional) Select the zone(s) to install the worker pools. Default value: ["us-south-1"]
  ibmcloud ks zone ls --provider vpc-gen2
  ZONE="us-south-1"

  # (Optional) Select a machine type or flavor for the given zone. Repeat these commands for each zone. Default value: ["mx2.4x32"]
  ibmcloud ks flavors --zone $ZONE --provider vpc-gen2
  ```

  Set the values as a list (i.e. `["a", "b", "c"]`) in the following variables in the `terraform.tfvars` file, using the zones and `flavors` from the previously executed commands. Then choose how many workers to create on each worker pool (_the number should be >= 2_):

  ```hcl
  infra          = "vpc"

  vpc_zone_names = ["us-south-1"]
  flavors        = ["mx2.4x32"]
  workers_count  = [2]
  ```

  Having more than two element on each list creates the cluster in multiple zones. Make sure the lists length or elements in each list is the same for every list. An example with two worker pools on two different zones:

  ```hcl
  infra          = "vpc"

  vpc_zone_names = ["us-south-1", "us-south-2"]
  flavors        = ["mx2.4x32", "mx2.8x64"]
  workers_count  = [2, 2]
  ```

Follow the instructions to set the parameters to install Cloud Pak for **Multi Cloud Management** or **Application**:

For either CP4MCM or CP4App it's required to have an entitlement key. Get the entitlement key from: https://myibm.ibm.com/products-services/containerlibrary and save the key to the file `./entitlement.key`. Open the file `terraform.tfvars` to assign your IBM Cloud account username - possibly your email address - to the variable `entitled_registry_user_email`, this username is used to access the IBM Cloud Containers Registry (ICR) and the entitlement key is the password. The entitlement variables would be like this:

```hcl
entitled_registry_key_file   = "./entitlement.key"
entitled_registry_user_email = "Johandry.Amador@ibm.com"
```

- With Cloud Pak for **Multi Cloud Management**:

  Open the `terraform.tfvars` file to set to `true` the variable `with_cp4mcm`. Optionally, modify the boolean values of the following MCM modules variables to enable or disable them:

  ```hcl
  with_cp4mcm           = true

  // MCM Modules
  infr_mgt_install      = false
  monitoring_install    = false
  security_svcs_install = false
  operations_install    = false
  tech_prev_install     = false
  ```

- With Cloud Pak for **Application**:

  Open the `terraform.tfvars` file to set to `true` the variable `with_cp4app`.

  ```hcl
  with_cp4app = true
  ```

After setting all the input parameters execute the following commands to create the cluster

```bash
terraform init
terraform plan
terraform apply
```

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

When you finish using the cluster, you can release the resources executing the following command, it should finish in about _8 minutes_:

```bash
terraform destroy
```

## Requirements

The development and testing of the Terraform code requires the following elements:

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
echo $IC_API_KEY
```

If you have an API Key but is not set neither have the JSON file when it was created, you must recreate the key. Delete the old one if won't be in use anymore.

```bash
# Delete the old one, if won't be in use anymore
ibmcloud iam api-keys       # Identify your old API Key Name
ibmcloud iam api-key-delete NAME

# Create a new one and set it as environment variable
ibmcloud iam api-key-create TerraformKey -d "API Key for Terraform" --file ~/.ibm_api_key.json
export IC_API_KEY=$(grep '"apikey":' ~/.ibm_api_key.json | sed 's/.*: "\(.*\)".*/\1/')
```

## Configure Access to IBM Cloud

Terraform requires the IBM Cloud credentials to access IBM Cloud Classics or VPC, we choose to set the credentials in environment variables.

### Setup Access to IBM Cloud Classic

Follow these instructions to get the **Username** and **API Key** to access **IBM Cloud Classic**, for more information read [Managing classic infrastructure API keys](https://cloud.ibm.com/docs/account?topic=account-classic_keys).

1. At the IBM Cloud web console, go to **Manage** > **Access (IAM)** > **API keys**, and select **Classic infrastructure API keys** in the dropdown menu.
2. Click Create a classic infrastructure key. If you don't see this option, check to see if you already have a classic infrastructure API key that is created because you're only allowed to have one in the account per user.
3. Go to the actions menu (3 vertical dots) to select **Details**, then **Copy** the API Key.
4. Go to **Manage** > **Access (IAM)** > **Users**, then search and click on your user's name. Select **Details** at the right top corner to copy the **User ID** from the users info (it may be your email address).
5. The IBM Cloud Classic credentials also requires the IBM Cloud API, check the following section ([Setup Access to IBM Cloud VPC](#setup-access-to-ibm-cloud-vpc)) to set it.
6. Export the following environment variables to let the IBM Provider to retrieve the credentials.

Execute in a terminal:

```bash
export IAAS_CLASSIC_USERNAME="< Your IBM Cloud Username/Email here >"
export IAAS_CLASSIC_API_KEY="< Your IBM Cloud Classic API Key here >"
export IC_API_KEY="< IBM Cloud API Key >"
```

### Setup Access to IBM Cloud VPC

Follow these instructions to setup the **IBM Cloud API Key**, for more information read [Creating an API key](https://cloud.ibm.com/docs/account?topic=account-userapikey#create_user_key).

In a Terminal, execute the `ibmcloud` command to:

1. Login to IBM Cloud
2. Target a resource group
3. Create and get the API Key in a local file
4. Export the API Key in the environment variable `IC_API_KEY` to let the IBM Provider to retrieve the credentials.

The instructions to execute are:

```bash
ibmcloud login --sso
ibmcloud resource groups
ibmcloud target -g RESOURCE_GROUP_NAME

ibmcloud iam api-key-create TerraformKey -d "API Key for Terraform" --file ~/.ibm_api_key.json

export IC_API_KEY=$(grep '"apikey":' ~/.ibm_api_key.json | sed 's/.*: "\(.*\)".*/\1/')
# Or using jq:
export IC_API_KEY=$(jq -r .apikey ~/.ibm_api_key.json)
```

### Using the `credentials.sh` file

To not define the credentials for every new terminal, you can have the file `credentials.sh` exporting all the credentials like so:

```bash
export IAAS_CLASSIC_USERNAME="< Your IBM Cloud Username/Email here >"
export IAAS_CLASSIC_API_KEY="< Your IBM Cloud Classic API Key here >"
export IC_API_KEY="< IBM Cloud API Key >"
```

then execute the file like so:

```bash
source credentials.sh
```

**IMPORTANT**: If you use a different filename different to `credentials.sh` make sure to not commit the file to GitHub. The filename `credentials.sh` is in the `.gitignore` file so it's safe to use it, it won't be committed to GitHub.

You can instead append the previous `export` commands in your shell profile or config file (i.e. `~/.bashrc` or `~/.zshrc`) and they will be executed on every new terminal.

## Input Variables

Besides the access credentials the Terraform script requires the following input parameters, for some variables are instructions to get the possible values using `ibmcloud`.

| Name             | Description                                                                                                                                                                                                                       | Default          | Required |
| ---------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------- | -------- |
| `infra`          | IBM Cloud infrastructure to install the cluster. The available options are `classic` or `vpc`                                                                                                                                     | `classic`        | Yes      |
| `project_name`   | The project name is used to name the cluster with the environment name. It's also used to label the cluster and other resources                                                                                                   |                  | Yes      |
| `owner`          | Use your user name or team name. The owner is used to label the cluster and other resources                                                                                                                                       |                  | Yes      |
| `environment`    | The environment name is used to label the cluster and other resources                                                                                                                                                             | `dev`            | No       |
| `region`         | IBM Cloud region to host the cluster. List all available zones with: `ibmcloud is regions`                                                                                                                                        | `us-south`       | No       |
| `resource_group` | Resource Group in your account to host the cluster. List all available resource groups with: `ibmcloud resource groups`                                                                                                           | `Default`        | No       |
| `k8s_version`    | OpenShift version to install. List all available versions: `ibmcloud ks versions`, make sure it ends with `_OpenShift` otherwise you'll be installing an IKS cluster. Compare versions at: https://ibm.biz/iks-versions           | `4.4_openshift`  | No       |
| `kubeconfig_dir` | Directory to store the kubeconfig file after the cluster is built, by default is `./.kube/config` and the config file will be at `${kubeconfig_dir}/<ID>/config.yml`, where `<ID>` is a 70-ish long hash id defined by Terraform. | `./.kube/config` | No       |

The following input parameters are required only if the selected infrastructure is **IBM Cloud Classic** (`infra` = `classic`)

| Name                  | Description                                                                                                                                                                                             | Default    | Required |
| --------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------- | -------- |
| `datacenter`          | Datacenter or Zone in the IBM Cloud Classic region to provision the cluster. List all available zones with: `ibmcloud ks zone ls --provider classic`                                                    | `dal10`    | No       |
| `size`                | Cluster size, number of workers in the cluster.                                                                                                                                                         | `1`        | No       |
| `flavor`              | Flavor or Machine Type for the workers. List all available flavors in the zone: `ibmcloud ks flavors --zone dal10`                                                                                      | `b3c.4x16` | No       |
| `private_vlan_number` | Private VLAN assigned to your zone. List available VLAN's in the zone: `ibmcloud ks vlan ls --zone`, make sure the the VLAN type is `private` and the router begins with `bc`. Use the `ID` or `Number` | `2832804`  | No       |
| `public_vlan_number`  | Public VLAN assigned to your zone. List available VLAN's in the zone: `ibmcloud ks vlan ls --zone`, make sure the the VLAN type is `public` and the router begins with `fc`. Use the `ID` or `Number`   | `2832802`  | No       |

The following input parameters are required only if the selected infrastructure is **IBM Cloud VPC Gen 2** (`infra` = `vpc`)

| Name             | Description                                                                                                                                                                                                         | Default          | Required |
| ---------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------- | -------- |
| `vpc_zone_names` | Array with the sub-zones in the region, to create the workers groups. List all the zones with: `ibmcloud ks zone ls --provider vpc-gen2`. Example: `['us-south-1', 'us-south-2', 'us-south-3']`                     | `["us-south-1"]` | No       |
| `flavors`        | Array with the flavors or machine types of each the workers group. List all flavors for each zone with: `ibmcloud ks flavors --zone us-south-1 --provider vpc-gen2`. Example: `['mx2.4x32', 'mx2.8x64', 'cx2.4x8']` | `["mx2.4x32"]`   | No       |
| `workers_count`  | Array with the amount of workers on each workers group. Example: `[1, 3, 5]`                                                                                                                                        | `[2]`            | No       |

If you are using **Terraform 0.11** or setting the **Catalog Input Parameters**, the above input parameters will fail. Instead, use the following parameters, they are of type `string` having a lists of elements separated with commas. The Catalog (at this time) only accepts variables of primitive type, the Terraform type `list` is not accepted.

| Name                  | Description                                                                                                                                                                                                          | Default        | Required |
| --------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------- | -------- |
| `vpc_zone_names_list` | String with a list of sub-zones in the region, to create the workers groups. List all the zones with: `ibmcloud ks zone ls --provider vpc-gen2`. Example: `"us-south-1, us-south-2, us-south-3"`                     | `"us-south-1"` | No       |
| `flavors_list`        | String with a list of flavors or machine types of each the workers group. List all flavors for each zone with: `ibmcloud ks flavors --zone us-south-1 --provider vpc-gen2`. Example: `"mx2.4x32, mx2.8x64, cx2.4x8"` | `"mx2.4x32"`   | No       |
| `workers_count_list`  | String with a list of amount of workers on each workers group. Example: `"1, 3, 5"`                                                                                                                                  | `"2"`          | No       |

Check the sections [Cloud Pak for Multi Cloud Management (CP4MCM)](#cloud-pak-for-multi-cloud-management-cp4mcm) and [Cloud Pak for Applications (CP4Apps)](#cloud-pak-for-applications-cp4apps) for the input variables required to install such Cloud Paks.

To set the input parameters you can export the environment variables with the prefix `TF_VARS_`, like in the following example:

```bash
export TF_VAR_infra=vpc
```

Or, create the file `terraform.tfvars` defining the variables and its values like so:

```hcl
project_name        = "cp-sandbox"
owner               = "johandry"
region              = "us-south"
resource_group      = "cloud-pak-sandbox"
private_vlan_number = "2832804"
public_vlan_number  = "2832802"
```

The environment variables have preference over the variables in the `terraform.tfvars` file. Also, there is no need to set the value if you are ok with the variable default value.

## Output Variables

The module return the following output parameters.

| Name               | Description                                                                                                                         |
| ------------------ | ----------------------------------------------------------------------------------------------------------------------------------- |
| `cluster_endpoint` | The URL of the public service endpoint for your cluster                                                                             |
| `cluster_id`       | The unique identifier of the cluster.                                                                                               |
| `kubeconfig`       | File path to the kubernetes cluster configuration file. Execute `export KUBECONFIG=$(terraform output kubeconfig)` to use `kubectl` |

Check the sections [Cloud Pak for Multi Cloud Management (CP4MCM)](#cloud-pak-for-multi-cloud-management-cp4mcm) and [Cloud Pak for Applications (CP4Apps)](#cloud-pak-for-applications-cp4apps) for the output variables result of the installation such Cloud Paks.

## Provisioning with Terraform

You can use Terraform to execute the code locally for testing or if you are the only administrator of this infrastructure. After install or setup all the requirements and set the desired values to the [Input Variables](#input-variables), just like explained in the [Getting Started with Terraform](#getting-started-with-terraform), execute the following commands:

```bash
terraform init
terraform plan
terraform apply
```

The cluster should be available in about **20 to 30 minutes**. Then execute the validation commands or actions documented in the [Validation](#validation) section below.

Finally, when you finish using the infrastructure, cleanup everything you created with the execution of:

```bash
terraform destroy
```

The cluster destruction should finish in about **10 minutes**.

## Provisioning with Schematics

For group development and testing it is recommended to use Schematics to provision the OpenShift cluster. The Terraform state of the cluster is shared with the team and the management of the cluster can be done in the IBM Web Console by any team member.

There are two ways to execute the Schematics workspace, using IBM Cloud Web Console or CLI. However, the creation of the workspace is recommended to do it using the CLI, to automate the process and facilitate the maintenance.

To create the Schematics workspace set the following required values (`OWNER`, `PROJECT`, `ENV`, `ENTITLED_KEY` and `ENTITLED_KEY_EMAIL`) in the `workspace.json` file using the `workspace.tmpl.json` as a template:

```bash
PROJECT=cp-mcm
OWNER=$USER
ENV=sandbox
ENTITLED_KEY_EMAIL=< The Email Address owner of the Entitled Key >
ENTITLED_KEY=< Your Entitled Key >
# Or:
ENTITLED_KEY=$(cat entitlement.key)

sed \
  -e "s|{{ PROJECT }}|$PROJECT|" \
  -e "s|{{ OWNER }}|$OWNER|" \
  -e "s|{{ ENV }}|$ENV|" \
  -e "s|{{ ENTITLED_KEY }}|$ENTITLED_KEY|" \
  -e "s|{{ ENTITLED_KEY_EMAIL }}|$ENTITLED_KEY_EMAIL|" \
  workspace.tmpl.json > workspace.json
```

Open the `workspace.json` file to modify (if needed) the value of the parameters located in `.template_data[].variablestore[]`. Use the `ibmcloud` command to identify the values, as explained in the [Input Variables](#input-variables) section and on each variable description.

Confirm in the `workspace.json` file the GitHub URL to the Terraform code in `.template_repo.url`. This URL could be in a the master branch, a different branch, tag or folder.

Create the workspace executing the following commands:

```bash
ibmcloud schematics workspace list
ibmcloud schematics workspace new --file workspace.json
ibmcloud schematics workspace list
```

Wait until the workspace status is set to **INACTIVE**. If something goes wrong you can update the workspace or delete it and create it with the correct parameters. To delete it use the command:

```bash
ibmcloud schematics workspace delete --id WORKSPACE_ID
```

Once the workspace is created and with status **INACTIVE**, it's ready to apply the terraform code, either by using the IBM Cloud Web Console (recommended) or the CLI.

### Using the IBM Cloud Web Console

1. In the IBM Cloud Web Console go to: **Navigation Menu** (_top left corner_) > **Schematics**. Click on the workspace named **roks_cluster_PROJECT**
2. Click on **Generate plan** button, then click on **View log** link and wait until it's completed.
3. Click on the **Apply plan** button, then click on the **View log** link.
4. On the left side menu check the **Resources** item, to see all the resources created or modified from the workspace.

### Using the IBM Cloud CLI

```bash
ibmcloud schematics workspace list           # Identify the WORKSPACE_ID
WORKSPACE_ID=

# (Optional) Planing:
ibmcloud schematics plan --id $WORKSPACE_ID  # Identify the Activity_ID
ibmcloud schematics logs --id $WORKSPACE_ID --act-id Activity_ID

# Apply:
ibmcloud schematics apply --id $WORKSPACE_ID # Identify the Activity_ID
ibmcloud schematics logs  --id $WORKSPACE_ID --act-id Activity_ID
```

### Cleanup

To destroy the Schematics created resources and the workspace execute the following commands:

```bash
ibmcloud schematics destroy --id $WORKSPACE_ID # Identify the Activity_ID
ibmcloud schematics logs  --id $WORKSPACE_ID --act-id Activity_ID

# ... wait until it's done

ibmcloud schematics workspace delete --id $WORKSPACE_ID
ibmcloud schematics workspace list
```

## Provisioning with IBM Cloud CLI

The creation of the cluster using the IBM Cloud CLI may not be the best option but you can use it if there is a problem with Terraform or Schematics.

Using the `ibmcloud` command and the `kubernetes-service` plugin, execute:

- On **IBM Cloud Classic**:

  ```bash
  export IAAS_CLASSIC_USERNAME="< Your IBM Cloud Username/Email here >"
  export IAAS_CLASSIC_API_KEY="< Your IBM Cloud Classic API Key here >"

  export PROJECT_NAME="cp-sandbox"

  ibmcloud ks versions | grep _OpenShift
  export VERSION="4.4_openshift"

  ibmcloud ks zone ls --provider classic
  export ZONE="dal10"

  ibmcloud ks flavors --zone $ZONE
  export FLAVOR="b3c.4x16"

  ibmcloud ks vlan ls --zone $ZONE
  export PUB_VLAN="2832802"
  export PRIV_VLAN="2832804"

  export CLUSTER_NAME="${PROJECT_NAME}-cluster"
  export SIZE=1

  ibmcloud ks cluster create classic \
            --name $CLUSTER_NAME \
            --version $VERSION \
            --zone $ZONE \
            --flavor $FLAVOR \
            --workers $SIZE \
            --entitlement cloud_pak \
            --private-vlan $PUB_VLAN \
            --public-vlan $PRIV_VLAN

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
  export VERSION="4.4_openshift"

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

## Validation

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

## Cloud Pak Entitlement Key

CloudPack requires to have an Entitlement Key, get it from https://myibm.ibm.com/products-services/containerlibrary and copy the content of the key into the variable `entitled_registry_key` or download the key into a file (i.e. `entitlement.key`) and set the file path into the variable `entitled_registry_key_file`. Edit the `terraform.tfvars` with either of the following lines. The IBM Cloud user email address is required in the variable `entitled_registry_user_email` to access the IBM Cloud Container Registry (ICR), set the user email address of the account used to generate the Entitlement Key into this variable.

For example:

```hcl
entitled_registry_user_email = "johandry.amador@ibm.com"

entitled_registry_key        = "< Your Entitled Key here>"
// Or:
entitled_registry_key_file   = "./entitlement.key"
```

**IMPORTANT**: Make sure to not commit the Entitlement Key file or content to the github repository.

## Cloud Pak for Multi Cloud Management (CP4MCM)

CloudPak for Multi Cloud Management is disabled by default, if you want to install it, set the variable `with_cp4mcm` to `true`, like this in the `terraform.tfvars`.

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

If you are using Schematics or the Catalog, the variable to use is only `entitled_registry_key` with the content of the Entitlement Key, the variable `entitled_registry_key_file` is not available.

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

## Cloud Pak for Applications (CP4Apps)

CloudPak for Applications is disabled by default, if you want to install it, set the variable `with_cp4app` to `true`, like this in the `terraform.tfvars`.

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

### CP4MCM Validation

Execute the following commands to validate MCM:

```bash
export KUBECONFIG=$(terraform output config_file_path)

kubectl cluster-info

# Namespace
kubectl get namespaces $(terraform output cp4app_namespace)
```

**TODO**: Complete the instructions to install CP4App
