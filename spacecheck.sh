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

# Store arguments and shift them
var="$*"
shift $((OPTIND - 1))

# Argument validation
if [ $# -lt 1 ]; then
    echo "Have to specify a folder: $0 <folder>"
    exit 1
fi

# Check if given path is a directory
directory="$1"
if [ ! -d "$directory" ]; then
    echo "'$directory' is not a Directory!"
    exit 1
fi

# Set printf format
format="%-8s %s\n"

# Recursivelly get all directories and subdirectories, and their respective sizes
if [ $(uname -s) = "Darwin" ]; then
    du_output=$(du -A $directory)
else
    du_output=$(du -b "$directory")
fi

# Reverse option (-r)
if [ $reverse = false ]; then
    du_output=$(sort -n -r <<<$du_output)
else
    du_output=$(sort -n <<<$du_output)
fi

# Limit option (-l)
if ! [ $outputLimit = 0 ]; then
    du_output=$(head -n $outputLimit <<<$du_output)
fi

# Get current date
dateTime=$(date '+%Y%m%d')

# Print
printf "${format}" "SIZE" "NAME $dateTime $var"
printf "${format}" "$du_output"