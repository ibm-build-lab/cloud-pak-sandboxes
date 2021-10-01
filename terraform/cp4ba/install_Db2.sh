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
CATALOG_SOURCE_FILE=${CUR_DIR}/ibm_operator_catalog.yaml
DB2_FILE=${CUR_DIR}/db2.yaml

echo
echo "Creating Storage Class ..."
oc apply -f storage_class.yaml
sleep 10

kubectl patch storageclass ibmc-block-gold -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
kubectl patch storageclass cp4a-file-retain-gold-gid -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

echo
echo "Installing the IBM Operator Catalog..."
oc apply -f ${CATALOG_SOURCE_FILE}

echo
echo "Creating project ${DB2_PROJECT_NAME}..."
oc new-project ${DB2_PROJECT_NAME}
oc project ${DB2_PROJECT_NAME}

echo
echo "Creating secret ibm-db2-registry. For this, your Entitlement Registry key is needed."
echo
echo "You can get the Entitlement Registry key from here: https://myibm.ibm.com/products-services/containerlibrary"
echo

#echo -e "\x1B[1mCreating secret \"ibm-entitlement-key\" in ${CP4BA_PROJECT_NAME} for CP4BA ...\n\x1B[0m"
#CREATE_SECRET_RESULT=$(${K8S_CMD} create secret docker-registry ibm-entitlement-key -n "${CP4BA_PROJECT_NAME}" --docker-username="${DOCKER_USERNAME}" --docker-password="${ENTITLED_REGISTRY_KEY}" --docker-server="${DOCKER_SERVER}" --docker-email="${ENTITLED_REGISTRY_EMAIL}")
#sleep 5

#ENTITLEMENTKEY=""
#EMAIL="me@here.com"
#DOCKER_REG_SERVER="cp.icr.io"
#DOCKER_REG_USER="cp"
#printf "\x1B[1mEnter your Entitlement Registry key: \x1B[0m"
#while [[ $ENTITLEMENTKEY == '' ]]
#do
#  read -rsp "" ENTITLEMENTKEY
#  if [ -z "$ENTITLEMENTKEY" ]; then
#    printf "\n"
#    printf "\x1B[1;31mEnter a valid Entitlement Registry key: \x1B[0m"
#  else
#    DOCKER_REG_KEY=$ENTITLEMENTKEY
#    entitlement_verify_passed=""
#    while [[ $entitlement_verify_passed == '' ]]
#    do
#      printf "\n"
#      printf "Verifying the Entitlement Registry key...\n"
#      if podman login -u "$DOCKER_REG_USER" -p "$DOCKER_REG_KEY" "$DOCKER_REG_SERVER" --tls-verify=false; then
#        printf 'Entitlement Registry key is valid.\n'
#        entitlement_verify_passed="passed"
#      else
#        printf '\x1B[1;31mThe Entitlement Registry key verification failed. Enter a valid Entitlement Registry key: \x1B[0m'
#        ENTITLEMENTKEY=''
#        entitlement_verify_passed="failed"
#      fi
#    done
#  fi
#done
oc create secret docker-registry ibm-db2-registry --docker-server=${DOCKER_REG_SERVER} --docker-username=${DOCKER_REG_USER} --docker-password=${ENTITLEMENTKEY} --docker-email=${EMAIL} --namespace=${DB2_PROJECT_NAME}

#if [ $cp4baDeploymentPlatform == "ROKS" ]; then
#  echo
echo "Preparing the cluster for Db2..."
oc get no -l node-role.kubernetes.io/worker --no-headers -o name | xargs -I {} --  oc debug {} -- chroot /host sh -c 'grep "^Domain = slnfsv4.coms" /etc/idmapd.conf || ( sed -i.bak "s/.*Domain =.*/Domain = slnfsv4.com/g" /etc/idmapd.conf; nfsidmap -c; rpc.idmapd )'
#fi

echo
echo "Modifying the OpenShift Global Pull Secret (you need jq tool for that):"
echo $(oc get secret pull-secret -n openshift-config --output="jsonpath={.data.\.dockerconfigjson}" | base64 --decode; oc get secret ibm-db2-registry -n ${DB2_PROJECT_NAME} --output="jsonpath={.data.\.dockerconfigjson}" | base64 --decode) | jq -s '.[0] * .[1]' > dockerconfig_merged
oc set data secret/pull-secret -n openshift-config --from-file=.dockerconfigjson=dockerconfig_merged

echo
echo "You are now ready to install the Db2u Operator:"
echo "  1. Open your OCP Web Console and navigate to \"Operators -> OperatorHub\"."
echo "  2. Set the project scope to \"${DB2_PROJECT_NAME}\"."
echo "  3. Search for \"db2\"."
echo "  4. Select \"IBM Db2\"."
echo "  5. Click \"Install\"."
echo "  6. Make sure the namespace is set to \"${DB2_PROJECT_NAME}\"."
echo "  7. Set the Approval Strategy to \"Manual\". Leave all other parameters at the defaults."
echo "  8. Click \"Install\", then click \"Approve\"."
echo "  9. Wait untill the installation of the Db2u operator succeeded."
echo " 10. Pls. make sure to specify for the just installed operator the correct Db2 version in ${DB2_INPUT_PROPS_FILENAME}."

