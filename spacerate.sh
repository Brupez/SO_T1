#!/usr/bin/env bash

orderByName=false # Disabled
reverse=false     # Disabled

while getopts "ad:l:n:rs:" opt; do
    case "${opt}" in
    a)
        orderByName=true
        ;;
    r)
        reverse=true
        ;;
    *) ;;
    esac
done

# Store arguments and shift them
var="$*"
shift $((OPTIND - 1))

# Argument validation
if [ $# -lt 2 ]; then
    echo "USAGE: $0 <file1> <file2>"
    exit 1
fi

# File validation
file1="$1"
file2="$2"

if ! [ -f "$file1" ]; then
    echo "$file1 is not a file."
    exit 1
fi

if ! [ -f "$file2" ]; then
    echo "$file2 is not a file."
    exit 1
fi

# Set printf format
format="%-10s %s\n"

# Print header
printf "${format}" "SIZE" "NAME"
