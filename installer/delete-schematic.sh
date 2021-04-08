bold=$(tput setaf 4; tput bold)
normal=$(tput sgr0)
green=$(tput setaf 2; tput bold)

LENGTH=0

RESOURCEGROUPNAME="cloud-pak-sandbox"


get_schematics() {
    ibmcloud schematics workspace list --json > list-schematics.json
    LENGTH=$(jq '.workspaces | length' list-schematics.json)
}

delete_schematics() {
    SCHEMATICS_OPTION="0"
    get_schematics
    echo ""
    echo "${bold}"
    echo $LENGTH " Workspaces available${normal}"
    while true;
    do
        echo "${green}"
        for (( c=1; c<=$LENGTH; c++))
        do 
            TEMP=$(jq -c --argjson v "$c" '(.workspaces | .[$v-1] | .status, .name)' list-schematics.json )
            echo $c". "$TEMP
        done
        echo $c". EXIT"
        echo "${bold}Type 0 to refresh available Workspaces${normal}"
        read -p "${bold}Choose a Workspace for deleting:${normal} " -e SCHEMATICS_OPTION

        if (($SCHEMATICS_OPTION == $c))
        then break
        elif (($SCHEMATICS_OPTION>0)) && (($SCHEMATICS_OPTION<=$LENGTH))
        then echo "${bold}Preparing to delete...${normal}"
             SCHEMATICS_OPTION=$(($SCHEMATICS_OPTION-1))
             WORKSPACE=$(jq -r --argjson v "$SCHEMATICS_OPTION" '(.workspaces | .[$v] | .id)' list-schematics.json )
             echo "${bold}Continue to delete...${green}"
             echo $WORKSPACE
             echo "${bold}Choose:${green}"
             echo "1. yes"
             echo "2. no"
             read -p "${bold}  ${normal} " -e CONTINUE
             if (($CONTINUE == 1))
             then echo "${bold}deleting ${green}$WORKSPACE${bold}"
                  echo "This may take some time.${normal}"
                  ibmcloud schematics workspace delete --id $WORKSPACE --force
                  get_schematics
             else echo "${bold}not deleting $WORKSPACE${normal}"
                  get_schematics
             fi
        elif (($SCHEMATICS_OPTION == 0))
        then echo "${bold}Refrehing Public VLANs...${normal}"
             get_schematics
        else echo "${bold}PLEASE TRY AGAIN${normal}"
             get_schematics
        fi
    done    
}

get_clusters() {
    ibmcloud ks cluster ls --json > cluster-list.json
    CLUSTER_LENGTH=$(jq length cluster-list.json)
}

delete_clusters() {
    CLUSTER_OPTION="0"
    get_clusters
    echo ""
    echo "${bold}"
    echo $CLUSTER_LENGTH " Clusters available${normal}"
    while true;
    do
        echo "${green}"
        for (( c=1; c<=$CLUSTER_LENGTH; c++))
        do 
            TEMP=$(jq -r ".[$c-1] | {name: .name,  state: .state,  region: .region,  id: .id}" cluster-list.json )
            echo $c". "$TEMP
        done
        echo $c". EXIT"
        echo "${bold}Type 0 to refresh available Clusters${normal}"
        read -p "${bold}Choose a Cluster for deleting:${normal} " -e CLUSTER_OPTION

        if (($CLUSTER_OPTION == $c))
        then break
        elif (($CLUSTER_OPTION>0)) && (($CLUSTER_OPTION<=$CLUSTER_LENGTH))
        then echo "${bold}Preparing to delete...${normal}"
             CLUSTER_OPTION=$(($CLUSTER_OPTION-1))
             CLUSTER=$(jq -r --argjson v "$CLUSTER_OPTION" '(.[$v] | .id)' cluster-list.json )
             echo "${bold}Continue to delete...${green}"
             echo $CLUSTER
             echo "${bold}Choose:${green}"
             echo "1. yes"
             echo "2. no"
             read -p "${bold} ${normal} " -e CONTINUE
             if (($CONTINUE == 1))
             then echo "${bold}deleting ${green}$CLUSTER${bold}"
                  echo "This may take some time.${normal}"
                  ibmcloud ks cluster rm --cluster $CLUSTER --force-delete-storage -f 
                  get_clusters
             else echo "${bold}not deleting ${green}$CLUSTER${normal}"
                  get_clusters
             fi
        elif (($CLUSTER_OPTION == 0))
        then echo "${bold}Refrehing Clusters...${normal}"
             get_clusters
        else echo "${bold}PLEASE TRY AGAIN${normal}"
             get_clusters
        fi
    done
}

echo "${bold}What you would like to do:${normal}"
while true;
do
    echo "${green}1. Delete Clusters"
    echo "2. Delete Schematics"
    echo "3. EXIT${normal}"
    read -p "${bold}select value:${normal} " -e OPTION
    if (($OPTION == 3))
    then break
    elif (($OPTION == 1))
    then delete_clusters
         rm cluster-list.json
    elif (($OPTION == 2))
    then delete_schematics
         rm list-schematics.json
    else echo "${green}PLEASE TRY AGAIN${normal}"
    fi
done
