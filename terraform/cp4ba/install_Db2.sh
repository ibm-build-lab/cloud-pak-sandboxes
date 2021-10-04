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
DB2_SUBSCRIPTION_CONTENT=db2_subscription.yaml
DB2_FILE=${CUR_DIR}/db2.yaml

DB2_PROJECT_NAME="ibm-db2"
OC_CMD=oc

echo
echo "Creating Storage Class ..."
${OC_CMD} apply -f storage_class.yaml
sleep 10

kubectl patch storageclass ibmc-block-gold -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
kubectl patch storageclass cp4a-file-retain-gold-gid -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

echo
echo "Installing the IBM Operator Catalog..."
${OC_CMD} apply -f ${CATALOG_SOURCE_FILE}

echo
echo "Creating project ${DB2_PROJECT_NAME}..."
${OC_CMD} new-project ${DB2_PROJECT_NAME}
${OC_CMD} project ${DB2_PROJECT_NAME}

echo
echo "Creating secret ibm-db2-registry. For this, your Entitlement Registry key is needed."
echo
echo "You can get the Entitlement Registry key from here: https://myibm.ibm.com/products-services/containerlibrary"
echo

${OC_CMD} create secret docker-registry ibm-db2-registry --docker-server=${DOCKER_REG_SERVER} --docker-username=${DOCKER_REG_USER} --docker-password=${ENTITLEMENTKEY} --docker-email=${EMAIL} --namespace=${DB2_PROJECT_NAME}

echo "Preparing the cluster for Db2..."
${OC_CMD} get no -l node-role.kubernetes.io/worker --no-headers -o name | xargs -I {} --  oc debug {} -- chroot /host sh -c 'grep "^Domain = slnfsv4.coms" /etc/idmapd.conf || ( sed -i.bak "s/.*Domain =.*/Domain = slnfsv4.com/g" /etc/idmapd.conf; nfsidmap -c; rpc.idmapd )'

echo
echo "Modifying the OpenShift Global Pull Secret (you need jq tool for that):"
echo $(${OC_CMD} get secret pull-secret -n openshift-config --output="jsonpath={.data.\.dockerconfigjson}" | base64 --decode; oc get secret ibm-db2-registry -n ${DB2_PROJECT_NAME} --output="jsonpath={.data.\.dockerconfigjson}" | base64 --decode) | jq -s '.[0] * .[1]' > dockerconfig_merged
${OC_CMD} set data secret/pull-secret -n openshift-config --from-file=.dockerconfigjson=dockerconfig_merged

echo

if ${OC_CMD} get catalogsource -n openshift-marketplace | grep ibm-operator-catalog ; then
        echo "Found ibm operator catalog source"
    else
        ${OC_CMD} apply -f "${CATALOG_SOURCE_FILE}"
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

      isReady=$(${OC_CMD} get pod -n openshift-marketplace --no-headers | grep ibm-operator-catalog | grep "Running")
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

###### Create subscription to Db2 Operator
echo -e "\x1B[1mCreating the Subscription...\n${DB2_SUBSCRIPTION_CONTENT}\n\x1B[0m"
kubectl apply -f -<<EOF
${DB2_SUBSCRIPTION_CONTENT}
EOF
echo "Sleeping for 5 minutes"
sleep 150

echo "Deploying the Db2u cluster ..."

db2License="accept: true"
if [ "$DB2_PROJECT_NAME" == "" ]; then
   db2License="accept: true"
else
   db2License="value: $DB2_STANDARD_LICENSE_KEY"
fi
sed -i.bak "s|db2License|$db2License|g" ${DB2_FILE}
${OC_CMD} apply -f ${DB2_FILE}
sleep 10

${OC_CMD} get pods -n ${DB2_PROJECT_NAME}

echo

echo "Finally, this script will patch the running Db2u cluster to apply the NUMDB change..."
${OC_CMD} exec c-db2ucluster-db2u-0 -it -- su - ${DB2_ADMIN_USER_NAME} -c "db2 update dbm cfg using numdb 20"
${OC_CMD} exec c-db2ucluster-db2u-0 -it -- su - ${DB2_ADMIN_USER_NAME} -c "db2set DB2_WORKLOAD=FILENET_CM"
${OC_CMD} exec c-db2ucluster-db2u-0 -it -- su - ${DB2_ADMIN_USER_NAME} -c "set CUR_COMMIT=ON"
${OC_CMD} exec c-db2ucluster-db2u-0 -it -- su - ${DB2_ADMIN_USER_NAME} -c "db2stop"
${OC_CMD} exec c-db2ucluster-db2u-0 -it -- su - ${DB2_ADMIN_USER_NAME} -c "db2start"
${OC_CMD} exec c-db2ucluster-db2u-0 -it -- su - ${DB2_ADMIN_USER_NAME} -c "db2 deactivate database BLUDB"
${OC_CMD} exec c-db2ucluster-db2u-0 -it -- su - ${DB2_ADMIN_USER_NAME} -c "db2 drop database BLUDB"

echo
echo "Existing databases are:"
${OC_CMD} exec c-db2ucluster-db2u-0 -it -- su - ${DB2_ADMIN_USER_NAME} -c "db2 list database directory | grep \"Database name\""

echo
echo "Use this hostname/IP to access the databases e.g. with IBM Data Studio."
echo "\x1B[1mPls. also update in ${DB2_INPUT_PROPS_FILENAME} property \"db2HostName\" with this information (in Skytap, use the IP 10.0.0.10 instead).\x1B[0m"
${OC_CMD} get route console -n openshift-console -o yaml | grep routerCanonicalHostname

echo
echo "Use one of these NodePorts to access the databases e.g. with IBM Data Studio (usually the first one is for legacy-server (Db2 port 50000), the second for ssl-server (Db2 port 50001))."
echo "\x1B[1mPls. also update in ${DB2_INPUT_PROPS_FILENAME} property \"db2PortNumber\" with this information (legacy-server).\x1B[0m"
${OC_CMD} get svc -n ${DB2_PROJECT_NAME} c-db2ucluster-db2u-engn-svc -o json | grep nodePort

echo
echo "Use \"${DB2_ADMIN_USER_NAME}\" and password \"${DB2_ADMIN_USER_PASSWORD}\" to access the databases e.g. with IBM Data Studio."

echo
echo "Db2u installation complete! Congratulations. Exiting..."
