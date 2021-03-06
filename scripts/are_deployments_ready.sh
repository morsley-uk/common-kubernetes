#!/bin/sh

#         /\             
#        /  \   _ __ ___ 
#       / /\ \ | '__/ _ \
#      / ____ \| | |  __/
#     /_/    \_\_|  \___|                       
#           _____             _                                  _       
#          |  __ \           | |                                | |      
#          | |  | | ___ _ __ | | ___  _   _ _ __ ___   ___ _ __ | |_ ___ 
#          | |  | |/ _ \ '_ \| |/ _ \| | | | '_ ` _ \ / _ \ '_ \| __/ __|
#          | |__| |  __/ |_) | | (_) | |_| | | | | | |  __/ | | | |_\__ \
#          |_____/ \___| .__/|_|\___/ \__, |_| |_| |_|\___|_| |_|\__|___/
#                      | |   _____     __/ |      _         ___                               
#                      |_|  |  __ \   |___/      | |       |__ \ 
#                           | |__) |___  __ _  __| |_   _     ) |
#                           |  _  // _ \/ _` |/ _` | | | |   / / 
#                           | | \ \  __/ (_| | (_| | |_| |  |_|  
#                           |_|  \_\___|\__,_|\__,_|\__, |  (_)  
#                                                    __/ |       
#                                                   |___/        

# Requires:
# - kubectl
# - jq

# Expects:
# 1 --> KUBE_CONGIG_FOLDER (Required): The full path where the kube_config.yaml file is located.
# 2 --> NAMESPACE (Optional): A Namespace to filter by. 

KUBE_CONGIG_FOLDER=$1
NAMESPACE=$2
DIRECTORY="$(dirname "$0")"

bash ${DIRECTORY}/header.sh "ARE DEPLOYMENTS READY...?"
echo "DIRECTORY: ${DIRECTORY}"

bash ${DIRECTORY}/print_divider.sh
if [[ -z "${KUBE_CONGIG_FOLDER}" ]]; then   
    echo "No KUBE_CONGIG_FOLDER supplied."
    exit 666
fi
echo "KUBE_CONGIG_FOLDER:" ${KUBE_CONGIG_FOLDER}

if [[ -z "${NAMESPACE}" ]]; then
    echo "No namespace supplied."
    GET_DEPLOYMENTS="kubectl get deployments --all-namespaces --output json"
else
    echo "NAMESPACE:" ${NAMESPACE}
    GET_DEPLOYMENTS="kubectl get deployments --namespace ${NAMESPACE} --output json"
fi
bash ${DIRECTORY}/print_divider.sh

export KUBECONFIG=${KUBE_CONGIG_FOLDER}/kube-config.yaml

#kubectl get nodes

are_deployments_ready () {
        
  bash ${DIRECTORY}/print_deployment_headers.sh
  
  is_ready="Yes"

  deployments_json=$($GET_DEPLOYMENTS)  
  number_of_deployments=$(jq '.items | length' <<< $deployments_json)  
  
  for ((i = 0 ; i < number_of_deployments ; i++)); do
   
    deployment_json=$(jq --arg i ${i} '.items[$i|tonumber]' <<< $deployments_json)
    
    deployment_name=$(jq  -r '.metadata.name' <<< $deployment_json)
    
    ready=$(jq '.status.readyReplicas' <<< $deployment_json)
    if bash ${DIRECTORY}/is_numeric.sh $ready; then
      ready=0
    fi
    
    expected=$(jq '.spec.replicas' <<< $deployment_json)
    
    available=$(jq '.status.availableReplicas' <<< $deployment_json)
    if bash "${DIRECTORY}/is_numeric.sh" $available; then
      available=0
    fi
            
    updated=$(jq '.status.updatedReplicas' <<< $deployment_json)
    if bash "${DIRECTORY}/is_numeric.sh" $updated; then
      updated=0
    fi

    bash ${DIRECTORY}/print_deployment_row.sh $ready $expected $available $updated $deployment_name
      
    if [ $ready -ne $expected ]; then
      is_ready="No"  
    fi
      
  done
    
  bash ${DIRECTORY}/print_deployment_header.sh
      
  if [ "$is_ready" == "Yes" ]; then
    return 1
  fi 
  
  return 0
  
}

deployments_json=$($GET_DEPLOYMENTS)  
number_of_deployments=$(jq '.items | length' <<< $deployments_json)  

if [[ number_of_deployments == 0 ]]; then 
  echo "No deployments!"
else

while true; do

    are_deployments_ready 

    if [[ $? == 1 ]]; then
        break
    fi

    sleep 10

done
  
fi

bash ${DIRECTORY}/print_divider.sh
if [[ -z "${NAMESPACE}" ]]; then
    echo "kubectl get all --all-namespaces"
    bash ${DIRECTORY}/print_divider.sh
    kubectl get all --all-namespaces    
else
    echo "kubectl get all --namespace ${NAMESPACE}"
    bash ${DIRECTORY}/print_divider.sh
    kubectl get all --namespace ${NAMESPACE}
fi
bash ${DIRECTORY}/print_divider.sh

bash ${DIRECTORY}/footer.sh "DEPLOYMENTS ARE READY"