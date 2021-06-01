bold=$(tput setaf 4; tput bold)
normal=$(tput sgr0)
green=$(tput setaf 2; tput bold)

VPC_LENGTH=0
SUBNET_LENGTH=0

RESOURCEGROUPNAME="cloud-pak-sandbox"

get_vpc() {
    ibmcloud is vpcs --json  > vpc-list.json
    VPC_LENGTH=$(jq '. | length' vpc-list.json)
}

get_subnet() {
    ibmcloud is subnets --json > subnets-list.json
    SUBNET_LENGTH=$(jq '. | length' subnets-list.json)
}

get_vpn() {
    ibmcloud is vpcs --json  > vpn-list.json
    VPN_LENGTH=$(jq '. | length' vpn-list.json)
}

get_load_balancer() {
    ibmcloud is load-balancers --json > balance-list.json
    BALANCE_LENGTH=$(jq '. | length' balance-list.json)

}

get_instances() {
    ibmcloud is instances --json > instance-list.json
    INSTANCE_LENGTH=$(jq '. | length' instance-list.json)
}

get_gateway() {
    ibmcloud is public-gateways --json > gateway-list.json
    GATEWAY=$(jq '. | length' gateway-list.json)
}

delete_vpc() {
    VPC_OPTION="0"
    get_vpc
    echo ""
    echo "${bold}"
    echo $VPC_LENGTH " VPC's available${normal}"
    while true;
    do
        echo "${green}"
        for (( c=1; c<=$VPC_LENGTH; c++))
        do 
            TEMP=$(jq -c --argjson v "$c" '(  .[$v-1] | .name, .id)' vpc-list.json )
            echo $c". "$TEMP
        done
        echo $c". EXIT"
        echo "${bold}Type 0 to refresh available VPC${normal}"
        read -p "${bold}Choose a VPC for deleting:${normal} " -e VPC_OPTION

        if (($VPC_OPTION == $c))
        then break
        elif (($VPC_OPTION>0)) && (($VPC_OPTION<=$VPC_LENGTH))
        then echo "${bold}Preparing to delete...${normal}"
             VPC_OPTION=$(($VPC_OPTION-1))
             VPC_ID=$(jq -r --argjson v "$VPC_OPTION" '(.[$v] | .id)' vpc-list.json )
             VPC_NAME=$(jq -r --argjson v "$VPC_OPTION" '(.[$v] | .name)' vpc-list.json )
             echo "${bold}Continue to delete...?${green}"
             echo $VPC_NAME
             echo $VPC_ID
             echo "${bold}Choose:${green}"
             echo "1. yes"
             echo "2. no"
             read -p "${bold}  ${normal} " -e CONTINUE
             if (($CONTINUE == 1))
             then echo "${bold}deleting ${green}$VPC_NAME${bold}"
                  echo "Select dependent resources to clear...${normal}"
                  #ibmcloud schematics workspace delete --id $WORKSPACE --force
                  delete_subnet
                  delete_gateway
                  ibmcloud is vpc-delete $VPC_ID --force
                  get_vpc
             else echo "${bold}not deleting $WORKSPACE${normal}"
                  get_vpc
             fi
        elif (($VPC_OPTION == 0))
        then echo "${bold}Refrehing VPC's...${normal}"
             get_vpc
        else echo "${bold}PLEASE TRY AGAIN${normal}"
             get_vpc
        fi
    done    
}

delete_subnet() {
    SUBNET_OPTION="0"
    get_subnet
    echo ""
    echo "${bold}"
    echo $SUBNET_LENGTH " SUBNET's available${normal}"
    while true;
    do
        echo "${green}"
        for (( c=1; c<=$SUBNET_LENGTH; c++))
        do 
            TEMP=$(jq -c --argjson v "$c" '(  .[$v-1] | .name, .id)' subnets-list.json )
            echo $c". "$TEMP
        done
        echo $c". EXIT"
        echo "${bold}Type 0 to refresh available SUBNET${normal}"
        read -p "${bold}Choose a SUBNET for deleting:${normal} " -e SUBNET_OPTION

        if (($SUBNET_OPTION == $c))
        then break
        elif (($SUBNET_OPTION>0)) && (($SUBNET_OPTION<=$SUBNET_LENGTH))
        then echo "${bold}Preparing to delete...${normal}"
             SUBNET_OPTION=$(($SUBNET_OPTION-1))
             SUBNET_ID=$(jq -r --argjson v "$SUBNET_OPTION" '(.[$v] | .id)' subnets-list.json )
             SUBNET_NAME=$(jq -r --argjson v "$SUBNET_OPTION" '(.[$v] | .name)' subnets-list.json )
             echo "${bold}Continue to delete...${green}"
             echo $SUBNET_ID
             echo $SUBNET_NAME
             echo "${bold}Choose:${green}"
             echo "1. yes"
             echo "2. no"
             read -p "${bold}  ${normal} " -e CONTINUE
             if (($CONTINUE == 1))
             then echo "${bold}cleaning up ${green}$SUBNET_NAME${bold}"
                  delete_vpn
                  delete_balance
                  delete_instances
                  echo "${bold}deleting ${green}$SUBNET_NAME${bold}"
                  ibmcloud is subnet-delete $SUBNET_ID --force
                  get_subnet
             else echo "${bold}not deleting $WORKSPACE${normal}"
                  get_subnet
             fi
        elif (($SUBNET_OPTION == 0))
        then echo "${bold}Refrehing VPC's...${normal}"
             get_subnet
        else echo "${bold}PLEASE TRY AGAIN${normal}"
             get_subnet
        fi
    done    
}

