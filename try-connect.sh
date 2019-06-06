#!/bin/bash

set -euo pipefail

for i in 2 3 4 5 ; do
  if ssh "${1}$i" $* ; then
    exit
  fi
done
