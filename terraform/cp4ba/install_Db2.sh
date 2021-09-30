#!/bin/bash
# set -x
###############################################################################
#
# Licensed Materials - Property of IBM
#
# (C) Copyright IBM Corp. 2021. All Rights Reserved.
#
# US Government Users Restricted Rights - Use, duplication or
# disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
#
###############################################################################

CUR_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DB2_INPUT_PROPS_FILENAME="01-parametersForDb2OnOCP.sh"
DB2_INPUT_PROPS_FILENAME_FULL="${CUR_DIR}/${DB2_INPUT_PROPS_FILENAME}"

if [[ -f $DB2_INPUT_PROPS_FILENAME_FULL ]]; then
   echo
   echo "Found ${DB2_INPUT_PROPS_FILENAME}.  Reading in variables from that script."
   . $DB2_INPUT_PROPS_FILENAME_FULL
   
   if [ $db2OnOcpProjectName == "REQUIRED" ] || [ $db2AdminUserPassword == "REQUIRED" ] || [ "$db2StandardLicenseKey" == "REQUIRED" ]; then
      echo "File ${DB2_INPUT_PROPS_FILENAME} not fully updated. Pls. update all parameters in the BEFORE running script section."
      echo
      exit 0
   fi
   
   echo "Done!"
else
   echo
   echo "File ${DB2_INPUT_PROPS_FILENAME_FULL} not found. Pls. check."
   echo
   exit 0
fi

echo
echo -e "\x1B[1mThis script installs Db2u on OCP into project ${db2OnOcpProjectName}. For this, you need the jq tool installed and your Entitlement Registry key handy.\n \x1B[0m"

printf "Do you want to continue (Yes/No, default: No): "
read -rp "" ans
case "$ans" in
"y"|"Y"|"yes"|"Yes"|"YES")
    echo
    echo -e "Installing Db2U on OCP..."
    ;;
*)
    echo
    echo -e "Exiting..."
    echo
    exit 0
    ;;
esac

if [ $cp4baDeploymentPlatform == "ROKS" ]; then
  echo
  echo "Installing the storage classes..."
  oc apply -f cp4a-bronze-storage-class.yaml
  oc apply -f cp4a-silver-storage-class.yaml
  oc apply -f cp4a-gold-storage-class.yaml
  kubectl patch storageclass ibmc-block-gold -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
  kubectl patch storageclass cp4a-file-delete-gold-gid -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
fi

echo
echo "Installing the IBM Operator Catalog..."
oc apply -f ibm_operator_catalog.yaml

echo
echo "Creating project ${db2OnOcpProjectName}..."
oc new-project ${db2OnOcpProjectName}
oc project ${db2OnOcpProjectName}

echo
echo "Creating secret ibm-registry. For this, your Entitlement Registry key is needed."
echo
echo "You can get the Entitlement Registry key from here: https://myibm.ibm.com/products-services/containerlibrary"
echo
ENTITLEMENTKEY=""
EMAIL="me@here.com"
DOCKER_REG_SERVER="cp.icr.io"
DOCKER_REG_USER="cp"
printf "\x1B[1mEnter your Entitlement Registry key: \x1B[0m"
while [[ $ENTITLEMENTKEY == '' ]]
do
  read -rsp "" ENTITLEMENTKEY
  if [ -z "$ENTITLEMENTKEY" ]; then
    printf "\n"
    printf "\x1B[1;31mEnter a valid Entitlement Registry key: \x1B[0m"
  else
    DOCKER_REG_KEY=$ENTITLEMENTKEY
    entitlement_verify_passed=""
    while [[ $entitlement_verify_passed == '' ]]
    do
      printf "\n"
      printf "Verifying the Entitlement Registry key...\n"
      if podman login -u "$DOCKER_REG_USER" -p "$DOCKER_REG_KEY" "$DOCKER_REG_SERVER" --tls-verify=false; then
        printf 'Entitlement Registry key is valid.\n'
        entitlement_verify_passed="passed"
      else
        printf '\x1B[1;31mThe Entitlement Registry key verification failed. Enter a valid Entitlement Registry key: \x1B[0m'
        ENTITLEMENTKEY=''
        entitlement_verify_passed="failed"
      fi
    done
  fi
