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

if [[ -r "$directory" && -x "$directory" ]]; then

    # Get stats for each file or directory
    if [ $(uname -s) = "Darwin" ]; then
        mapfile -t fileInfo < <(find "$directory" -exec gstat --printf '%s\t%a\t%Z\t%n\n' {} \+)
    else
        mapfile -t fileInfo < <(find "$directory" -exec stat --printf '%s\t%a\t%Z\t%n\n' {} \+)
    fi
    declare -A output

    for line in "${fileInfo[@]}"; do
        # lineArray is (re)assigned for each line.
        IFS=$'\t' read -r -a lineArray <<<"$line"

        # Array structure
        # lineArray[0]: Size
        # lineArray[1]: Permissions ("%d%d%d" format)
        # lineArray[2]: Modification date (in Unix seconds)
        # lineArray[3]: Name

        # Ignore file if conditions are not met
        if [[ "${lineArray[0]}" -lt $minDirSize ]] || [[ "${lineArray[2]}" -gt $maxDate ]] || ! [[ "${lineArray[3]}" =~ ${filter} ]]; then
            continue
        fi

        # Get file path
        if [[ -d "${lineArray[3]}" ]]; then
            lineArray[3]="${lineArray[3]}"
        else
            lineArray[3]="${lineArray[3]%/*}"
        fi

        # printf "%s\t%s\t%s\t%s\n" "${lineArray[0]}" "${lineArray[1]}" "${lineArray[2]}" "${lineArray[3]}"

        # Assign size to name in output associative array
        output["${lineArray[3]}"]=$((output["${lineArray[3]}"] + "${lineArray[0]}"))
    done

    # Spaghetti code to workaround sort
    declare -a keyValueArray
    for key in "${!output[@]}"; do
        keyValueArray+=("$(printf "${format}" "${output[$key]}" "$key")")
    done

    dateTime=$(date '+%Y%m%d')

    # Print header
    printf "${format}" "SIZE" "NAME $dateTime $var"

    # Order by name (-a) and reverse (-r)
    if [ $orderByName = true ]; then
        if [ $reverse = true ]; then
            printf "%s\n" "${keyValueArray[@]}" | sort -t '/' -k2r
        else
            printf "%s\n" "${keyValueArray[@]}" | sort -t '/' -k2
        fi
    else
        if [ $reverse = true ]; then
            printf "%s\n" "${keyValueArray[@]}" | sort -r -n -k1
        else
            printf "%s\n" "${keyValueArray[@]}" | sort -n -k1
        fi
    fi

    # Output limit (-l)
    if [ $outputLimit -ne 0 ]; then
        output=$(head -n $outputLimit <<<$output)
    fi
else
    echo "Permission denied: cannot read or execute $diretory"
fi
