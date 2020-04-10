#!/bin/sh

FOOTER_TEXT=$1

LengthOfFooterText=${#FOOTER_TEXT}

echo '#'
echo '#'
echo '#'
echo '# ##############################################################################'
echo -n '#' ${FOOTER_TEXT}
for (( i=1; i<=76-LengthOfFooterText; i++ ))
do  
   echo -n " "
done
echo ' #'  
echo '################################################################################'
echo ' '

exit 0