# Installation steps for GA version of IAF

- [Installation steps for GA version of IAF](#installation-steps-for-ga-version-of-iaf)
  - [Log into cloud account](#log-into-cloud-account)
  - [Install Prereqs](#install-prereqs)
    - [1. Enable IBM Operator Catalog](#1-enable-ibm-operator-catalog)
    - [2. Install Common Services](#2-install-common-services)
    - [3. Set Pull Secrets by running pre-install.sh](#3-set-pull-secrets-by-running-pre-installsh)
    - [4. Prerequisites for installing AI components (optional)](#4-prerequisites-for-installing-ai-components-optional)
  - [Install IAF](#install-iaf)
  - [Create Instance of Automation Foundation (Optional)](#create-instance-of-automation-foundation-optional)
  - [Install Demo Cartridge (Optional)](#install-demo-cartridge-optional)
    - [1. Ensure that pull secrets are set](#1-ensure-that-pull-secrets-are-set)
    - [2. Set up Image Mirroring](#2-set-up-image-mirroring)
    - [3. Create Demo Cartridge Catalog Source](#3-create-demo-cartridge-catalog-source)
    - [4. Verify the Zen dashboard](#4-verify-the-zen-dashboard)
  - [Additional references](#additional-references)
  
## Log into cloud account

In a terminal window, execute:

```bash
ibmcloud login --sso
```

or open an IBM Cloud Shell window on the Cloud account and

Target resource group:

```bash
ibmcloud target -g <resource-group>
```

Gain access to the OCP cluster:

```bash
ibmcloud oc cluster config -c <openshift-cluster> --admin
```

## Install Prereqs

### 1. [Enable IBM Operator Catalog](https://github.com/IBM/cloud-pak/blob/master/reference/operator-catalog-enablement.md)

Cleanup previously installed Catalog Source:

```bash
oc -n openshift-marketplace delete CatalogSource ibm-operator-catalog --ignore-not-found
```

Install Catalog Source:

```bash
cat << EOF | kubectl apply -n openshift-marketplace -f -
apiVersion: operators.coreos.com/v1alpha1
kind: CatalogSource
metadata:
    name: ibm-operator-catalog
    namespace: openshift-marketplace
spec:
    displayName: IBM Operator Catalog
    publisher: IBM
    sourceType: grpc
    image: docker.io/ibmcom/ibm-operator-catalog
    updateStrategy:
      registryPoll:
        interval: 45m
EOF
```

Verify Install

```console
oc get catalogsource -n openshift-marketplace | grep IBM
```

### 2. [Install Common Services](https://www.ibm.com/support/knowledgecenter/SSHKN6/installer/3.x.x/install_cs_cli.html)

Cleanup previously installed Catalog Source:

```bash
oc -n openshift-marketplace delete CatalogSource opencloud-operators --ignore-not-found
```

Install Common Services (Bedrock):

```bash
cat << EOF | kubectl apply -n openshift-marketplace -f -
apiVersion: operators.coreos.com/v1alpha1
kind: CatalogSource
metadata:
  name: opencloud-operators
  namespace: openshift-marketplace
spec:
  displayName: IBMCS Operators
  publisher: IBM
  sourceType: grpc
  image: docker.io/ibmcom/ibm-common-service-catalog:latest
  updateStrategy:
    registryPoll:
      interval: 45m
EOF
```

After a few minutes, verify operator installation:

```bash
oc -n openshift-marketplace get catalogsource opencloud-operators -o jsonpath="{.status.connectionState.lastObservedState}"
```

Should say `READY`.

### 3. Set Pull Secrets by running pre-install.sh

- Copy the _template-iafenv.config to iafenv.config and set the required values

- Source ./iafenv.config

- Run the [pre-install.sh](./pre-install.sh) script

### 4. Prerequisites for installing AI components (optional)

Go [here](https://www.ibm.com/support/knowledgecenter/SSUJN4_ent/install/prerequisites.html?view=kc#prerequisites-for-installing-ai-components) for details.

## [Install IAF](https://www.ibm.com/support/knowledgecenter/SSUJN4_ent/install/installing.html)

Verify prerequisites:

```bash
oc get catalogsource -n openshift-marketplace | grep IBM
oc get pods -n openshift-marketplace | grep opencloud-operators
oc get pods -n openshift-marketplace | grep ibm-operator
```

Run the following commands to set up for installation:

```bash
export IAF_PROJECT=<project to install IAF>
oc new-project ${IAF_PROJECT}
```

Create an `OperatorGroup`:

```bash
cat << EOF | oc apply -f -
apiVersion: operators.coreos.com/v1alpha2
kind: OperatorGroup
metadata:
  name: iaf-group
  namespace: ${IAF_PROJECT}
spec:
  targetNamespaces:
  - ${IAF_PROJECT}
EOF
```

Create a `Subscription`:

```bash
cat << EOF | oc apply -f -
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: ibm-automation
  namespace: ${IAF_PROJECT}
spec:
  channel: v1.0
  installPlanApproval: Automatic
  name: ibm-automation
  source: ibm-operator-catalog
  sourceNamespace: openshift-marketplace
EOF
```

[Verify installation](https://www.ibm.com/support/knowledgecenter/SSUJN4_ent/install/validate-install.html)

```bash
oc get subscription -n ${IAF_PROJECT} | grep ibm-automation
```

After a few minutes, should see:

```console
ibm-automation                                                          ibm-automation                 iaf-operators      v1.0
ibm-automation-ai-v1.0-iaf-operators-openshift-marketplace              ibm-automation-ai              iaf-operators      v1.0
ibm-automation-core-v1.0-iaf-core-operators-openshift-marketplace       ibm-automation-core            iaf-core-operators v1.0
ibm-automation-elastic-v1.0-iaf-operators-openshift-marketplace         ibm-automation-elastic         iaf-operators      v1.0
ibm-automation-eventprocessing-v1.0-iaf-operators-openshift-marketplace ibm-automation-eventprocessing iaf-operators      v1.0
ibm-automation-flink-v1.0-iaf-operators-openshift-marketplace           ibm-automation-flink           iaf-operators      v1.0
ibm-automation-v1.0-iaf-operators-openshift-marketplace                 ibm-automation                 iaf-operators      v1.0
```

Verify the install status and the ClusterServiceVersions:

```bash
oc get csv -n ${IAF_PROJECT}  | grep ibm-automation
```

Should see:

```console
ibm-automation-ai.v1.0.0              IBM Automation Foundation AI               1.0.0      Succeeded
ibm-automation-core.v1.0.0            IBM Automation Foundation Core             1.0.0      Succeeded
ibm-automation-elastic.v1.0.0         IBM Elastic                                1.0.0      Succeeded
ibm-automation-eventprocessing.v1.0.0 IBM Automation Foundation Event Processing 1.0.0      Succeeded
ibm-automation-flink.v1.0.0           IBM Automation Foundation Flink            1.0.0      Succeeded
ibm-automation.v1.0.0                 IBM Automation Foundation                  1.0.0      Succeeded
```

Verify pods are running

```bash
oc get pods -n ${IAF_PROJECT}
```

## Create Instance of Automation Foundation (Optional)

See [these](https://pages.github.ibm.com/automation-base-pak/abp-playbook/planning-install/install-ui-driven#creating-an-instance-of-ibm-automation-foundation) instructions to provision the `AutomationBase`.

Go [here](https://pages.github.ibm.com/automation-base-pak/abp-playbook/cartridges/custom-resources/#automationbase) to see the custom resource for `AutomationBase`.

## [Install Demo Cartridge](https://github.ibm.com/automation-base-pak/iaf-internal/blob/main/install-iaf-demo.sh) (Optional)

### 1. Ensure that pull secrets are set

The Demo cartridge requires pull secrets for `cp.stg.icr.io`. Make sure the pre-instal.sh script was run from [step 3](#3-set-pull-secrets-by-running-pre-installsh) above.

### 2. Set up Image Mirroring

Image mirroring is required to allow the correct container registry image to be accessed to install the demo cartridge.

Execute:

```bash
oc create -f setimagemirror.yaml -n kube-system
sleep 120
oc get pods -n kube-system | grep iaf-enable-mirrors

for worker in $(ibmcloud ks workers --cluster $CLUSTER | grep kube | awk '{ print $1 }'); \
  do echo "reloading worker"; \
  ibmcloud oc worker reboot --cluster $CLUSTER -w $worker -f; \
  done

# wait 10 minutes for reboots to complete
sleep 600
```

### 3. Create Demo Cartridge Catalog Source

Run the [install-iaf-demo.sh](./install-iaf-demo.sh) script to install the Demo Cartridge

### 4. Verify the Zen dashboard

The dashboard will be available by default as a route in the `ibm-common-services` project. Verify the dashboard by obtaining the route to the instance:

```bash
oc get route cpd -n $IAF_PROJECT -o jsonpath='{ .spec.host }{"\n"}'
```

This should produce something like:

```console
cpd-acme-iaf.iaf-demo-cluster-c0b572361ba41c9eef42d4d51297b04b-0000.us-south.containers.appdomain.cloud
```

Obtain the intial user and password with these commands:

```bash
kubectl -n ibm-common-services get secret platform-auth-idp-credentials -o jsonpath='{.data.admin_username}\' | base64 -d && echo

kubectl -n ibm-common-services get secret platform-auth-idp-credentials -o jsonpath='{.data.admin_password}' | base64 -d && echo
```

In a browser window - paste the URL for the route and accept any improperly signed certificates.

## Additional references

[IBM Automation Foundation Playbook](https://pages.github.ibm.com/automation-base-pak/abp-playbook/)

[Getting started with IBM Automation Foundation](https://www.ibm.com/support/knowledgecenter/en/cloudpaks_start/cloud-paks/about/overview-cp.html)

[IBM Automation Foundation Installation links](https://www.ibm.com/support/knowledgecenter/SSUJN4_ent/install/installation-links.html)

[Enabling IBM Operator Catalog](https://github.com/IBM/cloud-pak/blob/master/reference/operator-catalog-enablement.md)

[Installing Common Services](https://www.ibm.com/support/knowledgecenter/SSHKN6/installer/3.x.x/install_cs_cli.html)

[Installing IAF](https://www.ibm.com/support/knowledgecenter/SSUJN4_ent/install/installing.html)

[Development IAF repo, including Demo Cartridge Installation](https://github.ibm.com/automation-base-pak/iaf-internal/blob/main/README.md)

[Automation Base Pak Planning Issue Repository](https://github.ibm.com/automation-base-pak/abp-planning)


