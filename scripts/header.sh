#!/bin/sh

HEADER_TEXT=$1

LengthOfHeaderText=${#HEADER_TEXT}

echo ' '
echo '################################################################################'
echo -n '#' ${HEADER_TEXT}
for (( i=1; i<=76-LengthOfHeaderText; i++ ))
do  
   echo -n " "
done
echo ' #'  
echo '# ##############################################################################'
echo '#'
echo '#'
echo '#'

exit 0