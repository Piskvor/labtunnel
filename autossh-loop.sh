#!/bin/bash

set -euxo pipefail

HOSTNAME_TO_INT=$(sed 's/[^0-9]//g' < /etc/ssh/ssh_host_rsa_key.pub | cut -b8-)
HOSTNAME_TO_INT_3=$(echo ${HOSTNAME_TO_INT} | cut -b1-3)
HOSTNAME_TO_INT_4=$(echo ${HOSTNAME_TO_INT} | cut -b1-4)
LOCAL_LOCAL_ADDR="127.$(hostname -I | cut -f1 "-d " | sed 's/^[0-9]\+.//')"

if [[ "${1:-}" = "-p" ]]; then
    echo "$LOCAL_LOCAL_ADDR:2$HOSTNAME_TO_INT_4"
    exit 1
fi

# if we are to fail, fail quickly
SSH_REMOTE_HOST=$1
shift

INFINITE_LOOP=0
if [[ "${1:-}" = "--infinite-loop" ]]; then
    INFINITE_LOOP=1
    shift
fi


while : ; do
    for i in 2 3 4 5 ; do
        REMOTE_PORT_4="${i}${HOSTNAME_TO_INT_3}"
        REMOTE_PORT_5="${i}${HOSTNAME_TO_INT_4}"
        REMOTE_PORT_FORWARD="-R ${LOCAL_LOCAL_ADDR}:${REMOTE_PORT_4}:localhost:22"
        REMOTE_PORT_FORWARD="${REMOTE_PORT_FORWARD} -R ${LOCAL_LOCAL_ADDR}:${REMOTE_PORT_5}:localhost:222"

#    LOCAL_PORT_FORWARD="-L 13124:localhost:3128"
#    DYNAMIC_PORT_FORWARD="-D 23124"

        /usr/bin/autossh -NT \
            ${REMOTE_PORT_FORWARD} ${LOCAL_PORT_FORWARD:-} ${DYNAMIC_PORT_FORWARD:-} \
            -o ServerAliveInterval=20 \
            -o ServerAliveCountMax=3 \
            -o StrictHostKeyChecking=yes \
            -o IdentitiesOnly=yes \
            -o ExitOnForwardFailure=yes \
            -o BatchMode=yes \
            -o LogLevel=ERROR \
            ${SSH_REMOTE_HOST} "$@"
        sleep 10
    done
    [[ "${INFINITE_LOOP}" = "1" ]] || break
done
