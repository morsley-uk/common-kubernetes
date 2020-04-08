#!/bin/sh

ready=$1
expected=$2
available=$3
updated=$4
deployment_name=$5
              
printf "%9d | %9d | %9d | %9d | %s\n" ${ready} ${expected} ${available} ${updated} ${deployment_name}
  
exit 0