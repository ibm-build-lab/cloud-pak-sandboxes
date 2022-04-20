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


#ibmcloud login --apikey $IC_API_KEY
#ibmcloud ks cluster config -c $CLUSTER_ID

# CP4BA Database Name information
#db2_default_name=sample-db2
#DB2_USER=db2inst1
#DB2_PROJECT_NAME=ibm-db2

echo
echo -e "\x1B[1mThis script CREATES all needed CP4BA databases (assumes Db2u is running in project ibm-db2). \n \x1B[0m"

function create_appdb() {
    dbname=$1

    echo "*** Creating DB named: ${dbname} ***"

    db2 create database "${dbname}" automatic storage yes  using codeset UTF-8 territory US pagesize 32768;
    db2 connect to "${dbname}";

    db2 CREATE BUFFERPOOL DBASBBP IMMEDIATE SIZE 1024 PAGESIZE 32K;
    db2 CREATE REGULAR TABLESPACE APPENG_TS PAGESIZE 32 K MANAGED BY AUTOMATIC STORAGE DROPPED TABLE RECOVERY ON BUFFERPOOL DBASBBP;
    db2 CREATE USER TEMPORARY TABLESPACE APPENG_TEMP_TS PAGESIZE 32 K MANAGED BY AUTOMATIC STORAGE BUFFERPOOL DBASBBP;

    db2 GRANT USE OF TABLESPACE APPENG_TS TO user "${DB2_USER}";
    db2 GRANT USE OF TABLESPACE APPENG_TEMP_TS TO user "${DB2_USER}";

    db2 grant dbadm on database to user "${DB2_USER}";
    db2 connect reset;
}


function create_basdb() {
    dbname=$1

    echo "*** Creating DB named: ${dbname} ***"

    db2 create database "${dbname}" automatic storage yes using codeset UTF-8 territory US pagesize 32768;
    db2 connect to "${dbname}";
    db2 CREATE USER TEMPORARY TABLESPACE USRTMPSPC1;
    db2 UPDATE DB CFG FOR "${dbname}" USING LOGFILSIZ 16384 DEFERRED;
    db2 UPDATE DB CFG FOR "${dbname}" USING LOGSECOND 64 IMMEDIATE;
    db2 grant dbadm on database to user "${DB2_USER}";
    db2 connect reset;

}


function create_bawdb() {
    dbname=$1

    echo "*** Creating DB named: ${dbname} ***"

    db2 create database "${dbname}" automatic storage yes using codeset UTF-8 territory US pagesize 32768;
    db2 connect to "${dbname}";
    db2 CREATE USER TEMPORARY TABLESPACE USRTMPSPC1;
    db2 UPDATE DB CFG FOR "${dbname}" USING LOGFILSIZ 16384 DEFERRED;
    db2 UPDATE DB CFG FOR "${dbname}" USING LOGSECOND 64 IMMEDIATE;
    db2 grant dbadm on database to user "${DB2_USER}";
    db2 connect reset;
}


function create_gcddb() {
    dbname=$1

    echo "*** Creating DB named: ${dbname} ***"

    db2 create database "${dbname}" automatic storage yes using codeset UTF-8 territory US pagesize 32 K

    db2 connect to "${dbname}"

    db2 drop tablespace USERSPACE1

    echo "*** Create bufferpool ***"
    # Create 1GB fixed bufferpool for performance, automatic tuning for platform

    db2 create bufferpool "${dbname}"_32K immediate size 32768 pagesize 32k

    echo "*** Create table spaces ***"
    db2 CREATE LARGE TABLESPACE "${dbname}"_DATA_TBS PAGESIZE 32 K MANAGED BY AUTOMATIC STORAGE AUTORESIZE YES INITIALSIZE 10G INCREASESIZE 1G MAXSIZE 25G BUFFERPOOL "${dbname}"_32K

    db2 CREATE USER TEMPORARY TABLESPACE "${dbname}"_TMP_TBS PAGESIZE 32 K MANAGED BY AUTOMATIC STORAGE BUFFERPOOL "${dbname}"_32K

    echo "*** Grant permissions to DB user ***"
    db2 GRANT CREATETAB,CONNECT ON DATABASE  TO user "${DB2_USER}"
    db2 GRANT USE OF TABLESPACE "${dbname}"_DATA_TBS TO user "${DB2_USER}"
    db2 GRANT USE OF TABLESPACE "${dbname}"_TMP_TBS TO user "${DB2_USER}"
    db2 GRANT SELECT ON SYSIBM.SYSVERSIONS to user "${DB2_USER}"
    db2 GRANT SELECT ON SYSCAT.DATATYPES to user "${DB2_USER}"
    db2 GRANT SELECT ON SYSCAT.INDEXES to user "${DB2_USER}"
    db2 GRANT SELECT ON SYSIBM.SYSDUMMY1 to user "${DB2_USER}"
    db2 GRANT USAGE ON WORKLOAD SYSDEFAULTUSERWORKLOAD to user "${DB2_USER}"
    db2 GRANT IMPLICIT_SCHEMA ON DATABASE to user "${DB2_USER}"

    echo "*** Apply DB tunings ***"
    db2 update db cfg for "${dbname}" using LOCKTIMEOUT 30
    db2 update db cfg for "${dbname}" using APPLHEAPSZ 2560

    # Let Db2 ootb container settings stay
    #db2 update db cfg for ${dbname} using LOGBUFSZ 212
    #db2 update db cfg for ${dbname} using LOGFILSIZ 6000
    # db2 update db cfg for ${dbname} using LOGPRIMARY 10

    db2 connect reset
    db2 deactivate db "${dbname}"

    echo "*** Done creating and tuning DB named: ${dbname} ***"
}


