#!/bin/sh

DIRECTORY="$(dirname "$0")"

"${DIRECTORY}/print_deployment_header.sh"

printf "    Ready |  Expected | Available |   Updated | Deployment\n"

"${DIRECTORY}/print_deployment_header.sh"
  
exit 0