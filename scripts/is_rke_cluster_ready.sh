#!/bin/bash

#    _____        _____ _           _              _____                _      ___  
#   |_   _|      / ____| |         | |            |  __ \              | |    |__ \ 
#     | |  ___  | |    | |_   _ ___| |_ ___ _ __  | |__) |___  __ _  __| |_   _  ) |
#     | | / __| | |    | | | | / __| __/ _ \ '__| |  _  // _ \/ _` |/ _` | | | |/ / 
#    _| |_\__ \ | |____| | |_| \__ \ ||  __/ |    | | \ \  __/ (_| | (_| | |_| |_|  
#   |_____|___/  \_____|_|\__,_|___/\__\___|_|    |_|  \_\___|\__,_|\__,_|\__, (_)  
#                                                                         __/ |    
#                                                                        |___/     
       
# Requires:
# - kubectl
# - jq

# Expects:
# - FOLDER: The absolute path where the kube_config.yaml file is located. 

DIRECTORY="$(dirname "$0")"

bash ${DIRECTORY}/header.sh "IS RKE CLUSTER READY...?"

if [ -z "${FOLDER}" ]; then
  echo "Expected FOLDER to point to the location of the kube_config.yaml file!"
  exit 666
fi
echo "FOLDER: ${FOLDER}"

export KUBECONFIG=${FOLDER}/kube_config.yaml         

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

echo "Current Context:"
bash ${DIRECTORY}/print_divider.sh
kubectl config current-context
bash ${DIRECTORY}/print_divider.sh

echo "Are node(s) up...?"

while true; do

    is_cluster_ready

    if [[ $? == 1 ]]; then
        break
    fi

    sleep 10

done

bash ${DIRECTORY}/footer.sh "CLUSTER RKE IS READY."