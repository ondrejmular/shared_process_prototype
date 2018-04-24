#!/bin/sh

BOOTNODE_IP=$(getent hosts ${bootnode_name} | awk '{print $1;}')

echo "running: ${geth_home}/geth/bootnode \
        -nodekey ${geth_home}/boot.key \
        -addr ${BOOTNODE_IP}:30301"
${geth_home}/geth/bootnode \
        -nodekey ${geth_home}/boot.key \
        -addr ${BOOTNODE_IP}:30301