function create_icndb() {
    dbname=$1

    echo "*** Creating DB named: ${dbname} ***"

    db2 create database "${dbname}" automatic storage yes using codeset UTF-8 territory US pagesize 32 K
    db2 connect to "${dbname}";
    db2 grant dbadm on database to user "${DB2_USER}";
    db2 connect reset;
}


function create_osdb() {
    dbname=$1

    echo "*** Creating DB named: $dbname ***"

    db2 create database "${dbname}" automatic storage yes using codeset UTF-8 territory US pagesize 32 K

    db2 connect to "${dbname}"

    db2 drop tablespace USERSPACE1

    echo "*** Create bufferpool ***"
    # Create 1GB fixed bufferpool for performance, automatic tuning for platform

    db2 create bufferpool "${dbname}"_32K immediate size 32768 pagesize 32k

    echo "*** Create table spaces ***"
    db2 CREATE LARGE TABLESPACE "${dbname}"_DATA_TBS PAGESIZE 32 K MANAGED BY AUTOMATIC STORAGE AUTORESIZE YES INITIALSIZE 10G INCREASESIZE 1G MAXSIZE 25G BUFFERPOOL "${dbname}"_32K

    db2 CREATE USER TEMPORARY TABLESPACE "${dbname}"_TMP_TBS PAGESIZE 32 K MANAGED BY AUTOMATIC STORAGE BUFFERPOOL "${dbname}"_32K

    echo "*** Grant permissions to DB user ***"
    db2 GRANT CREATETAB,CONNECT ON DATABASE  TO user "${DB2_USER}"
    db2 GRANT USE OF TABLESPACE "${dbname}"_DATA_TBS TO user "${DB2_USER}"
    db2 GRANT USE OF TABLESPACE "${dbname}"_TMP_TBS TO user "${DB2_USER}"
    db2 GRANT SELECT ON SYSIBM.SYSVERSIONS to user "${DB2_USER}"
    db2 GRANT SELECT ON SYSCAT.DATATYPES to user "${DB2_USER}"
    db2 GRANT SELECT ON SYSCAT.INDEXES to user "${DB2_USER}"
    db2 GRANT SELECT ON SYSIBM.SYSDUMMY1 to user "${DB2_USER}"
    db2 GRANT USAGE ON WORKLOAD SYSDEFAULTUSERWORKLOAD to user "${DB2_USER}"
    db2 GRANT IMPLICIT_SCHEMA ON DATABASE to user "${DB2_USER}"

    echo "*** Apply DB tunings ***"
    db2 update db cfg for "${dbname}" using LOCKTIMEOUT 30
    db2 update db cfg for "${dbname}" using APPLHEAPSZ 2560
    db2 update db cfg using cur_commit ON

    # Let Db2 ootb container settings stay
    #db2 update db cfg for ${dbname} using LOGBUFSZ 212
    #db2 update db cfg for ${dbname} using LOGFILSIZ 6000
    # db2 update db cfg for ${dbname} using LOGPRIMARY 10

    db2 connect reset
    db2 deactivate db "${dbname}"

    echo "*** Done creating and tuning DB named: ${dbname} ***"
}


function create_umsdb() {
  dbname=$1

  echo "*** Creating DB named: ${dbname} ***"

  db2 create database "${dbname}" automatic storage yes using codeset UTF-8 territory US pagesize 32768;
  db2 connect to "${dbname}";
  db2 grant dbadm on database to user "${DB2_USER}";
  db2 connect reset;
}


function activate_database() {
    dbname=$1

    echo "Activating ${dbname} database ..."
    echo
    oc exec c-db2ucluster-db2u-0 -it -- su - "${DB2_USER}" -c "db2 activate database ${dbname}"
    sleep 5
    echo
}

