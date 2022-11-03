# Cloud Pak for Watson AIOps 

## Requirements

Make sure all requirements listed [here](../README.md#requirements) are completed.

## Configure Access to IBM Cloud

Make sure access to IBM Cloud is set up.  Go [here](../README.md#configure-access-to-ibm-cloud) for details.

## Cloud Pak Entitlement Key

This Cloud Pak requires an Entitlement Key. It can be retrieved from https://myibm.ibm.com/products-services/containerlibrary.

Edit the `./my_variables.auto.tfvars` file to define the `entitled_registry_user_email` variable and optionally the variable `entitled_registry_key` or save the entitlement key in the file `entitlement.key`. The IBM Cloud user email address is required in the variable `entitled_registry_user_email` to access the IBM Cloud Container Registry (ICR), set the user email address of the account used to generate the Entitlement Key.

For example:

```hcl
entitled_registry_user_email = "john.smith@ibm.com"

# Optionally:
entitled_registry_key        = "< Your Entitled Key here >"
```

**IMPORTANT**: Make sure to not commit the Entitlement Key file or content to the github repository.

## Provisioning the Sandbox

For instructions to provision the sandbox, go [here](../README.md#provisioning-the-sandbox).

## Requirements for AIOps

Please ensure your cluster is setup to install AIManager and Eventmanager: `9` nodes.

Current min spec requires:
- 3 nodes for AIManager    @ 16x64
- 6 nodes for EventManager @ 16x64

## Input Parameters

In addition, the Terraform code requires the following input parameters, for some variables are instructions to get the possible values using `ibmcloud`.

roks_version = "4.7"
entitlement = "cloud_pak"
flavors = ["b3c.16x64"]
workers_count = [9]

Name                             | Type   | Description                                                                                                                                        | Sensitive | Default
-------------------------------- | ------ | -------------------------------------------------------------------------------------------------------------------------------------------------- | --------- | ----------------------------
ibmcloud_api_key                 |        | IBMCloud API key (https://cloud.ibm.com/docs/account?topic=account-userapikey                                                                      | true      | 
project_name                 |    string    | The project name is used to name the cluster with the environment name. It's also used to label the cluster and other resources                                                                      |       | 
owner                 |     string   | Use your user name or team name. The owner is used to label the cluster and other resources                                                                      |       | anonymous
environment                 |        | The environment name is used to label the cluster and other resources                                                                      |       | sandbox
cluster_name_or_id               |        | Id of the cluster for AIOps to be installed on. If you do not have one, keep this value `empty`                                                                                                        |           | 
roks_version                 |    string    | ROKS version                                                                      | true      | 4.7
entitlement                 |        | If you are using the cloud pak entitlement use `cloud_pak`                                                                      |       | 
flavors                 |   string[]     | IBM Cloud ROKS flavor                                                                      |       | ["b3c.16x64"]
workers_count                 |    int[]    | Number of worker nodes                                                                |       | [9]
datacenter                 |        | On IBM Cloud Classic this is the datacenter or Zone in the region to provision the cluster. List all available zones with: `ibmcloud ks zone ls --provider classic`                                                                      |       | dal10
private_vlan_number                 |        | Private VLAN assigned to your zone. List available VLANs in the zone: `ibmcloud ks vlan ls --zone`, make sure the the VLAN type is private and the router begins with **bc**. Use the ID or Number. This value may be empty if there isn't any VLAN in the Zone, however this may cause issues if the code is applied again.                                                                      | true      | 
public_vlan_number                 |        | Public VLAN assigned to your zone. List available VLANs in the zone: `ibmcloud ks vlan ls --zone`, make sure the the VLAN type is public and the router begins with **fc**. Use the ID or Number. This value may be empty if there isn't any VLAN in the Zone, however this may cause issues if the code is applied again.                                                                 | true      | 
region                           |        | IBM Cloud region to host the cluster. List all available zones with: `ibmcloud is regions`                                                                                                                     |           | us-south
resource_group_name              |        | Resource group that cluster resides in                                                                                                             |           | cloud-pak-sandbox-ibm
enable                           |        | If set to true installs Cloud-Pak for Data on the given cluster                                                                                    |           | true
cluster_config_path              |        | Path to the Kubernetes configuration file to access your cluster                                                                                   |           | 
on_vpc                           | bool   | If set to true, lets the module know cluster is using VPC Gen2                                                                                     |           | false
portworx_is_ready                | any    |                                                                                                                                                    |           | null
entitled_registry_key            |        | Get the entitlement key from https://myibm.ibm.com/products-services/containerlibrary                                                              |           | 
entitled_registry_user_email     |        | Required: Email address of the user owner of the Entitled Registry Key                                                                             |           | 
namespace                        |        | Namespace for Cloud Pak for AIOps                                                                                                                  |           | cpaiops
accept_aimanager_license             | bool   | Do you accept the licensing agreement for AI Manager? `T/F`                                                                                             |           | false
accept_event_manager_license             | bool   | Do you accept the licensing agreement for Event Manager? `T/F`                                                                                             |           | false
enable_aimanager                 | bool   | Install AIManager? `T/F`                                                                                                                           |           | true
enable_event_manager             | bool   | Install Event Manager? `T/F`                                                                                                                       |           | true

**NOTE** The boolean input variable `enable` is used to enable/disable the module. This parameter may be deprecated when Terraform 0.12 is not longer supported. In Terraform 0.13, the block parameter `count` can be used to define how many instances of the module are needed. If set to zero the module won't be created.

For an example of how to put all this together, refer to our [Cloud Pak for Watson AIOps Terraform script](https://github.com/ibm-build-lab/cloud-pak-sandboxes/tree/master/terraform/cp4aiops).

## Event Manager Options

Name                             | Type   | Description                                                                                                                                        | Sensitive | Default
-------------------------------- | ------ | -------------------------------------------------------------------------------------------------------------------------------------------------- | --------- | ----------------------------
enable_persistence               | bool   | Enables persistence storage for kafka, cassandra, couchdb, and others. Default is `true`                                                           |           | true
humio_repo                       | string | To enable Humio search integrations, provide the Humio Repository for your Humio instance                                                          |           | 
humio_url                        | string | To enable Humio search integrations, provide the Humio Base URL of your Humio instance (on-prem/cloud)                                             |           | 
ldap_port                        | number | Configure the port of your organization's LDAP server.                                                                                             |           | 3389
ldap_mode                        | string | Choose `standalone` for a built-in LDAP server or `proxy` and connect to an external organization LDAP server. See http://ibm.biz/install_noi_icp. |           | standalone
ldap_storage_class               | string | LDAP Storage class - note: only needed for `standalone` mode                                                                                       |           | 
ldap_user_filter                 | string | LDAP User Filter                                                                                                                                   |           | uid=%s,ou=users
ldap_bind_dn                     | string | Configure LDAP bind user identity by specifying the bind distinguished name (bind DN).                                                             |           | cn=admin,dc=mycluster,dc=icp
ldap_ssl_port                    | number | Configure the SSL port of your organization's LDAP server.                                                                                         |           | 3636
ldap_url                         | string | Configure the URL of your organization's LDAP server.                                                                                              |           | ldap://localhost:3389
ldap_suffix                      | string | Configure the top entry in the LDAP directory information tree (DIT).                                                                              |           | dc=mycluster,dc=icp
ldap_group_filter                | string | LDAP Group Filter                                                                                                                                  |           | cn=%s,ou=groups
ldap_base_dn                     | string | Configure the LDAP base entry by specifying the base distinguished name (DN).                                                                      |           | dc=mycluster,dc=icp
ldap_server_type                 | string | LDAP Server Type. Set to `CUSTOM` for non Active Directory servers. Set to `AD` for Active Directory                                               |           | CUSTOM
continuous_analytics_correlation | bool   | Enable Continuous Analytics Correlation                                                                                                            |           | false
backup_deployment                | bool   | Is this a backup deployment?                                                                                                                       |           | false
zen_deploy                       | bool   | Flag to deploy NOI cpd in the same namespace as aimanager                                                                                          |           | false
zen_ignore_ready                 | bool   | Flag to deploy zen customization even if not in ready state                                                                                        |           | false
zen_instance_name                | string | Application Discovery Certificate Secret (If Application Discovery is enabled)                                                                     |           | iaf-zen-cpdservice
zen_instance_id                  | string | ID of Zen Service Instance                                                                                                                         |           | 
zen_namespace                    | string | Namespace of the ZenService Instance                                                                                                               |           | 
zen_storage                      | string | The Storage Class Name                                                                                                                             |           | 
enable_app_discovery             | bool   | Enable Application Discovery and Application Discovery Observer                                                                                    |           | false
ap_cert_secret                   | string | Application Discovery Certificate Secret (If Application Discovery is enabled)                                                                     |           | 
ap_db_secret                     | string | Application Discovery DB2 secret (If Application Discovery is enabled)                                                                             |           | 
ap_db_host_url                   | string | Application Discovery DB2 host to connect (If Application Discovery is enabled)                                                                    |           | 
ap_secure_db                     | bool   | Application Discovery Secure DB connection (If Application Discovery is enabled)                                                                   |           | false
enable_network_discovery         | bool   | Enable Network Discovery and Network Discovery Observer                                                                                            |           | false
obv_alm                          | bool   | Enable ALM Topology Observer                                                                                                                       |           | false
obv_ansibleawx                   | bool   | Enable Ansible AWX Topology Observer                                                                                                               |           | false
obv_appdynamics                  | bool   | Enable AppDynamics Topology Observer                                                                                                               |           | false
obv_aws                          | bool   | Enable AWS Topology Observer                                                                                                                       |           | false
obv_azure                        | bool   | Enable Azure Topology Observer                                                                                                                     |           | false
obv_bigfixinventory              | bool   | Enable BigFixInventory Topology Observer                                                                                                           |           | false
obv_cienablueplanet              | bool   | Enable CienaBluePlanet Topology Observer                                                                                                           |           | false
obv_ciscoaci                     | bool   | Enable CiscoAci Topology Observer                                                                                                                  |           | false
obv_contrail                     | bool   | Enable Contrail Topology Observer                                                                                                                  |           | false
obv_dns                          | bool   | Enable DNS Topology Observer                                                                                                                       |           | false
obv_docker                       | bool   | Enable Docker Topology Observer                                                                                                                    |           | false
obv_dynatrace                    | bool   | Enable Dynatrace Topology Observer                                                                                                                 |           | false
obv_file                         | bool   | Enable File Topology Observer                                                                                                                      |           | true
obv_googlecloud                  | bool   | Enable GoogleCloud Topology Observer                                                                                                               |           | false
obv_ibmcloud                     | bool   | Enable IBMCloud Topology Observer                                                                                                                  |           | false
obv_itnm                         | bool   | Enable ITNM Topology Observer                                                                                                                      |           | false
obv_jenkins                      | bool   | Enable Jenkins Topology Observer                                                                                                                   |           | false
obv_junipercso                   | bool   | Enable JuniperCSO Topology Observer                                                                                                                |           | false
obv_kubernetes                   | bool   | Enable Kubernetes Topology Observer                                                                                                                |           | true
obv_newrelic                     | bool   | Enable NewRelic Topology Observer                                                                                                                  |           | false
obv_openstack                    | bool   | Enable OpenStack Topology Observer                                                                                                                 |           | false
obv_rancher                      | bool   | Enable Rancher Topology Observer                                                                                                                   |           | false
obv_rest                         | bool   | Enable Rest Topology Observer                                                                                                                      |           | true
obv_servicenow                   | bool   | Enable ServiceNow Topology Observer                                                                                                                |           | true
obv_taddm                        | bool   | Enable TADDM Topology Observer                                                                                                                     |           | false
obv_vmvcenter                    | bool   | Enable VMVcenter Topology Observer                                                                                                                 |           | true
obv_vmwarensx                    | bool   | Enable VMWareNSX Topology Observer                                                                                                                 |           | false
obv_zabbix                       | bool   | Enable Zabbix Topology Observer                                                                                                                    |           | false
enable_backup_restore            | bool   | Enable Analytics Backups                                                                                                                           |           | false

## Output Parameters

The Terraform code return the following output parameters.

| Name                | Description                                                                                                                         |
| ------------------- | ----------------------------------------------------------------------------------------------------------------------------------- |
| `cluster_endpoint`  | The URL of the public service endpoint for your cluster                                                                             |
| `cluster_id`        | The unique identifier of the cluster.                                                                                               |
| `cluster_name`      | The cluster name which should be: `{project_name}-{environment}-cluster`                                                            |
| `resource_group`    | Resource group where the OpenShift cluster is created                                                                               |
| `kubeconfig`        | File path to the kubernetes cluster configuration file. Execute `export KUBECONFIG=$(terraform output kubeconfig)` to use `kubectl` |
| `cp4aiops_aiman_url`        | Access your Cloud Pak for AIOPS AIManager deployment at this URL. |
| `cp4aiops_aiman_user`       | Username for your Cloud Pak for AIOPS AIManager deployment. |
| `cp4aiops_aiman_password`   | Password for your Cloud Pak for AIOPSAIManager  deployment. |
| `cp4aiops_evtman_url`       | Access your Cloud Pak for AIOP EventManager deployment at this URL. |
| `cp4aiops_evtman_user`      | Username for your Cloud Pak for AIOPS EventManager deployment. |
| `cp4aiops_evtman_password`  | Password for your Cloud Pak for AIOPS EventManager deployment. |
## Validations

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

Execute the following commands to validate this cloud pak:

```bash
export KUBECONFIG=$(terraform output config_file_path)

kubectl cluster-info

# Namespace
kubectl get namespaces $(terraform output cp4i_namespace)

# All resources
kubectl get all --namespace $(terraform output cp4i_namespace)
```

Using the following credentials:

```bash
terraform output cp4i_user
terraform output cp4i_password
```

Open the following URL:

```bash
open $(terraform output cp4i_endpoint)
```

## Uninstall

**Note**: The uninstall/cleanup process is a work in progress at this time, we are identifying the objects that need to be deleted in order to have a successful re-installation.
