# Installation steps for GA version of IAF

- [Installation steps for GA version of IAF](#installation-steps-for-ga-version-of-iaf)
  - [Log into cloud account](#log-into-cloud-account)
  - [Install Prereqs and IAF](#install-prereqs-and-iaf)
    - [1. Set Pull Secrets](#1-set-pull-secrets)
    - [2. Install prereqs and IAF](#2-install-prereqs-and-iaf)
    - [3. Prerequisites for installing AI components (optional)](#3-prerequisites-for-installing-ai-components-optional)
    - [4. Create Instance of Automation Foundation (Optional)](#4-create-instance-of-automation-foundation-optional)
  - [Install Demo Cartridge (Optional)](#install-demo-cartridge-optional)
    - [1. Set Pull Secrets for Staging](#1-set-pull-secrets-for-staging)
    - [2. Set up Image Mirroring](#2-set-up-image-mirroring)
    - [3. Set Default Storage Class](#3-set-default-storage-class)
    - [4. Install Demo Cartridge](#4-install-demo-cartridge)
    - [5. Verify the Zen dashboard](#5-verify-the-zen-dashboard)
  - [Additional references](#additional-references)
  
NOTE: To install IBM Automation Foundation, an OpenShift cluster of size 4 nodes of at least 16x64 is required.  

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

## Install Prereqs and IAF

### 1. Set Pull Secrets

Copy the `_template-iafenv.config` file to `iafenv.config` and set the required values. Then run these commands:

```bash
source ./iafenv.config
./setpullsecrets.sh
```
  
### 2. Install prereqs and IAF

To install the Operator Catalog, Common Services and IAF run the [install-iaf.sh](./install-iaf.sh) script

After several minutes, you can verify that the pods are running

```bash
oc get pods -n ${IAF_PROJECT}
```

### 3. Prerequisites for installing AI components (optional)

Go [here](https://www.ibm.com/docs/en/automationfoundation/1.0_ent?topic=installing-prerequisites#prerequisites-for-installing-ai-components) for details.

### 4. Create Instance of Automation Foundation (Optional)

If not installing the Demo Cartridge, you will need to create an instance of the AutomationBase.

See [these](https://pages.github.ibm.com/automation-base-pak/abp-playbook/planning-install/install-ui-driven#creating-an-instance-of-ibm-automation-foundation) instructions to provision the `AutomationBase`.

Go [here](https://pages.github.ibm.com/automation-base-pak/abp-playbook/cartridges/custom-resources/#automationbase) to see the custom resource for `AutomationBase`.

## [Install Demo Cartridge](https://github.ibm.com/automation-base-pak/iaf-internal/blob/main/install-iaf-demo.sh) (Optional)

### 1. Set Pull Secrets for Staging

The Demo cartridge requires pull secrets for `cp.stg.icr.io`. Make sure the [setpullsecrets.sh](./setpullsecrets.sh) script was run.

### 2. Set up Image Mirroring

Image mirroring is required to allow the correct container registry image to be accessed to install the demo cartridge.

Execute:

```bash
./setimagemirror.sh
```

### 3. Set Default Storage Class

The demo cartridge needs the default storage class to be `ibmc-file-gold-gid`.  To set this, run the following commands:

```bash
kubectl patch storageclass ibmc-file-gold-gid -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
kubectl patch storageclass ibmc-block-gold -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
```

### 4. Install Demo Cartridge

Execute:

```bash
./install-iaf-demo.sh
```

to install the Demo Cartridge

### 5. Verify the Zen dashboard

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


