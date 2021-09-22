#!/bin/bash

if [ $# -lt 1 ]; then
    echo -e "\e[31mUsage: $0 [cmd]\e[m"
    exit 1
fi

show-versions

if [[ "${INPUT_DANGERFILE}" == '' ]]; then
    DANGERFILE_ARGS=''
else
    DANGERFILE_ARGS="--dangerfile ${INPUT_DANGERFILE}"
fi

danger-swift $@ $DANGERFILE_ARGS