done
oc create secret docker-registry ibm-registry --docker-server=${DOCKER_REG_SERVER} --docker-username=${DOCKER_REG_USER} --docker-password=${ENTITLEMENTKEY} --docker-email=${EMAIL} --namespace=${db2OnOcpProjectName}

if [ $cp4baDeploymentPlatform == "ROKS" ]; then
  echo
  echo "Preparing the cluster for Db2..."
  oc get no -l node-role.kubernetes.io/worker --no-headers -o name | xargs -I {} --  oc debug {} -- chroot /host sh -c 'grep "^Domain = slnfsv4.coms" /etc/idmapd.conf || ( sed -i.bak "s/.*Domain =.*/Domain = slnfsv4.com/g" /etc/idmapd.conf; nfsidmap -c; rpc.idmapd )'
fi

echo
echo "Modifying the OpenShift Global Pull Secret (you need jq tool for that):"
echo $(oc get secret pull-secret -n openshift-config --output="jsonpath={.data.\.dockerconfigjson}" | base64 --decode; oc get secret ibm-registry -n ${db2OnOcpProjectName} --output="jsonpath={.data.\.dockerconfigjson}" | base64 --decode) | jq -s '.[0] * .[1]' > dockerconfig_merged
oc set data secret/pull-secret -n openshift-config --from-file=.dockerconfigjson=dockerconfig_merged

echo
echo "You are now ready to install the Db2u Operator:"
echo "  1. Open your OCP Web Console and navigate to \"Operators -> OperatorHub\"."
echo "  2. Set the project scope to \"${db2OnOcpProjectName}\"."
echo "  3. Search for \"db2\"."
echo "  4. Select \"IBM Db2\"."
echo "  5. Click \"Install\"."
echo "  6. Make sure the namespace is set to \"${db2OnOcpProjectName}\"."
echo "  7. Set the Approval Strategy to \"Manual\". Leave all other parameters at the defaults."
echo "  8. Click \"Install\", then click \"Approve\"."
echo "  9. Wait untill the installation of the Db2u operator succeeded."
echo " 10. Pls. make sure to specify for the just installed operator the correct Db2 version in ${DB2_INPUT_PROPS_FILENAME}."

echo
printf "Has the installation of the Db2u operator succeeded and have you updated ${DB2_INPUT_PROPS_FILENAME} (Yes/No, default: No): "
read -rp "" ans
case "$ans" in
"y"|"Y"|"yes"|"Yes"|"YES")
    echo
    echo -e "Installation of the Db2u operator succeeded."
    ;;
*)
    echo
    echo -e "Pls. debug the installation of the Db2u operator. Exiting..."
    echo
    exit 0
    ;;
esac

. $DB2_INPUT_PROPS_FILENAME_FULL
if [ $db2InstanceVersion == "REQUIRED" ]; then
   echo "File ${DB2_INPUT_PROPS_FILENAME} not updated. Pls. update parameter db2InstanceVersion."
   echo
   exit 0
fi

echo
echo "Final step is to deploy the Db2u cluster..."
cp db2.template.yaml db2.yaml
sed -i.bak "s|db2OnOcpProjectName|$db2OnOcpProjectName|g" db2.yaml
sed -i.bak "s|db2AdminUserPassword|$db2AdminUserPassword|g" db2.yaml
sed -i.bak "s|db2InstanceVersion|$db2InstanceVersion|g" db2.yaml
sed -i.bak "s|db2Cpu|$db2Cpu|g" db2.yaml
sed -i.bak "s|db2Memory|$db2Memory|g" db2.yaml
sed -i.bak "s|db2StorageSize|$db2StorageSize|g" db2.yaml
sed -i.bak "s|db2OnOcpStorageClassName|$db2OnOcpStorageClassName|g" db2.yaml
db2License="accept: true"
if [ "$db2StandardLicenseKey" == "" ]; then
   db2License="accept: true"
else
   db2License="value: $db2StandardLicenseKey"
fi
sed -i.bak "s|db2License|$db2License|g" db2.yaml
oc apply -f db2.yaml

