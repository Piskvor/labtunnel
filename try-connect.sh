#!/bin/bash

set -euo pipefail

HOST=$1
shift

for i in 2 3 4 5 ; do
  if ssh "${HOST}$i" $* ; then
    exit
  fi
done
