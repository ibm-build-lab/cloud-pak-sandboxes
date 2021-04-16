#!/bin/bash
#******************************************************************************
# Licensed Materials - Property of IBM
# (c) Copyright IBM Corporation 2019. All Rights Reserved.
#
# Note to U.S. Government Users Restricted Rights:
# Use, duplication or disclosure restricted by GSA ADP Schedule
# Contract with IBM Corp.
#******************************************************************************
# Download and install a few CLI tools and the Kubernetes Service plug-in.
#   curl -sL https://ibm.biz/idt-installer | bash

# helpful commands:
#   docker exec -it <container name> /bin/bash
#   kubectl describe <resource name>
#   kubectl get <resource> <name> -o yaml
#   kubectl config set-context --current --namespace=<namespace/project>

# Log in to IBM Cloud
#ibmcloud login -sso
echo "What Resource Group (defaults to cloud-pak-sandbox)?"
read RESOURCE_GROUP
RESOURCE_GROUP="${RESOURCE_GROUP:-cloud-pak-sandbox}"
ibmcloud target -g $RESOURCE_GROUP

echo "Setting environment variables.  Be sure to have the iafenv.config file set up"
source ./iafenv.config

ibmcloud oc cluster config -c $CLUSTER --admin

CLUSTER_URL=$(kubectl cluster-info | sed -n -e 's/^.*at //p')
echo "Cluster is ready and console can be accessed via $CLUSTER_URL"
# create namespace to install IAF
kubectl create namespace iaf
kubectl config set-context --current --namespace=iaf

# Create secret from entitlement key
echo "Create secret from entitlement key"
./pre-install.sh

# Create the Operator catalog source
kubectl apply -f ./resources.yaml

sleep 60
oc get catalogsource -n openshift-marketplace | grep IBM
oc get pods -n openshift-marketplace | grep opencloud-operators
oc get pods -n openshift-marketplace | grep ibm-operator

echo "Installing..."
kubectl apply -f ./installation.yaml

sleep 180
echo "Verifying installation"
oc get pods -n iaf
