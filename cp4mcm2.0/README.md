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

`git clone https://github.com/ibm-pett/cloud-pak-sandboxes.git`

# Script Instructions

```
cd cloud-pak-sandboxes/cp4mcm2.0
chmod +x install.sh
./install.sh
```
# Details
- User is prompted for entitlement key, email, and to provide existing OCP Cluster or create one
- If creating 

  - user is prompted for cluster name, flavor, number of nodes, zone, private vlan and public vlan details
  - User is prompted to locate their entitlement key and their docker email address to be used to connect to the docker registry
  - Cluster is provisioned
  
When cluster is complete, operator resources are installed and invoked to install MCM 2.0

Note: Cloud Shell may sometimes time out if it doesn't have activity happening. If the script dies before starting the MCM installation, you may need to restart a cloud shell, clone the repo again, then restart the script and add the newly created cluster name to use to install on.
# Verify that MCM installed
Note: it can take up to an hour for all pods to start up.  During the installation process, you will see pods starting and stopping until they all start in the proper order.

To verify that MCM installed properly:
1) log into IBM Cloud
2) set to the correct account
3) open the resource list from top menu
4) find the OpenShift cluster you created
5) open the cluster information
6) launch the OpenShift Web Console from botton at the top
7) on OpenShift Console, under "Operators", "Installed Operators", there should be an entry for "IBM Cloud Pak for Multicloud Manager".  Open this and under "Installations" you should see "ibm-management" running.
8) under "Workloads", "Pods" look to see that there aren't any in Pending, Terminating, CrashLoopBackOff state.  
# Retrieving the MCM Console information
To monitor progress:
`kubectl get pods -A | grep -Ev "Completed|1/1|2/2|3/3|4/4|5/5|6/6|7/7"`

This should not return anything when MCM is up and running

To get the URL to get to the Multicloud Management Console:
```
ibmcloud oc cluster config -c cp4mcm-script-test --admin
kubectl get route -n ibm-common-services cp-console -o jsonpath=‘{.spec.host}’ && echo
```
To get default login id:
```
kubectl -n ibm-common-services get secret platform-auth-idp-credentials -o jsonpath='{.data.admin_username}\' | base64 -D && echo
```
To get default Password:
```
kubectl -n ibm-common-services get secret platform-auth-idp-credentials -o jsonpath='{.data.admin_password}' | base64 -D && echo
```
  
