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
#RESOURCE_GROUP='cloud-pak-sandbox'
ibmcloud target -g $RESOURCE_GROUP

echo "Setting environment variables.  Be sure to have the iafenv.config file set up"
source ./iafenv.config

# Create or get details of OCP Cluster
echo "Do you already have an OpenShift cluster?"
select yn in "y" "n"; do
  case $yn in
  n)
    echo "Creating OpenShift Cluster on IBM Cloud"
    echo "What is the name of new cluster?"
    read CLUSTER
    #    echo "What version of Openshift (defaults to 4.6)?"
    #    read OCP_VERSION
    OCP_VERSION="${OCP_VERSION:-4.6}"
    #    echo "What flavor (defaults to c3c.16x32)?"
    #    echo "ibmcloud ks flavors --zone dal12 --provider classic"
    #    read OCP_FLAVOR
    OCP_FLAVOR="${OCP_FLAVOR:-b3c.16x64}"
    #    echo "How many worker nodes (defaults to 4)?"
    #    read NUM_NODES
    NUM_NODES="${NUM_NODES:-4}"
    echo "What data center (defaults to dal12)?"
    read ZONE
    ZONE="${ZONE:-dal12}"
    ibmcloud sl vlan list -d $ZONE
    echo "Enter private VLAN id for $ZONE:"
    read PVLAN
    echo "Enter public VLAN id for $ZONE:"
    read PBVLAN
    echo "Creating Cluster"
    echo "ibmcloud oc cluster create classic --name ${CLUSTER} --version ${OCP_VERSION}_openshift --zone ${ZONE} --flavor ${OCP_FLAVOR} --workers ${NUM_NODES} --entitlement cloud_pak --private-vlan ${PVLAN} --public-vlan ${PBVLAN}"
    ibmcloud oc cluster create classic --name ${CLUSTER} --version ${OCP_VERSION}_openshift --zone ${ZONE} --flavor ${OCP_FLAVOR} --workers ${NUM_NODES} --entitlement cloud_pak --private-vlan ${PVLAN} --public-vlan ${PBVLAN}
    echo "Waiting for cluster to come up..."
    date

    # try command every 5 minutes for an hour or until it returns success
    for ((time = 0; time < 12; time++)); do
      echo ibmcloud oc cluster config -c $CLUSTER --admin
      if ibmcloud oc cluster config -c $CLUSTER --admin; then
        break
      fi
      echo "Trying again in 5 minutes"
      sleep 300
    done
    break
    ;;
  y)
    echo What is the name of existing cluster to use?
    read CLUSTER
    ibmcloud oc cluster config -c $CLUSTER --admin
    break
    ;;
  esac
done

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
