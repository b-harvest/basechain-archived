#!/bin/bash

KEY="mykey"
CHAINID="basechain_9000-1"
MONIKER="mymoniker"
DATA_DIR=$(mktemp -d -t basechain-datadir.XXXXX)

echo "create and add new keys"
./basechaind keys add $KEY --home $DATA_DIR --no-backup --chain-id $CHAINID --algo "eth_secp256k1" --keyring-backend test
echo "init basechain with moniker=$MONIKER and chain-id=$CHAINID"
./basechaind init $MONIKER --chain-id $CHAINID --home $DATA_DIR
echo "prepare genesis: Allocate genesis accounts"
./basechaind add-genesis-account \
"$(./basechaind keys show $KEY -a --home $DATA_DIR --keyring-backend test)" 1000000000000000000abasecoin,1000000000000000000stake \
--home $DATA_DIR --keyring-backend test
echo "prepare genesis: Sign genesis transaction"
./basechaind gentx $KEY 1000000000000000000stake --keyring-backend test --home $DATA_DIR --keyring-backend test --chain-id $CHAINID
echo "prepare genesis: Collect genesis tx"
./basechaind collect-gentxs --home $DATA_DIR
echo "prepare genesis: Run validate-genesis to ensure everything worked and that the genesis file is setup correctly"
./basechaind validate-genesis --home $DATA_DIR

echo "starting basechain node $i in background ..."
./basechaind start --pruning=nothing --rpc.unsafe \
--keyring-backend test --home $DATA_DIR \
>$DATA_DIR/node.log 2>&1 & disown

echo "started basechain node"
tail -f /dev/null