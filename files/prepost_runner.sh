#!/bin/bash

ddir=$1
#Iterate through pre.d and execute em all
if [ ! -d "${ddir}" ]; then
     echo "${ddir} does not exist" 
     exit 1
fi

for PROG in ${ddir}/*.sh; do
     echo "Doing: '${PROG}'"
     ${PROG} 
done
