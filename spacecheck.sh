#!/usr/bin/env bash

orderByName=false # Disabled
maxDate=$(date)   # Disabled
outputLimit=0     # Disabled
filter=".*"       # All files
reverse=false     # Disabled
minDirSize=0   # All files; in bytes

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
        minDirSize=${OPTARG}
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

# Reverse the order of the output
if [ $reverse = false ]; then
    du_output=$(sort -n -r <<<$du_output)
else
    du_output=$(sort -n <<<$du_output)
fi

# Order by Name
if [ $orderByName = true ]; then
    du_output=$(du -d 1 | sort -k2 <<<$du_output)
fi

#Output limit
if [ $outputLimit -ne 0 ]; then
    du_output=$(du -d 1 | head -n $outputLimit <<<$du_output)
fi

#Max Date of modification
#if [ $maxDate = '%m %d %H:%M' ]; then
#    du_output=$(date -d $maxDate)
#fi

#minDirSize
if [ $minDirSize -ge 0 ]; then
    du_output=$(du -d 1 | awk -v minSize="$minDirSize" '$1 >= minSize' <<<$du_output)
fi

dateTime=$(date '+%Y%m%d')

# Print
printf "${format}" "SIZE" "NAME $dateTime $var"
printf "${format}" "$du_output"