for name in umsdb appdb basdb bawdb gcddb icndb devos1 aeos bawdocs bawtos bawdos aedb osdb;
do
  dbname="${db2_default_name}-${name}"
  if [ $name == umsdb ]
  then
      kubectl -n "${DB2_PROJECT_NAME}" exec c-db2ucluster-db2u-0 -it -- su ""| create_umsdb "${dbname}"
      activate_database "${dbname}"
  #    kubectl -n "${DB2_PROJECT_NAME}" exec c-db2ucluster-db2u-0 -it -- /bin/sh -c chmod a+x ./create_db2_schemas.sh | create_umsdb "${dbname}"
  #    echo $dbname
      echo
  elif [ $name == appdb ]; then
      kubectl -n "${DB2_PROJECT_NAME}" exec c-db2ucluster-db2u-0 -it -- su ""| create_appdb "${dbname}"
      activate_database "${dbname}"
      echo
  elif [ $name == basdb ]; then
      kubectl -n "${DB2_PROJECT_NAME}" exec c-db2ucluster-db2u-0 -it -- su ""| create_basdb "${dbname}"
      activate_database "${dbname}"
      echo
  elif [ $name == bawdb ]; then
      kubectl -n "${DB2_PROJECT_NAME}" exec c-db2ucluster-db2u-0 -it -- su ""| create_bawdb "${dbname}"
      activate_database "${dbname}"
      echo
  elif [ $name == gcddb ]; then
      kubectl -n "${DB2_PROJECT_NAME}" exec c-db2ucluster-db2u-0 -it -- su ""| create_gcddb "${dbname}"
      activate_database "${dbname}"
      echo
  elif [ $name == icndb ]; then
      kubectl -n "${DB2_PROJECT_NAME}" exec c-db2ucluster-db2u-0 -it -- su ""| create_icndb "${dbname}"
      activate_database "${dbname}"
      echo
  elif [ $name == osdb ]; then
      kubectl -n "${DB2_PROJECT_NAME}" exec c-db2ucluster-db2u-0 -it -- su ""| create_osdb "${dbname}"
      activate_database "${dbname}"
      echo
  elif [ $name == devos1 ]; then
      kubectl -n "${DB2_PROJECT_NAME}" exec c-db2ucluster-db2u-0 -it -- su ""| create_osdb "${dbname}"
      activate_database "${dbname}"
      echo
  elif [ $name == aeos ]; then
      kubectl -n "${DB2_PROJECT_NAME}" exec c-db2ucluster-db2u-0 -it -- su ""| create_osdb "${dbname}"
      activate_database "${dbname}"
      echo
  elif [ $name == bawdocs ]; then
      kubectl -n "${DB2_PROJECT_NAME}" exec c-db2ucluster-db2u-0 -it -- su ""| create_osdb "${dbname}"
      activate_database "${dbname}"
      echo
  elif [ $name == bawtos ]; then
      kubectl -n "${DB2_PROJECT_NAME}" exec c-db2ucluster-db2u-0 -it -- su ""| create_osdb "${dbname}"
      activate_database "${dbname}"
      echo
  elif [ $name == bawdos ]; then
      kubectl -n "${DB2_PROJECT_NAME}" exec c-db2ucluster-db2u-0 -it -- su ""| create_osdb "${dbname}"
      activate_database "${dbname}"
      echo
  elif [ $name == aedb ]; then
      kubectl -n "${DB2_PROJECT_NAME}" exec c-db2ucluster-db2u-0 -it -- su ""| create_appdb "${dbname}"
      activate_database "${dbname}"
      echo
  else
      continue
  fi
done


echo
echo "Restarting Db2..."
oc exec c-db2ucluster-db2u-0 -it -- su - "${DB2_USER}" -c "db2stop"
sleep 5
oc exec c-db2ucluster-db2u-0 -it -- su - "${DB2_USER}" -c "db2start"
sleep 5


# **************************** WILL BE REMOVED
#echo "File path:"
#echo $CUR_DIR/createUMSDB.sh
#dbname=umsdb
#echo "Creating database ${dbname}"
#kubectl -n "${DB2_PROJECT_NAME}" cp createUMSDB.sh c-db2ucluster-db2u-0:/tmp/
#kubectl -n "${DB2_PROJECT_NAME}" exec c-db2ucluster-db2u-0 -it -- /bin/sh -c "chmod a+x /tmp/createUMSDB.sh"
#kubectl -n "${DB2_PROJECT_NAME}" exec c-db2ucluster-db2u-0 -it -- su ${"${DB2_USER}"} -c "/tmp/createUMSDB.sh ${dbname} ${"${DB2_USER}"}"
#kubectl -n "${DB2_PROJECT_NAME}" exec c-db2ucluster-db2u-0 -it -- /bin/sh -c "rm /tmp/createUMSDB.sh"

#
#kubectl -n "${DB2_PROJECT_NAME}" cp createUMSDB.sh c-db2ucluster-db2u-0:/tmp/
#kubectl -n "${DB2_PROJECT_NAME}" exec c-db2ucluster-db2u-0 -it -- /bin/sh -c "chmod a+x $CUR_DIR/createUMSDB.sh"
#kubectl -n "${DB2_PROJECT_NAME}" exec c-db2ucluster-db2u-0 -it -- su ${"${DB2_USER}"} -c "$CUR_DIR/createUMSDB.sh ${dbname} ${"${DB2_USER}"}"
#kubectl -n "${DB2_PROJECT_NAME}" exec c-db2ucluster-db2u-0 -it -- /bin/sh -c "rm $CUR_DIR/createUMSDB.sh"
# ****************************

