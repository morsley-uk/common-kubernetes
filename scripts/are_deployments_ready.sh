#!/bin/sh

#set -x

# PARAMETERS:
# 1 --> Folder where kube_config.yaml is
# 2 --> Namespace 

FOLDER=$1
NAMESPACE=$2

DIRECTORY="$(dirname "$0")"

"${DIRECTORY}/header.sh" "ARE DEPLOYMENTS READY...?"

if [[ ! -z "${FOLDER}" ]]; then
    echo "No folder supplied."
    export KUBECONFIG=${FOLDER}/kube_config.yaml
fi

if [[ -z "${NAMESPACE}" ]]; then
    echo "No namespace supplied."
    GET_DEPLOYMENTS="kubectl get deployments --all-namespaces --output json"
else
    echo "Namespace: " ${NAMESPACE}
    GET_DEPLOYMENTS="kubectl get deployments --namespace ${NAMESPACE} --output json"
fi

are_deployments_ready () {
        
  echo ' '  
  "${DIRECTORY}/print_deployment_headers.sh"
  
  is_ready="Yes"

  deployments_json=$($GET_DEPLOYMENTS)  
  number_of_deployments=$(jq '.items | length' <<< $deployments_json)  
  
  for ((i = 0 ; i < number_of_deployments ; i++)); do
   
    deployment_json=$(jq --arg i ${i} '.items[$i|tonumber]' <<< $deployments_json)
    
    deployment_name=$(jq  -r '.metadata.name' <<< $deployment_json)
    
    ready=$(jq '.status.readyReplicas' <<< $deployment_json)
    if "${DIRECTORY}/is_numeric.sh" $ready; then
      ready=0
    fi
    
    expected=$(jq '.spec.replicas' <<< $deployment_json)
    
    available=$(jq '.status.availableReplicas' <<< $deployment_json)
    if "${DIRECTORY}/is_numeric.sh" $available; then
      available=0
    fi
            
    updated=$(jq '.status.updatedReplicas' <<< $deployment_json)
    if "${DIRECTORY}/is_numeric.sh" $updated; then
      updated=0
    fi

    "${DIRECTORY}/print_deployment_row.sh" $ready $expected $available $updated $deployment_name
      
    if [ $ready -ne $expected ]; then
      is_ready="No"  
    fi
      
  done
    
  "${DIRECTORY}/print_deployment_headers.sh"
  echo ' '
    
  echo "${is_ready}"
  
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

#while true; do
#
#    are_deployments_ready 
#
#    if [[ $? == 1 ]]; then
#        break
#    fi
#
#    sleep 10
#
#done

"${DIRECTORY}/header.sh" "DEPLOYMENTS ARE READY"