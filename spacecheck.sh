#!/usr/bin/env bash

orderByName=false   # Disabled
maxDate=$(date +%s) # Disabled
outputLimit=0       # Disabled
filter=".*"         # All files
reverse=false       # Disabled
minDirSize=0        # All files; in bytes

while getopts "ad:l:n:rs:" opt; do
    case "${opt}" in
    a)
        orderByName=true
        ;;
    d)
        if [[ $(uname -s) == "Darwin" ]]; then
            maxDate=$(gdate -d "${OPTARG}" +%s)
        else
            maxDate=$(date -d "${OPTARG}" +%s)
        fi
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

# Argument validation and directory assignment
if [ $# -lt 1 ]; then
    directory="."
else
    directory="$1"
fi

# Check if path is a directory
if [ ! -d "$directory" ]; then
    echo "'$directory' is not a Directory!"
    exit 1
fi

# Set printf format
format="%-10s %s\n"

# Print header
printf "${format}" "SIZE" "NAME $dateTime $var"

if [[ -r "$directory" && -x "$directory" ]]; then
    # Get stats for each file or directory
    if [ $(uname -s) = "Darwin" ]; then
        mapfile -t fileInfo < <(find "$directory" -exec gstat --printf '%s\t%Z\t%n\n' {} \+ 2>/dev/null)
    else
        mapfile -t fileInfo < <(find "$directory" -exec stat --printf '%s\t%Z\t%n\n' {} \+ 2>/dev/null)
    fi
    declare -A sizeNameArray

    for line in "${fileInfo[@]}"; do
        # lineArray is (re)assigned for each line.
        IFS=$'\t' read -r -a lineArray <<<"$line"

        # Array structure
        # lineArray[0]: Size
        # lineArray[1]: Modification date (in Unix seconds)
        # lineArray[2]: Name

        if ! [[ -r "${lineArray[2]}" ]]; then
            sizeNameArray["${lineArray[2]}"]="NA"
            continue
        fi

        # Ignore file if conditions are not met
        if [[ "${lineArray[0]}" -lt $minDirSize ]] || [[ "${lineArray[1]}" -gt $maxDate ]] || ! [[ "${lineArray[2]}" =~ ${filter} ]]; then
            continue
        fi

        # Get file path
        if [[ -d "${lineArray[2]}" ]]; then
            lineArray[2]="${lineArray[2]}"
        else
            lineArray[2]="${lineArray[2]%/*}"
        fi

        # Assign size to name in output associative array
        sizeNameArray["${lineArray[2]}"]=$((sizeNameArray["${lineArray[2]}"] + "${lineArray[0]}"))
    done

    # Spaghetti code to workaround sort
    declare -a keyValueArray
    for key in "${!sizeNameArray[@]}"; do
        keyValueArray+=("$(printf "${format}" "${sizeNameArray[$key]}" "$key")")
    done

    dateTime=$(date '+%Y%m%d')

    # Order by name (-a) and reverse (-r)
    if [ $orderByName = true ]; then
        if [ $reverse = true ]; then
            output=$(printf "%s\n" "${keyValueArray[@]}" | sort -t '/' -k2r)
        else
            output=$(printf "%s\n" "${keyValueArray[@]}" | sort -t '/' -k2)
        fi
    else
        if [ $reverse = true ]; then
            output=$(printf "%s\n" "${keyValueArray[@]}" | sort -r -n -k1)
        else
            output=$(printf "%s\n" "${keyValueArray[@]}" | sort -n -k1)
        fi
    fi

    # Print and set output limit
    if [ $outputLimit -gt 0 ]; then
        echo "$output" | head -n $outputLimit
    else
        echo "$output"
    fi
else
    printf "${format}" "NA" "$directory"
fi
