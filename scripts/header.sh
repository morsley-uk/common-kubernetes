#!/bin/sh

HEADER_TEXT=$1

LengthOfHeaderText=${#HEADER_TEXT}

for (( i=1; i<=78-LengthOfHeaderText; i++ ))
do  
   echo -n "-"
done
echo "> ${HEADER_TEXT}"

exit 0