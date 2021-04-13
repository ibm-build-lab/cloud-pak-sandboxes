#!/bin/bash
########################################################### {COPYRIGHT-TOP} ####
# Licensed Materials - Property of IBM
# 5900-AEO
#
# Copyright IBM Corp. 2020, 2021. All Rights Reserved.
#
# US Government Users Restricted Rights - Use, duplication, or
# disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
########################################################### {COPYRIGHT-END} ####
HELP="false"
SKIP_CONFIRM="false"

while getopts 'hscz' OPTION; do
  case "$OPTION" in
    h)
      HELP="true"
      ;;
    s)
      SKIP_CONFIRM="true"
      ;;
    c)
      echo "This option is no longer required and will be removed from future releases"
      ;;
    z)
      echo "This option is no longer required and will be removed from future releases"
      ;;
    ?)
      HELP="true"
      exit 1
      ;;
  esac
done
shift "$(($OPTIND -1))"

if [[ $HELP == "true" ]]; then
  echo "This script installs the IBM Automation Foundation demo cartridge."
  echo "You must have already installed IBM Automation Foundation for this script to succeed."
  echo "The demo cartridge operator is always installed. The CR creation is optional."
  echo "Usage: $0 -h -s"
  echo " -h prints this help message"
  echo " -s skips confirmation message"
  echo "The following prerequisites are checked:"
  echo "1. oc command must be installed and be logged in to your cluster."
  echo "2. Environment variable IAF_PROJECT must be set to an existing project."
  exit 0
fi 
    
# validate that oc is installed
if ! [ -x "$(command -v oc)" ]; then
  echo 'Error: oc is not installed.' >&2
  exit 1
fi

# validate oc login has been done
oc project &>/dev/null
if [ $? -gt 0 ]; then
  echo "Error: oc login required" && exit 1
fi

# validate IAF_PROJECT env var exists
if [ -z "${IAF_PROJECT}" ]; then
  echo "Error: IAF_PROJECT environment variable is not set. It must be set and then run 'install-iaf-setup.sh' to create the project." && exit 1
fi

# validate IAF_PROJECT env var is for existing project
if [ -z "$(oc get project ${IAF_PROJECT} 2>/dev/null)" ]; then
	echo "Error: project ${IAF_PROJECT} does not exist. Project will be created by running 'install-iaf-setup.sh'." && exit 1
fi

echo
echo "Congratulations, you passed all the prereq checks!"
echo

if [[ $SKIP_CONFIRM == "false" ]]; then
  echo "This script will install the IBM Automation Foundation demo cartridge into existing project ${IAF_PROJECT}."
  echo "Use -s option to skip this confirmation, -h for help."
  read -p "Enter Y or y to continue: " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "You chose to NOT continue.  Bye."
    exit 0
  fi
  echo "OK. Continuing...."
  sleep 2
  echo  
fi

echo " Create Demo Cartridge Catalog Source"

cat << EOF | oc apply -f -
apiVersion: operators.coreos.com/v1alpha1
kind: CatalogSource
metadata:
  name: iaf-demo-cartridge
  namespace: openshift-marketplace  
spec:
  displayName: IAF Demo Cartridge
  publisher: IBM  
  sourceType: grpc  
  image: cp.stg.icr.io/cp/iaf-demo-cartridge-catalog:latest
  updateStrategy:
    registryPoll:
     interval: 45m
EOF

echo "Verifying..."
oc get CatalogSources iaf-demo-cartridge  -n openshift-marketplace

echo "Create demo cartridge subscription"

cat <<EOF | oc apply -f -
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: iaf-demo-cartridge-operator
  namespace: ${IAF_PROJECT}
spec:
  channel: alpha
  installPlanApproval: Automatic
  name: iaf-demo-cartridge
  source: iaf-demo-cartridge
  sourceNamespace: openshift-marketplace
EOF

