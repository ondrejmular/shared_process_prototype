#!/bin/sh

BOOTNODE_IP=$(getent hosts ${bootnode_name} | awk '{print $1;}')
CHAIN_DATA_DIR=$geth_home/chain_dir/
GETH_BIN=${geth_home}/geth/geth
CHAIN_KEYSTORE=$CHAIN_DATA_DIR/keystore/
NODE_IP=$(awk 'END{print $1}' /etc/hosts)

mkdir -p $CHAIN_KEYSTORE

case $eth_acc in
        acc1)
                ACC=92f4f00f2f5355f5ec1c55512118f1fa537b1864
                ;;
        acc2)
                ACC=f27292834a6b7129e5ad00e264062c978c48d705
                ;;
        acc3)
                ACC=830de593b42d3a007e19553c68f0f4c95e0e6e8f
                ;;
esac

if [[ ! -z $ACC ]]; then
        echo "Using account $ACC"
        cp $geth_home/keystore/$ACC $CHAIN_KEYSTORE/
        ACC_UNLOCK="--unlock 0x$ACC --password $geth_home/password"
fi

echo "running: $GETH_BIN init $geth_home/genesis.json --datadir $CHAIN_DATA_DIR"
$GETH_BIN init $geth_home/genesis.json --datadir $CHAIN_DATA_DIR

echo "$GETH_BIN
        --datadir $CHAIN_DATA_DIR
        --networkid 12345
        --bootnodes enode://$(cat $geth_home/bootnode_id)@$BOOTNODE_IP:30301
        --syncmode full
        --rpc
        --rpcaddr ${NODE_IP}
        $ACC_UNLOCK
        --mine
        --etherbase 0x$ACC
        --preload $geth_home/package_delivery_contract.js,$geth_home/package_delivery.js
        console
"
$GETH_BIN \
        --datadir $CHAIN_DATA_DIR \
        --networkid 12345 \
        --bootnodes enode://$(cat $geth_home/bootnode_id)@$BOOTNODE_IP:30301 \
        --syncmode full \
        --rpc \
        --rpcaddr ${NODE_IP} \
        $ACC_UNLOCK \
        --mine \
        --etherbase 0x$ACC \
        --preload $geth_home/package_delivery_contract.js,$geth_home/package_delivery.js \
        console

        # --ethash.dagdir $geth_home/.ethash \
