#!/bin/sh
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

# To upgrade the flavor
#   ibmcloud oc worker-pool create classic --name default_workers --cluster <cluster_name> --flavor c3c.16x32 --size-per-zone <number_of_workers_per_zone>
#   ibmcloud sl vlan list
#   ibmcloud oc cluster get --cluster <cluster_name> --show-resources
#   ibmcloud oc zone add classic --zone dal10 --cluster <cluster_name> --worker-pool default_workers --private-vlan 2832804 --public-vlan 2832802

# helpful commands:
#   docker exec -it <container name> /bin/bash
#   kubectl describe <resource name>
#   kubectl get <resource> <name> -o yaml
#   kubectl config set-context --current --namespace=<namespace/project>

# Data center info:
# Name: wdc04
# PVlan: 2876468
# PBVlan: 2876470
# Name: wdc06
# PVlan: 2916302
# PBVlan: 2916300
# Name: dal13
# PVlan: 2847992
# PBVlan: 2847990
# Name: dal10
# PVlan: 2832804
# PBVlan: 2832802

# Log in to IBM Cloud
# ibmcloud login -sso
# echo "What Resource Group (defaults to cloud-pak-sandbox)?"
# read RESOURCE_GROUP
# RESOURCE_GROUP="${RESOURCE_GROUP:-cloud-pak-sandbox}"
RESOURCE_GROUP="cloud-pak-sandbox"
ibmcloud target -g $RESOURCE_GROUP

# Get entitlement key, https://myibm.ibm.com/products-services/containerlibrary
echo Please go to https://myibm.ibm.com/products-services/containerlibrary for your entitlement key
echo Enter entitlement key here:
read E_KEY
echo What is your IBM email address?
read EMAIL_ADDR

# Create or get details of OCP Cluster
echo "Do you already have an OpenShift cluster? ('y','n')"
select yn in "y" "n"; do
  case $yn in
  n)
    echo "Creating OpenShift Cluster on IBM Cloud"
    echo "What is the name of new cluster?"
    read CLUSTER_NAME
    echo "What version of Openshift (defaults to 4.4)?"
    read OCP_VERSION
    OCP_VERSION="${OCP_VERSION:-4.4}"
    echo "What flavor (defaults to c3c.16x32)?"
    read OCP_FLAVOR
    OCP_FLAVOR="${OCP_FLAVOR:-c3c.16x32}"
    echo "How many worker nodes (defaults to 5)?"
    read NUM_NODES
    NUM_NODES="${NUM_NODES:-5}"
    echo "What data center (defaults to dal10)?"
    read ZONE
    ZONE="${ZONE:-dal10}"
    echo "Enter private VLAN id (defaults to 2832804)?"
    read PVLAN
    PVLAN="${PVLAN:-2832804}"
    echo "Enter public VLAN id (defaults to 2832802)?"
    read PBVLAN
    PBVLAN="${PBVLAN:-2832802}"
    echo "Creating Cluster"
    echo "ibmcloud oc cluster create classic --name ${CLUSTER_NAME} --version ${OCP_VERSION}_openshift --zone ${ZONE} --flavor ${OCP_FLAVOR} --workers ${NUM_NODES} --entitlement cloud_pak --private-vlan ${PVLAN} --public-vlan ${PBVLAN}"
    ibmcloud oc cluster create classic --name ${CLUSTER_NAME} --version ${OCP_VERSION}_openshift --zone ${ZONE} --flavor ${OCP_FLAVOR} --workers ${NUM_NODES} --entitlement cloud_pak --private-vlan ${PVLAN} --public-vlan ${PBVLAN}
    # Documentation on how to access cluster: https://cloud.ibm.com/docs/openshift?topic=openshift-access_cluster
    echo "Waiting for cluster to come up..."
    date

    # try command every 5 mintutes 5 times or until it returns success
    for ((time = 0; time < 5; time++)); do
      echo ibmcloud oc cluster config -c $CLUSTER_NAME --admin
      if ibmcloud oc cluster config -c $CLUSTER_NAME --admin; then
        break
      fi
      echo "Trying again in 5 minutes"
      sleep 300
    done
    break
    ;;
  y)
    echo What is the name of existing cluster to use?
    read CLUSTER_NAME
    ibmcloud oc cluster config -c $CLUSTER_NAME --admin
    break
    ;;
  esac