delete_vpn() {
    get_vpn
    echo "Searching for VPN's with Subnet $SUBNET_NAME..."
    for (( c=1; c<=$VPN_LENGTH; c++))
    do 
        VPN_ID=$(jq -r --argjson v "$c" '.[$v-1] |  .id' vpn-list.json)
        VPN_SUBNET=$(jq -r -c --argjson v "$c" '.[$v-1] | .subnets[0] | .name' vpn-list.json)
        if [[ "$VPN_SUBNET" == "$SUBNET_NAME" ]];
        then 
            echo "Deleting VPN gateway $VPN_ID"
            ibmcloud is vpn-gateway-delete $VPN_ID --force
        fi
    done
}

delete_balance() {
get_load_balancer
echo "Searching for Load Balancers with Subnet $SUBNET_NAME..."
for (( c=1; c<=$BALANCE_LENGTH; c++))
do 
    LOAD_BALANCE_ID=$(jq -r --argjson v "$c" '.[$v-1] | .id' balance-list.json)
    LOAD_BALANCE_SUBNET=$(jq -r -c --argjson v "$c" '.[$v-1] | .subnets[0] | .name' balance-list.json)
    if [[ "$LOAD_BALANCE_SUBNET" == "$SUBNET_NAME" ]];
    then 
        echo "Deleting Load Balancer $LOAD_BALANCE_ID"
        ibmcloud is load-balancer-delete $LOAD_BALANCE_ID --force
    fi
done
}

delete_instances() {
    get_instances
    echo "Searching for Instances with Subnet $SUBNET_NAME..."
    for (( c=1; c<=$INSTANCE_LENGTH; c++))
    do 
        INSTANCE_ID=$(jq -r --argjson v "$c" '.[$v-1] | .id' instance-list.json)
        INSTANCE_SUBNET=$(jq -r -c --argjson v "$c" '.[$v-1] | .subnets[0] | .name' instance-list.json)
        if [[ "$INSTANCE_SUBNET" == "$SUBNET_NAME" ]];
        then 
            echo "Deleting instance $INSTANCE_ID"
            ibmcloud is vpn-gateway-delete $INSTANCE_ID --force
        fi
    done
}

delete_gateway() {
    GATEWAY_OPTION="0"
    get_gateway
    echo ""
    echo "${bold}"
    echo $GATEWAY_LENGTH " Gateway's available${normal}"
        while true;
    do
        echo "${green}"
        for (( c=1; c<=$GATEWAY_LENGTH; c++))
        do 
            TEMP=$(jq -c --argjson v "$c" '(  .[$v-1] | [.name, .vpc.name])' gateway-list.json )
            echo $c". "$TEMP
        done
        echo $c". EXIT"
        echo "${bold}Type 0 to refresh available Gateways${normal}"
        read -p "${bold}Choose a Gateway for deleting:${normal} " -e GATEWAY_OPTION

        if (($GATEWAY_OPTION == $c))
        then break
        elif (($GATEWAY_OPTION>0)) && (($GATEWAY_OPTION<=$GATEWAY_LENGTH))
        then echo "${bold}Preparing to delete...${normal}"
                GATEWAY_OPTION=$(($GATEWAY_OPTION-1))
                GATEWAY_ID=$(jq -r --argjson v "$GATEWAY_OPTION" '(.[$v] | .id)' gateway-list.json )
                echo "${bold}Continue to delete...${green}"
                echo $GATEWAY_NAME
                echo $GATEWAY_ID
                echo "${bold}Choose:${green}"
                echo "1. yes"
                echo "2. no"
                read -p "${bold}  ${normal} " -e CONTINUE
                if (($CONTINUE == 1))
                then echo "${bold}deleting ${green}$GATEWAY_NAME${bold}"
                    echo "Select dependent resources to clear...${normal}"
                    ibmcloud is public-gateway-delete $GATEWAY_ID --force
                    get_gateway
                else echo "${bold}not deleting $WORKSPACE${normal}"
                    get_gateway
                fi
        elif (($GATEWAY_OPTION == 0))
        then echo "${bold}Refrehing VPC's...${normal}"
                get_gateway
        else echo "${bold}PLEASE TRY AGAIN${normal}"
                get_gateway
        fi
    done    
}

delete_vpc


rm -rf balance-list.json
rm -rf gateway-list.json
rm -rf subnets-list.json
rm -rf vpc-list.json


