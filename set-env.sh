#!/bin/bash
if [[ "$0" = "$BASH_SOURCE" ]]; then
    echo "Please source this script. Do not execute."
    exit -1
fi

GOPASS_PATH=$1

REGEX="([^ ]+): *(.+)"
while read -r line
do
    if [[ $line =~ $REGEX ]]; then
        echo "Setting ${BASH_REMATCH[1]}"
        export ${BASH_REMATCH[1]}=${BASH_REMATCH[2]}
    fi
done < <(cd && gopass show $GOPASS_PATH && echo)
