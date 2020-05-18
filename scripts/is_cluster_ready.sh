#!/bin/bash

#      _____        _____ _           _              
#     |_   _|      / ____| |         | |            
#       | |  ___  | |    | |_   _ ___| |_ ___ _ __ 
#       | | / __| | |    | | | | / __| __/ _ \ '__| 
#      _| |_\__ \ | |____| | |_| \__ \ ||  __/ |     
#     |_____|___/  \_____|_|\__,_|___/\__\___|_|     
#           _____                _         ___  
#          |  __ \              | |       |__ \ 
#          | |__) |___  __ _  __| |_   _     ) |
#          |  _  // _ \/ _` |/ _` | | | |   / / 
#          | | \ \  __/ (_| | (_| | |_| |  |_|  
#          |_|  \_\___|\__,_|\__,_|\__, |  (_)  
#                                   __/ |       
#                                  |___/        

# Requires:
# - kubectl
# - jq

# Expects:
# 1 --> KUBE_CONFIG_FOLDER (Required): The full path where the 
#                                      kube-config.yaml file is located.

KUBE_CONFIG_FOLDER=$1

DIRECTORY="$(dirname "$0")"
echo "DIRECTORY: ${DIRECTORY}"

#bash ${DIRECTORY}/header.sh "IS CLUSTER READY...?"

#bash ${DIRECTORY}/print_divider.sh

if [[ -z "${KUBE_CONFIG_FOLDER}" ]]; then
  echo "No KUBE_CONFIG_FOLDER supplied."
  exit 666
fi
echo "KUBE_CONFIG_FOLDER: ${KUBE_CONFIG_FOLDER}"

#bash ${DIRECTORY}/print_divider.sh

export KUBECONFIG=${KUBE_CONFIG_FOLDER}/kube-config.yaml         

is_cluster_ready () {

    nodes_json=$(kubectl get nodes --output "json" 2>/dev/null)

    if [ -z "$nodes_json" ]; then
      echo "No"
      return 0
    fi

    number_of_nodes=$(jq '.items | length' <<< $nodes_json)

    if [[ $number_of_nodes == 0 ]]; then
        echo "No - Number of Nodes: ${number_of_nodes}"
        return 0
    fi

    feedback="Number of Nodes: ${number_of_nodes} | "

    for ((i = 0 ; i < number_of_nodes ; i++))
    do
        node_json=$(jq --arg i ${i} '.items[$i|tonumber]' <<< $nodes_json)
        node_name=$(jq '.metadata.name' <<< $node_json)
        node_status=$(jq '.status.conditions[] | select(.reason == "KubeletReady") | .type' <<< $node_json)
        feedback+="Node $((i+1)): ${node_name} | Status: ${node_status}"
    done

    if [ "${node_status}" == '"Ready"' ]; then
        echo "Yes"
        return 1
    fi
    echo "No - $feedback"
    return 0

}  

#bash ${DIRECTORY}/print_divider.sh
echo "kubectl config current-context"
#bash ${DIRECTORY}/print_divider.sh
kubectl config current-context
#bash ${DIRECTORY}/print_divider.sh

echo "Are node(s) up...?"

while true; do

    is_cluster_ready

    if [[ $? == 1 ]]; then
        break
    fi

    sleep 10

done

#bash ${DIRECTORY}/print_divider.sh
echo "kubectl cluster-info"
#bash ${DIRECTORY}/print_divider.sh
kubectl cluster-info

#bash ${DIRECTORY}/print_divider.sh
echo "kubectl get nodes"
#bash ${DIRECTORY}/print_divider.sh
kubectl get nodes

#bash ${DIRECTORY}/print_divider.sh

#bash ${DIRECTORY}/footer.sh "CLUSTER IS READY"

#bash ${DIRECTORY}/are_deployments_ready.sh ${FOLDER}

exit 0