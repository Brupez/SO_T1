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

if ! [ -r "$file1" ]; then
    echo "$file1 doesn't have read permissions."
    exit 1
fi

if ! [ -f "$file2" ]; then
    echo "$file2 is not a file."
    exit 1
fi

if ! [ -r "$file2" ]; then
    echo "$file2 doesn't have read permissions."
    exit 1
fi

# Set printf format
format="%-10s %s\n"

# Print header
printf "${format}" "SIZE" "NAME"

# Read file1
exec 3<"$file1"     # "Open" the file
read -r header1 <&3 # Get the header

declare -A file1Array
while read -r size path; do
    file1Array["$path"]=$size
done <&3

# Read file2
exec 4<"$file2"
read -r header2 <&4

declare -A file2Array
while read -r size path; do
    file2Array["$path"]=$size
done <&4

# Check file1 array against file2 one
# For now, file1 will be considered as "old" and file2 as "new"
for i in "${!file1Array[@]}"; do
    if [[ -n "${file2Array[$i]}" ]]; then
        printf "${format}" "$((${file2Array[$i]} - ${file1Array[$i]}))" "$i"
    else
        printf "${format}" "-${file1Array[$i]}" "$i REMOVED"
    fi
done

# Check file2 array against file1 one
for i in "${!file2Array[@]}"; do
    if ! [[ -n "${file1Array[$i]}" ]]; then
        printf "${format}" "${file2Array[$i]}" "$i NEW"
    fi
done