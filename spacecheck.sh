#!/usr/bin/env bash

orderByName=false # Disabled
maxDate=$(date)   # Disabled
outputLimit=0     # Disabled
filter=".*"       # All files
reverse=false     # Disabled
minFileSize=0     # All files; in bytes

while getopts "ad:l:n:rs:" opt; do
    case "${opt}" in
    a)
        orderByName=true
        ;;
    d)
        maxDate=${OPTARG}
        ;;
    l)
        outputLimit=${OPTARG}
        ;;
    n)
        filter=${OPTARG}
        ;;
    r)
        reverse=true
        ;;
    s)
        minFileSize=${OPTARG}
        ;;
    *) ;;
    esac
done

# Set printf format
format="%-8s %s\n"

# Print header and shift arguments so that $1 is the path to look for
printf "${format}" "SIZE" "NAME $*"
shift $((OPTIND - 1))

for path in *; do
    # Check if path is a file
    if [ -f ${path} ]; then
        echo ${path}
    # Directory
    else
        echo ${path}/
    fi
done
