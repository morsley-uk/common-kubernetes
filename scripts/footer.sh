#!/bin/sh

FOOTER_TEXT=$1

LengthOfFooterText=${#FOOTER_TEXT}

for (( i=1; i<=78-LengthOfFooterText; i++ ))
do  
   echo -n "-"
done
echo "> ${FOOTER_TEXT}"

exit 0