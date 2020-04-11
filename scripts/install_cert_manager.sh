#!/usr/bin/env bash

#    _____           _        _ _    _____          _          __  __                                   
#   |_   _|         | |      | | |  / ____|        | |        |  \/  |                                  
#     | |  _ __  ___| |_ __ _| | | | |     ___ _ __| |_ ______| \  / | __ _ _ __   __ _  __ _  ___ _ __ 
#     | | | '_ \/ __| __/ _` | | | | |    / _ \ '__| __|______| |\/| |/ _` | '_ \ / _` |/ _` |/ _ \ '__|
#    _| |_| | | \__ \ || (_| | | | | |___|  __/ |  | |_       | |  | | (_| | | | | (_| | (_| |  __/ |   
#   |_____|_| |_|___/\__\__,_|_|_|  \_____\___|_|   \__|      |_|  |_|\__,_|_| |_|\__,_|\__, |\___|_|   
#                                                                                        __/ |          
#                                                                                       |___/                                                        

DIRECTORY="$(dirname "$0")"

bash ${DIRECTORY}/header.sh "INSTALL CERT-MANAGER..."

if [[ -z "${FOLDER}" ]]; then   
    echo "No FOLDER supplied."
    exit 666
fi
echo "FOLDER:" ${FOLDER}

export KUBECONFIG=${FOLDER}/kube_config.yaml

kubectl apply -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.12/deploy/manifests/00-crds.yaml

kubectl create namespace ${NAMESPACE}

helm repo add jetstack https://charts.jetstack.io

helm repo update

helm install cert-manager jetstack/cert-manager \
  --version v0.12.0 \
  --set ingressShim.defaultIssuerName=lets-encrypt-test \
  --set ingressShim.defaultIssuerKind=Issuer \  
  --namespace ${NAMESPACE}

bash ${DIRECTORY}/footer.sh "CERT-MANAGER INSTALLED"

exit 0