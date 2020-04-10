#!/bin/sh

DIRECTORY="$(dirname "$0")"

bash ${DIRECTORY}/print_deployment_header.sh

echo "    Ready |  Expected | Available |   Updated | Deployment"

bash ${DIRECTORY}/print_deployment_header.sh
  
exit 0