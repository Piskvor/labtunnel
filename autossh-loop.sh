#!/bin/bash

set -euxo pipefail

# if we are to fail, fail quickly
SSH_REMOTE_HOST=$1
shift

HOSTNAME_TO_INT=$(sed 's/[^0-9]//g' < /etc/ssh/ssh_host_rsa_key.pub | cut -b1-4)
LOCAL_LOCAL_ADDR="127.$(hostname -I | cut -f1 "-d " | sed 's/^[0-9]\+.//')"

for i in 1 2 3 4 5 ; do
    REMOTE_PORT="${i}${HOSTNAME_TO_INT}"
    REMOTE_PORT_FORWARD="-R ${LOCAL_LOCAL_ADDR}:${REMOTE_PORT}:localhost:22"

    /usr/bin/autossh -NT \
        -o ServerAliveInterval=30 \
        -o ServerAliveCountMax=2 \
        -o StrictHostKeyChecking=yes \
        -o IdentitiesOnly=yes \
        -o ExitOnForwardFailure=yes \
        -o BatchMode=yes \
        -o LogLevel=ERROR \
        ${REMOTE_PORT_FORWARD} ${SSH_REMOTE_HOST}
    sleep 10
done
