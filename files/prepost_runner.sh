#!/bin/bash

ddir=$(basename $@).d
if [ "${ddir}" != "pre.d" ] || [ "${ddir}" != "post.d" ]; then
    #Iterate through pre.d and execute em all
    if [ ! -d "${ddir}" ]; then
        echo "${ddir} does not exist" 
        exit 1
    fi

    for PROG in ${ddir}/*.sh; do
        echo "Doing: '${PROG}'"
        ${PROG} 
    done
else
    echo "Must be either 'pre' or 'post'! Error in prepost_runner.sh"
    exit 1
fi
