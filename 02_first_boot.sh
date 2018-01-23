#!/bin/bash -e

if [ -z "$1" ]; then
    exit 1
fi

SSH_OPTS="-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
ssh-copy-id ${SSH_OPTS} pi@raspberrypi.local
ssh ${SSH_OPTS} pi@raspberrypi.local sudo sed -i "s/raspberrypi/$1/" /etc/hostname
ssh ${SSH_OPTS} pi@raspberrypi.local sudo sed -i "s/raspberrypi/$1/" /etc/hosts
ssh ${SSH_OPTS} pi@raspberrypi.local sudo shutdown -r now