done

CLUSTER_URL=$(kubectl cluster-info | sed -n -e 's/^.*at //p')
echo "Cluster is ready and console can be accessed via $CLUSTER_URL"
# create namespace to install mcm
kubectl create namespace cp4mcm
kubectl config set-context --current --namespace=cp4mcm

# Designate ibmc-block-retain-gold as default storage class
#kubectl patch storageclass ibmc-block-retain-gold -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
#kubectl patch storageclass ibmc-block-gold -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'

# Ensure that the image registry has a valid route for IBM Cloud Pak for Multicloud Management images
kubectl patch configs.imageregistry.operator.openshift.io/cluster --type merge -p '{"spec":{"defaultRoute":true}}'

# Create secret from entitlement key
export ENTITLED_REGISTRY=cp.icr.io
export ENTITLED_REGISTRY_USER=cp
export ENTITLED_REGISTRY_USER_EMAIL=$EMAIL_ADDR
export ENTITLED_REGISTRY_KEY=$E_KEY
echo "kubectl create secret docker-registry ibm-management-pull-secret --docker-username=$ENTITLED_REGISTRY_USER --docker-password=$ENTITLED_REGISTRY_KEY --docker-email=$ENTITLED_REGISTRY_USER_EMAIL --docker-server=$ENTITLED_REGISTRY -n cp4mcm"
kubectl create secret docker-registry ibm-management-pull-secret --docker-username=$ENTITLED_REGISTRY_USER --docker-password=$ENTITLED_REGISTRY_KEY --docker-email=$ENTITLED_REGISTRY_USER_EMAIL --docker-server=$ENTITLED_REGISTRY -n cp4mcm

# Create the CP4MCM Operator catalog source, subscriptions and installion
#kubectl --validate=false apply -f ./resources.yaml
cat <<EOF | kubectl apply -f -
apiVersion: operators.coreos.com/v1alpha1
kind: CatalogSource
metadata:
  name: ibm-management-orchestrator
  namespace: openshift-marketplace
spec:
  displayName: IBM Management Orchestrator Catalog
  publisher: IBM
  sourceType: grpc
  image: quay.io/cp4mcm/cp4mcm-orchestrator-catalog:2.0.0
  updateStrategy:
    registryPoll:
      interval: 45m
---
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
---
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: ibm-management-orchestrator
  namespace: openshift-operators
spec:
  channel: 2.0-stable
  installPlanApproval: Automatic
  name: ibm-management-orchestrator
  source: ibm-management-orchestrator
  sourceNamespace: openshift-marketplace
EOF

echo "Waiting for operators to install"
while ! kubectl get sub ibm-common-service-operator-stable-v1-opencloud-operators-openshift-marketplace ibm-management-orchestrator operand-deployment-lifecycle-manager-app --namespace openshift-operators; do \
  sleep 60
done
#kubectl apply -f ./installation.yaml
cat <<EOF | kubectl apply -f -
apiVersion: orchestrator.management.ibm.com/v1alpha1
kind: Installation
metadata:
  annotations:
  finalizers:
  - ibm-management-orchestrator.management.ibm.com/finalizer
  name: ibm-management
  namespace: cp4mcm
