#!/usr/bin/env bash

orderByName=false # Disabled
maxDate=$(date)   # Disabled
outputLimit=0     # Disabled
filter=".*"       # All files
reverse=false     # Disabled
minDirSize=0      # All files; in bytes

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
format="%-10s %s\n"

# Get stats for each file or directory
if [ $(uname -s) = "Darwin" ]; then
    mapfile -t fileInfo < <(find "$directory" -exec stat -f '%z %A %m %N' {} \+ | awk '{printf "%s\t%s\t%s\t%s\n", $1, $2, $3, substr($0, index($0,$4))}')
else
    mapfile -t fileInfo < <(find "$directory" -exec stat --printf '%s\t%a\t%Z\t%n\n' {} \+)
fi
declare -A output

for line in "${fileInfo[@]}"; do
    # lineArray is (re)assigned for each line.
    IFS=$'\t' read -r -a lineArray <<<"$line"

    # TODO: Start iterating from here.
    # lineArray[0]: Size
    # lineArray[1]: Permissions ("%d%d%d" format)
    # lineArray[2]: Modification date (in Unix seconds)
    # lineArray[3]: Name

    # Assign size to name in output associative array
    output["${lineArray[3]}"]="${lineArray[0]}"
done

# Order by name (-a)
# if [ $orderByName = true ]; then
#     output=$(sort -k2 <<<$output)
# fi

# Reverse the order of the output (-r)
# if [ $reverse = false ]; then
#     output=$(sort -n -r <<<$output)
# else
#     output=$(sort -n <<<$output)
# fi

# Output limit (-l)
if [ $outputLimit -ne 0 ]; then
    output=$(head -n $outputLimit <<<$output)
fi

# Minimum directory size (-s)
# if [ $minDirSize -gt 0 ]; then
#     output=$(awk -v minSize="$minDirSize" '$1 >= minSize' <<<$output)
# fi

dateTime=$(date '+%Y%m%d')

# Print
printf "${format}" "SIZE" "NAME $dateTime $var"
for name in "${!output[@]}"; do
    size="${output[$name]}"
    printf "${format}" "$size" "$name"
done