if oc get catalogsource -n openshift-marketplace | grep ibm-operator-catalog ; then
        echo "Found ibm operator catalog source"
    else
        oc apply -f "${CATALOG_SOURCE_FILE}"
        if [ $? -eq 0 ]; then
          echo "IBM Operator Catalog source created!"
        else
          echo "Generic Operator catalog source creation failed"
          exit 1
        fi
    fi

    maxRetry=20
    for ((retry=0;retry<=${maxRetry};retry++)); do
      echo "Waiting for Db2u Operator Catalog pod initialization"

      isReady=$(oc get pod -n openshift-marketplace --no-headers | grep ibm-operator-catalog | grep "Running")
      if [[ -z $isReady ]]; then
        if [[ $retry -eq ${maxRetry} ]]; then
          echo "Timeout Waiting for  Db2u Operator Catalog pod to start"
          echo -e "Please, debug the installation of the Db2u operator. Exiting..."
          exit 1
        else
          sleep 5
          continue
        fi
      else
        echo "Db2u Operator Catalog is running $isReady"
        echo -e "Installation of the Db2u operator succeeded."
        break
      fi
    done

echo
#printf "Has the installation of the Db2u operator succeeded and have you updated ${DB2_INPUT_PROPS_FILENAME} (Yes/No, default: No): "
#read -rp "" ans
#case "$ans" in
#"y"|"Y"|"yes"|"Yes"|"YES")
#    echo
#    echo -e "Installation of the Db2u operator succeeded."
#    ;;
#*)
#    echo
#    echo -e "Pls. debug the installation of the Db2u operator. Exiting..."
#    echo
#    exit 0
#    ;;
#esac

echo "Deploying the Db2u cluster ..."

db2License="accept: true"
if [ "$DB2_PROJECT_NAME" == "" ]; then
   db2License="accept: true"
else
   db2License="value: $DB2_STANDARD_LICENSE_KEY"
fi
sed -i.bak "s|db2License|$db2License|g" ${DB2_FILE}
oc apply -f ${DB2_FILE}
sleep 10

oc get pods -n ${DB2_PROJECT_NAME}

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
echo "Finally, pls. increase the number of DBs allowed. For this:"
echo "  1. Open your OCP Web Console and navigate to \"Workloads -> Config Maps\"."
echo "  2. Set the project scope to \"${DB2_PROJECT_NAME}\"."
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
oc exec c-db2ucluster-db2u-0 -it -- su - ${DB2_ADMIN_USER_NAME} -c "db2 update dbm cfg using numdb 20"

oc exec c-db2ucluster-db2u-0 -it -- su - ${DB2_ADMIN_USER_NAME} -c "db2set DB2_WORKLOAD=FILENET_CM"
oc exec c-db2ucluster-db2u-0 -it -- su - ${DB2_ADMIN_USER_NAME} -c "set CUR_COMMIT=ON"

oc exec c-db2ucluster-db2u-0 -it -- su - ${DB2_ADMIN_USER_NAME} -c "db2stop"
oc exec c-db2ucluster-db2u-0 -it -- su - ${DB2_ADMIN_USER_NAME} -c "db2start"

oc exec c-db2ucluster-db2u-0 -it -- su - ${DB2_ADMIN_USER_NAME} -c "db2 deactivate database BLUDB"

oc exec c-db2ucluster-db2u-0 -it -- su - ${DB2_ADMIN_USER_NAME} -c "db2 drop database BLUDB"

echo
echo "Existing databases are:"
oc exec c-db2ucluster-db2u-0 -it -- su - ${DB2_ADMIN_USER_NAME} -c "db2 list database directory | grep \"Database name\""

echo
echo "Use this hostname/IP to access the databases e.g. with IBM Data Studio."
echo "\x1B[1mPls. also update in ${DB2_INPUT_PROPS_FILENAME} property \"db2HostName\" with this information (in Skytap, use the IP 10.0.0.10 instead).\x1B[0m"
oc get route console -n openshift-console -o yaml | grep routerCanonicalHostname

echo
echo "Use one of these NodePorts to access the databases e.g. with IBM Data Studio (usually the first one is for legacy-server (Db2 port 50000), the second for ssl-server (Db2 port 50001))."
echo "\x1B[1mPls. also update in ${DB2_INPUT_PROPS_FILENAME} property \"db2PortNumber\" with this information (legacy-server).\x1B[0m"
oc get svc -n ${DB2_PROJECT_NAME} c-db2ucluster-db2u-engn-svc -o json | grep nodePort

echo
echo "Use \"${DB2_ADMIN_USER_NAME}\" and password \"${DB2_ADMIN_USER_PASSWORD}\" to access the databases e.g. with IBM Data Studio."

echo
echo "Db2u installation complete! Congratulations. Exiting..."