echo
echo "Now, wait untill your Db2u cluster is fully deployed. For this you should see the following pods (names might be slightly different):"
echo "  oc get pods"
echo "  NAME                                    READY   STATUS"
echo "  c-db2ucluster-db2u-0                    1/1     Running"
echo "  c-db2ucluster-etcd-0                    1/1     Running"
echo "  c-db2ucluster-instdb-rrkm4              0/1     Completed"
echo "  c-db2ucluster-ldap-566d88f54d-nqg9n     1/1     Running"
echo "  c-db2ucluster-restore-morph-x2qj8       0/1     Completed"
echo "  db2u-operator-manager-66879f8ff-2gj89    1/1     Running"

echo
echo "Wait untill the pod \"c-db2ucluster-restore-morph-xxxxx\" pod is in STATUS \"Completed\"."

echo
printf "Has the installation of your Db2u cluster succeeded (Yes/No, default: No): "
read -rp "" ans
case "$ans" in
"y"|"Y"|"yes"|"Yes"|"YES")
    echo
    echo -e "Installation of your Db2u cluster succeeded."
    ;;
*)
    echo
    echo -e "Pls. debug the installation of your Db2u cluster. Exiting..."
    echo
    exit 0
    ;;
esac

echo
echo "Finally, pls. increase the number of DBs allowed. For this:"
echo "  1. Open your OCP Web Console and navigate to \"Workloads -> Config Maps\"."
echo "  2. Set the project scope to \"${db2OnOcpProjectName}\"."
echo "  3. Click \"c-db2ucluster-db2dbmconfig\"."
echo "  4. Open tab \"YAML\"."
echo "  5. Scroll to the bottom of the definition and change \"NUMDB\" to \"20\"."
echo "  6. Click \"Save\" twice."

echo
printf "Have you completed the above steps (Yes/No, default: No): "
read -rp "" ans
case "$ans" in
"y"|"Y"|"yes"|"Yes"|"YES")
    echo
    echo -e "Perfect!"
    ;;
*)
    echo
    echo -e "It's recommended you complete them!"
    ;;
esac

echo
echo "Finally, this script will patch the running Db2u cluster to apply the NUMDB change..."
oc exec c-db2ucluster-db2u-0 -it -- su - $db2AdminUserName -c "db2 update dbm cfg using numdb 20"

oc exec c-db2ucluster-db2u-0 -it -- su - $db2AdminUserName -c "db2set DB2_WORKLOAD=FILENET_CM"
oc exec c-db2ucluster-db2u-0 -it -- su - $db2AdminUserName -c "set CUR_COMMIT=ON"

oc exec c-db2ucluster-db2u-0 -it -- su - $db2AdminUserName -c "db2stop"
oc exec c-db2ucluster-db2u-0 -it -- su - $db2AdminUserName -c "db2start"

oc exec c-db2ucluster-db2u-0 -it -- su - $db2AdminUserName -c "db2 deactivate database BLUDB"

oc exec c-db2ucluster-db2u-0 -it -- su - $db2AdminUserName -c "db2 drop database BLUDB"

echo
echo "Existing databases are:"
oc exec c-db2ucluster-db2u-0 -it -- su - $db2AdminUserName -c "db2 list database directory | grep \"Database name\""

echo
echo "Use this hostname/IP to access the databases e.g. with IBM Data Studio."
echo "\x1B[1mPls. also update in ${DB2_INPUT_PROPS_FILENAME} property \"db2HostName\" with this information (in Skytap, use the IP 10.0.0.10 instead).\x1B[0m"
oc get route console -n openshift-console -o yaml | grep routerCanonicalHostname

echo
echo "Use one of these NodePorts to access the databases e.g. with IBM Data Studio (usually the first one is for legacy-server (Db2 port 50000), the second for ssl-server (Db2 port 50001))."
echo "\x1B[1mPls. also update in ${DB2_INPUT_PROPS_FILENAME} property \"db2PortNumber\" with this information (legacy-server).\x1B[0m"
oc get svc -n ${db2OnOcpProjectName} c-db2ucluster-db2u-engn-svc -o json | grep nodePort

echo
echo "Use \"$db2AdminUserName\" and password \"$db2AdminUserPassword\" to access the databases e.g. with IBM Data Studio."

echo
echo "Db2u installation complete! Congratulations. Exiting..."
