#!/bin/bash

ddir=$(basename $0).d
#Iterate through pre.d and execute em all
if [ ! -d "${ddir}" ]; then
  echo "${ddir} does not exist" 
  exit 1
fi

for PROG in ${ddir}/*.sh; do
  echo "Doing: '${PROG}'"
  ${PROG} 
done

