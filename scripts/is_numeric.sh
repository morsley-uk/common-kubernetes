#!/bin/sh

if [ "$1" -eq "$1" ] 2>/dev/null; then
    exit 1
fi

exit 0