count=0
while :
do
  echo "get pods from ${IAF_PROJECT}"
  PODS=$(oc get pods -n ${IAF_PROJECT} -o jsonpath='{range .items[*]}{@.metadata.name}{" "}{@.status.phase}{"\n"}')
  echo "$PODS"
  if [[ "Running" == $(echo "$PODS" | grep iaf-demo-cartridge-controller-manager | awk '{print $2}' | uniq) ]] && 
    [[ "Running" == $(echo "$PODS" | grep iaf-eventprocessing-operator-controller-manager | awk '{print $2}' | uniq) ]] &&
	[[ "Running" == $(echo "$PODS" | grep iaf-core-operator-controller-manager | awk '{print $2}' | uniq) ]] &&
	[[ "Running" == $(echo "$PODS" | grep iaf-operator-controller-manager | awk '{print $2}' | uniq) ]] &&	
	[[ "Running" == $(echo "$PODS" | grep ibm-elastic-operator-controller-manager | awk '{print $2}' | uniq) ]] &&
	[[ "Running" == $(echo "$PODS" | grep ibm-common-service-operator | awk '{print $2}' | uniq) ]] &&
	[[ "Running" == $(echo "$PODS" | grep iaf-ai-operator-controller-manager | awk '{print $2}' | uniq) ]] &&
	[[ "Running" == $(echo "$PODS" | grep iaf-flink-operator-controller-manager | awk '{print $2}' | uniq) ]]; then
	echo "All required operator pods are running!"
	break
  else
    ((count+=1))
    if (( count <= 24 )); then
       echo "Waiting for required operator pods.  Recheck in 10 seconds"
       sleep 10
    else
       echo "Required operator pods taking too long.  Giving up."
       exit 1
    fi
  fi
done

count=0
while :
do
  READY=$(oc get pods -n ${IAF_PROJECT} -l app.kubernetes.io/instance=ibm-elastic-operator -o jsonpath='{.items[0].status.containerStatuses[0].ready}')
  if [[ "true" == "$READY" ]]; then
	echo "Elasticsearch is ready!"
	break
  else
    ((count+=1))
    if (( count <= 24 )); then
       echo "Waiting for elasticsearch to become ready.  Recheck $count of 24 in 20 seconds"
       sleep 20
    else
       echo "Elasticsearch taking too long to become ready.  Giving up."
       exit 1
    fi
  fi
done

# create Automation UI config for ROKS
echo "Create Automation UI config"
cat << EOF | oc apply -f -
apiVersion: core.automation.ibm.com/v1beta1
kind: AutomationUIConfig
metadata:
  name: iaf-system
spec:
  description: automationuiconfig
  license:
    accept: true
  version: 1.0.0
  tls: {}
  storage:
    class: "ibmc-file-gold-gid"
EOF

echo "Apply demo cartridge CR yaml"
cat << EOF | oc apply -f -
apiVersion: democartridge.ibm.com/v1
kind: IAFDemo
metadata:
  name: iafdemo-sample
  namespace: ${IAF_PROJECT}
spec:
  messagesPerGroup: "10"
  secondsToPause: "1"
  sequenceRepititions: "1"
  license:
    accept: true
EOF

echo "Wait for demoproducer pod to be running"
count=0
while :
do
  echo "get pods from ${IAF_PROJECT}"
  PODS=$(oc get pods -n ${IAF_PROJECT} -o jsonpath='{range .items[*]}{@.metadata.name}{" "}{@.status.phase}{"\n"}')
  # echo "$PODS"
  if [[ "Running" == $(echo "$PODS" | grep demoproducer | awk '{print $2}') ]]; then
    echo "Demo cartridge is now producing kafka messages!."
    break
  else 
    ((count+=1))
    if (( count <= 75 )); then
       echo "Waiting up to 60 minutes for demoproducer pod.  Recheck $count of 60 in 1 minute."
       sleep 60
    else
       echo "demoproducer pod taking too long.  Giving up."
       exit 1
    fi
  fi
done

echo "IAF Demo Cartridge operator install and CR creation successful."
echo "Demo Cartridge URL"
oc get route cpd -n iaf-project -o jsonpath='{ .spec.host }{"\n"}' 
echo "User id"
kubectl -n ibm-common-services get secret platform-auth-idp-credentials -o jsonpath='{.data.admin_username}\' | base64 -d && echo
echo "Password"
kubectl -n ibm-common-services get secret platform-auth-idp-credentials -o jsonpath='{.data.admin_password}' | base64 -d && echo
