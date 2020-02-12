#!/bin/sh

if [ $# -lt 1 ]; then
    echo -e "\e[31mUsage: $0 [cmd]\e[m"
    exit 1
fi

show-versions

danger-swift $@
