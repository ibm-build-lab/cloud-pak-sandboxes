# Cloud Pak for Business Automation 

## Requirements

Make sure all requirements listed [here](https://github.com/ibm-hcbt/cloud-pak-sandboxes/blob/master/terraform/README.md#requirements) are completed.

## Configure Access to IBM Cloud

Make sure access to IBM Cloud is set up.  Go [here](https://github.com/ibm-hcbt/cloud-pak-sandboxes/blob/master/terraform/README.md#configure-access-to-ibm-cloud) for details.

## Cloud Pak Entitlement Key

This Cloud Pak requires an Entitlement Key. It can be retrieved from https://myibm.ibm.com/products-services/containerlibrary.

Edit the `./my_variables.auto.tfvars` file to define the `entitled_registry_user_email` variable and optionally the variable `entitlement_key` or save the entitlement key in the file `entitlement.key`. The IBM Cloud user email address is required in the variable `entitled_registry_user_email` to access the IBM Cloud Container Registry (ICR), set the user email address of the account used to generate the Entitlement Key.

For example:

```hcl
entitled_registry_user_email = "john.smith@ibm.com"

# Optionally:
entitled_registry_key        = "< Your Entitled Key here >"
```

**IMPORTANT**: Make sure to not commit the Entitlement Key file or content to the github repository.

## Provisioning the Sandbox

For instructions to provision the sandbox, go
[here](https://github.com/ibm-hcbt/cloud-pak-sandboxes/blob/master/terraform/README.md#provisioning-the-sandbox).

## Input Parameters
In addition, the Terraform code requires the following input parameters,
for some variables are instructions to get the possible values using
`ibmcloud`.

| Name                               | Description                                                                                                                                                                                                                | Default                     | Required |
| ---------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------- | -------- |
| `ibmcloud_api_key`                 | IBM Cloud API key (https://cloud.ibm.com/docs/account?topic=account-userapikey#create_user_key)                                                                                                                            |                             | Yes      |
| `resource_group`                   | Region where the cluster is created. Managing resource groups: (https://cloud.ibm.com/docs/account?topic=account-rgs&interface=ui)                                                                                         | 'default`                   | Yes      |
| `region`                           | Region code (https://cloud.ibm.com/docs/codeengine?topic=codeengine-regions)                                                                                                                                               | `us-south`                  | Yes      |
| `enable`                           | If set to `false` does not install the cloud pak on the given cluster. By default it's enabled                                                                                                                             | `true`                      | No       |
| `cluster_config_path`              | Path to the Kubernetes configuration file to access your cluster                                                                                                                                                           | `./.kube/config`            | No       |
| `ingress_subdomain`                | Run the command `ibmcloud ks cluster get -c <cluster_name_or_id>` to get the Ingress Subdomain value                                                                                                                       |                             | No       |
| `ldap_admin`                       | LDAP Admin user name                                                                                                                                                                                                       | `cn=root`                   | Yes      |
| `ldap_password`                    | LDAP Admin password                                                                                                                                                                                                        | `Passw0rd`                  | Yes      |
| `ldap_host_ip`                     | LDAP server IP address                                                                                                                                                                                                     |                             | Yes      |
| `db2_project_name`                 | The namespace/project for Db2                                                                                                                                                                                              | `ibm-db2`                   | Yes      |
| `db2_admin_password`               | Admin user name defined in associated LDAP                                                                                                                                                                                 | `cpadmin`                   | Yes      |
| `db2_admin_username`               | User name defined in associated LDAP                                                                                                                                                                                       | `db2inst1`                  | Yes      |
| `db2_host_name`                    | Host for DB2 instance                                                                                                                                                                                                      |                             | Yes      |
| `db2_host_port_number`             | Port for DB2 instance                                                                                                                                                                                                      |                             | Yes      |
| `db2_host_ip`                      | IP address for the Db2                                                                                                                                                                                                     |                             | Yes      |
| `db2_standard_license_key`         | The standard license key for the Db2 database product                                                                                                                                                                      |                             | Yes      |
| `cp4ba_project_name`               | Namespace to install for Cloud Pak for Business Automation                                                                                                                                                                 | `cp4ba`                     | Yes      |
| `entitled_registry_key`            | Get the entitlement key from https://myibm.ibm.com/products-services/containerlibrary and assign it to this variable. Optionally you can store the key in a file and use the `file()` function to get the file content/key |                             | Yes      |
| `entitled_registry_user_email`     | IBM Container Registry (ICR) username which is the email address of the owner of the Entitled Registry Key. i.e: joe@ibm.com                                                                                               |                             | Yes      |


## Output Parameters

The Terraform code return the following output parameters.

| Name               | Description                                                                                                                        |
| ------------------ | -----------------------------------------------------------------------------------------------------------------------------------|
| `cluster_endpoint` | The URL of the public service endpoint for your cluster                                                                            |
| `cluster_id`       | The unique identifier of the cluster.                                                                                              |
| `cluster_name`     | The cluster name which should be: `{project_name}-{environment}-cluster`                                                           |
| `resource_group`   | Resource group where the OpenShift cluster is created                                                                              |
| `kubeconfig`       | File path to the kubernetes cluster configuration file. Execute `export KUBECONFIG=$(terraform output kubeconfig)` to use `kubectl`|
| `db2_host_name`    | Host name of Db2 instance                                                                                                          |
| `db2_host_ip`      | IP address for the Db2                                                                                                             |
| `db2_port_number`  | Port for Db2 instance                                                                                                              |
| `db2_standard_license_key`  | The standard license key for the Db2 database product                                                                     |
| `cp4ba_endpoint`   | URL of the CP4BA dashboard                                                                                                         |
| `cp4ba_user`       | Username to login to the CP4BA dashboard                                                                                           |
| `cp4ba_password`   | Password to login to the CP4BA dashboard                                                                                           |



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
kubectl get namespaces $(terraform output cp4ba)

# All resources
kubectl get all --namespace $(terraform output cp4ba)
```

Using the following credentials:

```bash
terraform output cp4ba_user
terraform output cp4ba_password
```

Open the following URL:

```bash
open $(terraform output cp4ba_endpoint)
```

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


