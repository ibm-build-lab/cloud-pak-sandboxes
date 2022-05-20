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

DB2_PROJECT_NAME=$1
DB2_USER=$2


echo
echo -e "\x1B[1mThis script CREATES all needed CP4BA databases (assumes Db2u is running in project ibm-db2). \n \x1B[0m"

function create_appdb() {
    dbname=$1

    echo "*** Creating ${dbname} database ... ***"

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

    echo "*** Creating ${dbname} database ... ***"

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

    echo "*** Creating ${dbname} database ... ***"

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

    echo "*** Creating ${dbname} database ... ***"

    db2 create database "${dbname}" automatic storage yes using codeset UTF-8 territory US pagesize 32 K

    db2 connect to "${dbname}"

    db2 drop tablespace USERSPACE1

    echo "*** Create bufferpool ***"

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

    db2 connect reset
    db2 deactivate db "${dbname}"

    echo "*** Done creating and tuning DB named: ${dbname} ***"
}


function create_icndb() {
    dbname=$1

    echo "*** Creating ${dbname} database ... ***"

    db2 create database "${dbname}" automatic storage yes using codeset UTF-8 territory US pagesize 32 K
    db2 connect to "${dbname}";
    db2 grant dbadm on database to user "${DB2_USER}";
    db2 connect reset;
}


function create_osdb() {
    dbname=$1

    echo "*** Creating ${dbname} database ... ***"

    db2 create database "${dbname}" automatic storage yes using codeset UTF-8 territory US pagesize 32 K

    db2 connect to "${dbname}"

    db2 drop tablespace USERSPACE1

    echo "*** Create bufferpool ***"

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

    db2 connect reset
    db2 deactivate db "${dbname}"

    echo "*** Done creating and tuning DB named: ${dbname} ***"
}


function create_umsdb() {
  dbname=$1

  echo "*** Creating ${dbname} database ... ***"

  db2 create database "${dbname}" automatic storage yes using codeset UTF-8 territory US pagesize 32768;
  db2 connect to "${dbname}";
  db2 grant dbadm on database to user "${DB2_USER}";
  db2 connect reset;
}


for name in umsdb appdb basdb bawdb gcddb icndb devos1 aeos bawdocs bawtos bawdos aedb osdb;
do
  dbname="${name}"
  if [ $name == umsdb ]
  then
      create_umsdb "${dbname}"
      sleep 15
      echo
  elif [ $name == appdb ]; then
      create_appdb "${dbname}"
      sleep 15
      echo
  elif [ $name == basdb ]; then
      create_basdb "${dbname}"
      sleep 15
      echo
  elif [ $name == bawdb ]; then
      create_bawdb "${dbname}"
      sleep 15
      echo
  elif [ $name == gcddb ]; then
      create_gcddb "${dbname}"
      sleep 15
      echo
  elif [ $name == icndb ]; then
      create_icndb "${dbname}"
      sleep 15
      echo
  elif [ $name == osdb ]; then
      create_osdb "${dbname}"
      sleep 15
      echo
  elif [ $name == devos1 ]; then
      create_osdb "${dbname}"
      sleep 15
      echo
  elif [ $name == aeos ]; then
      create_osdb "${dbname}"
      sleep 15
      echo
  elif [ $name == bawdocs ]; then
      create_osdb "${dbname}"
      sleep 15
      echo
  elif [ $name == bawtos ]; then
      create_osdb "${dbname}"
      sleep 15
      echo
  elif [ $name == bawdos ]; then
      create_osdb "${dbname}"
      sleep 15
      echo
  elif [ $name == aedb ]; then
      create_appdb "${dbname}"
      sleep 15
      echo
  else
      continue
  fi
done