spec:
  storageClass: ibmc-block-retain-gold
  imagePullSecret: ibm-management-pull-secret
  license:
    accept: true
  mcmCoreDisabled: false
  pakModules:
  - config:
    - enabled: true
      name: ibm-management-im-install
    - enabled: true
      name: ibm-management-infra-grc
    - enabled: true
      name: ibm-management-infra-vm
    - enabled: true
      name: ibm-management-cam-install
      spec:
        manageservice:
          camLogsPV:
            name: cam-logs-pv
            persistence:
              accessMode: ReadWriteMany
              enabled: true
              existingClaimName: ""
              existingDynamicVolume: false
              size: 10Gi
              storageClassName: ibmc-file-gold
              useDynamicProvisioning: true
          camMongoPV:
            name: cam-mongo-pv
            persistence:
              accessMode: ReadWriteOnce
              enabled: true
              existingClaimName: ""
              existingDynamicVolume: false
              size: 30Gi
              storageClassName: ibmc-block-gold
              useDynamicProvisioning: true
          camTerraformPV:
            name: cam-terraform-pv
            persistence:
              accessMode: ReadWriteMany
              enabled: true
              existingClaimName: ""
              existingDynamicVolume: false
              size: 15Gi
              storageClassName: ibmc-file-gold-gid
              useDynamicProvisioning: true
          roks: true
          roksRegion: us-south
          roksZone: dal10
    - enabled: true
      name: ibm-management-service-library
    enabled: false
    name: infrastructureManagement
  - config:
    - enabled: false
      name: ibm-management-monitoring
      spec:
        monitoringDeploy:
          global:
            environmentSize: size0
            persistence:
              storageClassOption:
                cassandrabak: none
                cassandradata: ibmc-block-gold
                couchdbdata: ibmc-block-gold
                datalayerjobs: ibmc-block-gold
                elasticdata: ibmc-block-gold
                kafkadata: ibmc-block-gold
                zookeeperdata: ibmc-block-gold
              storageSize:
                cassandrabak: 500Gi
                cassandradata: 500Gi
                couchdbdata: 50Gi
                datalayerjobs: 50Gi
                elasticdata: 50Gi
                kafkadata: 100Gi
                zookeeperdata: 10Gi
        operandRequest: {}
    enabled: false
    name: monitoring
  - config:
    - enabled: true
      name: ibm-management-notary
    - enabled: true
      name: ibm-management-image-security-enforcement
    - enabled: true
      name: ibm-management-mutation-advisor
    - enabled: true
      name: ibm-management-vulnerability-advisor
      spec:
        annotator:
          esSecretCA: ca.crt
          esSecretCert: curator.crt
          esSecretKey: curator.key
          esSecretName: logging-elk-certs
          esSecurityEnabled: true
          esServiceName: elasticsearch.ibm-common-services
        controlplane:
          esSecretCA: ca.crt
          esSecretCert: curator.crt
          esSecretKey: curator.key
          esSecretName: logging-elk-certs
          esSecurityEnabled: true
          esServiceName: elasticsearch.ibm-common-services
        indexer:
          esSecretCA: ca.crt
          esSecretCert: curator.crt
          esSecretKey: curator.key
          esSecretName: logging-elk-certs
          esSecurityEnabled: true
          esServiceName: elasticsearch.ibm-common-services
    enabled: false
    name: securityServices
  - config:
    - enabled: true
      name: ibm-management-sre-chatops
    enabled: false
    name: operations
  - config:
    - enabled: true
      name: ibm-management-manage-runtime
    enabled: false
    name: techPreview
EOF

echo "It will take approximately 40 minutes for software to install. The time is currently"
date
echo
echo "To monitor progress: 'kubectl get pods -A | grep -Ev \"Completed|1/1|2/2|3/3|4/4|5/5|6/6|7/7\"'"
echo Should not return anything when MCM is up and running
echo
echo To get the URL to get to the Multicloud Management Console:
echo ibmcloud oc cluster config -c $CLUSTER_NAME --admin
echo "kubectl get route -n ibm-common-services cp-console -o jsonpath=‘{.spec.host}’ && echo"
echo
echo To get default login id:
echo "kubectl -n ibm-common-services get secret platform-auth-idp-credentials -o jsonpath='{.data.admin_username}\' | base64 -D && echo"
echo
echo To get default Password:
echo "kubectl -n ibm-common-services get secret platform-auth-idp-credentials -o jsonpath='{.data.admin_password}' | base64 -D && echo"
