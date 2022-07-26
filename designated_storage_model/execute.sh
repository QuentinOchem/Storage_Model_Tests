#!/bin/bash

set -eu
line='----------------------------------------'

BACKEND=${BACKEND:="llvm-gcc"}

result=$(realpath result.txt)
rm -f "$result"

for NAME in *; do
    if [ ! -d "$NAME" ]; then
        continue
    fi
    pushd "$NAME"
    if gprbuild -v -P test -f -Xbackend="$BACKEND"; then
        if ./obj/main; then
            printf "$NAME %s [OK]\n" "${line:${#NAME}}" >> "$result"
        else
            printf "$NAME %s [EXEC FAIL]\n" "${line:${#NAME}}" >> "$result"
        fi
    else
        printf "$NAME %s [BUILD FAIL]\n" "${line:${#NAME}}" >> "$result"
    fi
    popd
done
