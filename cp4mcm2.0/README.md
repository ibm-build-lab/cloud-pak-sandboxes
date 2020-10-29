# Description

This script installs Multi Cloud Management Cloud Pak version 2.0 on an OpenShift cluster on IBM Cloud.  It prompts for inputs to install or use an existing OCP cluster then waits for the cluster to provision and installs MCM.

# Files

_install.sh_: runs through installation

_resources.yaml_: contains the yaml necessary to create the CatalogSource resources for MCM

_installation.yaml_: contains yaml to create the installation

# Running from Cloud Shell on IBM Cloud

Launch a cloud shell by clicking on the terminal icon at the top right area on IBM Cloud console once you have logged into IBM Cloud. Run these commands:
```
git clone https://github.com/ibm-pett/cloud-pak-sandboxes.git
cd cloud-pak-sandboxes/cp4mcm2.0
chmod +x install.sh
./install.sh
```
# Details
- User is prompted for entitlement key, email, and to provide existing OCP Cluster name or create one
- If creating a cluster

  - User is prompted for cluster name, zone, private vlan and public vlan details
  - Cluster is provisioned
  
- MCM operator resources are installed and invoked
  - NOTE: You will like see this message several times as these resources get created.  Just ignore it:
  ```
  NAME                          PACKAGE                       SOURCE                        CHANNEL
  ibm-management-orchestrator   ibm-management-orchestrator   ibm-management-orchestrator   2.0-stable
  Error from server (NotFound): subscriptions.operators.coreos.com "ibm-common-service-operator-stable-v1-opencloud-operators-openshift-marketplace" not found
  Error from server (NotFound): subscriptions.operators.coreos.com "operand-deployment-lifecycle-manager-app" not found
  ```

Note: Cloud shell may sometimes time out during this process. If the script dies before starting the MCM installation, you may need to restart a cloud shell, clone the repo again, then restart the script and add the newly created cluster name to use to install on.
# Verify that MCM installed
Note: it can take up to an hour for all pods to start up.  During the installation process, you will see pods starting and stopping until they all start in the proper order.

To monitor progress, from Cloud Shell:
```
ibmcloud oc cluster config -c <cluster-name> --admin
kubectl get pods -A | grep -Ev "Completed|1/1|2/2|3/3|4/4|5/5|6/6|7/7"
```
To verify that MCM installed properly:
1) log into IBM Cloud
2) set to the correct account
3) open the resource list from top menu
4) find the OpenShift cluster you created
5) open the cluster information
6) launch the OpenShift Web Console from botton at the top
7) on OpenShift Console, under "Operators", "Installed Operators", there should be an entry for "IBM Cloud Pak for Multicloud Manager".  Open this and under "Installations" you should see "ibm-management" running.
8) under "Workloads", "Pods" look to see that there aren't any in Pending, Terminating, CrashLoopBackOff state.  

This should not return anything when MCM is up and running
# Retrieving the MCM Console information

To get the Multicloud Management Console URL, open a Cloud Shell and issue the following commands:
```
ibmcloud oc cluster config -c <cluster-name> --admin
kubectl get route -n ibm-common-services cp-console -o jsonpath=‘{.spec.host}’ && echo
```
To get default login id:
```
kubectl -n ibm-common-services get secret platform-auth-idp-credentials -o jsonpath='{.data.admin_username}\' | base64 -di && echo
```
To get default Password:
```
kubectl -n ibm-common-services get secret platform-auth-idp-credentials -o jsonpath='{.data.admin_password}' | base64 -di && echo
```
  
