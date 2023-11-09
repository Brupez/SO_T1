#!/usr/bin/env bash

# Disclaimer: there are some ifs that test whether the OS is macOS or Linux.
# macOS users should install the coreutils Homebrew package, in order to use
# GNU tools instead of the BSD ones (and thus get the same output as in Linux).

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

# Get current date
dateTime=$(date '+%Y%m%d')

# Print header
printf "${format}" "SIZE" "NAME $dateTime $var"

# Check if directory is readable
if [[ -r "$directory" && -x "$directory" ]]; then

    # Get stats for each file or directory
    if [ $(uname -s) = "Darwin" ]; then
        mapfile -t fileInfo < <(find "$directory" -exec gstat --printf '%s\t%Y\t%n\n' {} \+ 2>/dev/null)
    else
        mapfile -t fileInfo < <(find "$directory" -exec stat --printf '%s\t%Y\t%n\n' {} \+ 2>/dev/null)
    fi
    declare -A sizeNameArray

    for line in "${fileInfo[@]}"; do
        # lineArray is (re)assigned for each line.
        IFS=$'\t' read -r -a lineArray <<<"$line"

        # Array structure
        # lineArray[0]: Size
        # lineArray[1]: Modification date (in Unix seconds)
        # lineArray[2]: Name

        # Get file path (i.e., the parent directory)
        if [[ -d "${lineArray[2]}" ]]; then
            continue
        else
            lineArray[2]="${lineArray[2]%/*}"
        fi

        # Set NA if there are no read permissions
        if ! [[ -r "${lineArray[2]}" ]]; then
            sizeNameArray["${lineArray[2]}"]="NA"
            continue
        fi

        # Ignore file if conditions are not met (minimum dir size, maximum date and regex)
        # Ignore file if conditions are not met

        if [[ "${lineArray[0]}" -lt $minDirSize ]] || [[ "${lineArray[1]}" -gt $maxDate ]] || ! [[ "${lineArray[2]}" =~ ${filter} ]]; then
            continue
        fi

        # Get file path (-d is a directory?)
        if [[ -d "${lineArray[2]}" ]]; then
            lineArray[2]="${lineArray[2]}"
        else
            # if not diretory remove the last element in name (file)
            lineArray[2]="${lineArray[2]%/*}"
        fi

        # Assign size to name in output associative array
        sizeNameArray["${lineArray[2]}"]=$((sizeNameArray["${lineArray[2]}"] + "${lineArray[0]}"))

        # Add size to all parent directories (e.g. size in sop/main/ should also count to sop/)
        parentDir="${lineArray[2]}"
        while [[ "$parentDir" != "$directory" ]]; do
            parentDir="${parentDir%/*}"
            sizeNameArray["$parentDir"]=$((sizeNameArray["$parentDir"] + "${lineArray[0]}"))
        done
    done

    # Spaghetti code to workaround sort
    # Output the print string to an array, so that sort works with real output
    declare -a keyValueArray
    for key in "${!sizeNameArray[@]}"; do
        # Ignore file if conditions are not met
        if [[ "${sizeNameArray[$key]}" -gt $minDirSize ]]; then
            keyValueArray+=("$(printf "${format}" "${sizeNameArray[$key]}" "$key")")
        else
            keyValueArray+=("$(printf "${format}" "0" "$key")")

        fi
    done

    # Order by name (-a) and reverse (-r)
    if [ $orderByName = true ]; then
        if [ $reverse = true ]; then
            output=$(printf "%s\n" "${keyValueArray[@]}" | sort -k2 -t '/' -r)
        else
            output=$(printf "%s\n" "${keyValueArray[@]}" | sort -k2 -t '/')
        fi
    else
        if [ $reverse = true ]; then
            output=$(printf "%s\n" "${keyValueArray[@]}" | sort -k1 -n)
        else
            output=$(printf "%s\n" "${keyValueArray[@]}" | sort -k1 -n -r)
        fi
    fi

    # Print output with a limit (if any)
    if [ $outputLimit -gt 0 ]; then
        echo "$output" | head -n $outputLimit
    else
        echo "$output"
    fi
else
    printf "${format}" "NA" "$directory"
fi
