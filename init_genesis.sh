KEY="validator"
KEY2="user1"
CHAINID="canto_7700-1"
MONIKER="validator"
KEYRING="os"
KEYALGO="eth_secp256k1"
LOGLEVEL="info"
# to trace evm
#TRACE="--trace"
TRACE=""

# validate dependencies are installed
command -v jq > /dev/null 2>&1 || { echo >&2 "jq not installed. More info: https://stedolan.github.io/jq/download/"; exit 1; }

# Reinstall daemon
rm -rf ~/.cantod*
make install

# Set client config
cantod config keyring-backend $KEYRING
cantod config chain-id $CHAINID

# if $KEY exists it should be deleted
cantod keys add $KEY --keyring-backend $KEYRING --algo $KEYALGO
cantod keys add $KEY2 --keyring-backend $KEYRING --algo $KEYALGO

# Set moniker and chain-id for Canto (Moniker can be anything, chain-id must be an integer)
cantod init $MONIKER --chain-id $CHAINID

# Change parameter token denominations to abasecoin
cat $HOME/.cantod/config/genesis.json | jq '.app_state["staking"]["params"]["bond_denom"]="abasecoin"' > $HOME/.cantod/config/tmp_genesis.json && mv $HOME/.cantod/config/tmp_genesis.json $HOME/.cantod/config/genesis.json
cat $HOME/.cantod/config/genesis.json | jq '.app_state["crisis"]["constant_fee"]["denom"]="abasecoin"' > $HOME/.cantod/config/tmp_genesis.json && mv $HOME/.cantod/config/tmp_genesis.json $HOME/.cantod/config/genesis.json
cat $HOME/.cantod/config/genesis.json | jq '.app_state["gov"]["deposit_params"]["min_deposit"][0]["denom"]="abasecoin"' > $HOME/.cantod/config/tmp_genesis.json && mv $HOME/.cantod/config/tmp_genesis.json $HOME/.cantod/config/genesis.json
cat $HOME/.cantod/config/genesis.json | jq '.app_state["evm"]["params"]["evm_denom"]="ausd"' > $HOME/.cantod/config/tmp_genesis.json && mv $HOME/.cantod/config/tmp_genesis.json $HOME/.cantod/config/genesis.json
cat $HOME/.cantod/config/genesis.json | jq '.app_state["inflation"]["params"]["mint_denom"]="abasecoin"' > $HOME/.cantod/config/tmp_genesis.json && mv $HOME/.cantod/config/tmp_genesis.json $HOME/.cantod/config/genesis.json

# Change voting params so that submitted proposals pass immediately for testing
cat $HOME/.cantod/config/genesis.json| jq '.app_state.gov.voting_params.voting_period="720s"' > $HOME/.cantod/config/tmp_genesis.json && mv $HOME/.cantod/config/tmp_genesis.json $HOME/.cantod/config/genesis.json


# TODO: add staking denom, etc 



# disable produce empty block
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' 's/create_empty_blocks = true/create_empty_blocks = false/g' $HOME/.cantod/config/config.toml
  else
    sed -i 's/create_empty_blocks = true/create_empty_blocks = false/g' $HOME/.cantod/config/config.toml
fi

if [[ $1 == "pending" ]]; then
  if [[ "$OSTYPE" == "darwin"* ]]; then
      sed -i '' 's/create_empty_blocks_interval = "0s"/create_empty_blocks_interval = "30s"/g' $HOME/.cantod/config/config.toml
      sed -i '' 's/timeout_propose = "3s"/timeout_propose = "30s"/g' $HOME/.cantod/config/config.toml
      sed -i '' 's/timeout_propose_delta = "500ms"/timeout_propose_delta = "5s"/g' $HOME/.cantod/config/config.toml
      sed -i '' 's/timeout_prevote = "1s"/timeout_prevote = "10s"/g' $HOME/.cantod/config/config.toml
      sed -i '' 's/timeout_prevote_delta = "500ms"/timeout_prevote_delta = "5s"/g' $HOME/.cantod/config/config.toml
      sed -i '' 's/timeout_precommit = "1s"/timeout_precommit = "10s"/g' $HOME/.cantod/config/config.toml
      sed -i '' 's/timeout_precommit_delta = "500ms"/timeout_precommit_delta = "5s"/g' $HOME/.cantod/config/config.toml
      sed -i '' 's/timeout_commit = "5s"/timeout_commit = "150s"/g' $HOME/.cantod/config/config.toml
      sed -i '' 's/timeout_broadcast_tx_commit = "10s"/timeout_broadcast_tx_commit = "150s"/g' $HOME/.cantod/config/config.toml
  else
      sed -i 's/create_empty_blocks_interval = "0s"/create_empty_blocks_interval = "30s"/g' $HOME/.cantod/config/config.toml
      sed -i 's/timeout_propose = "3s"/timeout_propose = "30s"/g' $HOME/.cantod/config/config.toml
      sed -i 's/timeout_propose_delta = "500ms"/timeout_propose_delta = "5s"/g' $HOME/.cantod/config/config.toml
      sed -i 's/timeout_prevote = "1s"/timeout_prevote = "10s"/g' $HOME/.cantod/config/config.toml
      sed -i 's/timeout_prevote_delta = "500ms"/timeout_prevote_delta = "5s"/g' $HOME/.cantod/config/config.toml
      sed -i 's/timeout_precommit = "1s"/timeout_precommit = "10s"/g' $HOME/.cantod/config/config.toml
      sed -i 's/timeout_precommit_delta = "500ms"/timeout_precommit_delta = "5s"/g' $HOME/.cantod/config/config.toml
      sed -i 's/timeout_commit = "5s"/timeout_commit = "150s"/g' $HOME/.cantod/config/config.toml
      sed -i 's/timeout_broadcast_tx_commit = "10s"/timeout_broadcast_tx_commit = "150s"/g' $HOME/.cantod/config/config.toml
  fi
fi

# Allocate genesis accounts (cosmos formatted addresses)
cantod add-genesis-account $KEY 10000000000000000000000000abasecoin,10000000000000000000000000ausd --keyring-backend $KEYRING
cantod add-genesis-account $KEY2 10000000000000000000000000abasecoin,10000000000000000000000000ausd --keyring-backend $KEYRING

# TODO: fix account, bech32 
# add Genesis Account
cantod add-genesis-account canto1j6yqpu87lfulcvz7eda623v4q9wrkt24w6tcsj 10000000000000000000000000abasecoin,10000000000000000000000000ausd
# cantod add-genesis-account canto1zkmj7pzaaytpr3y8ejdvugvl8fnuzn4xd6lkg9 10000000000000000000000000abasecoin10000000000000000000000000ausd


# Update total supply with claim values
#validators_supply=$(cat $HOME/.cantod/config/genesis.json | jq -r '.app_state["bank"]["supply"][0]["amount"]')
# Bc is required to add this big numbers
# total_supply=$(bc <<< "$amount_to_claim+$validators_supply")
# total_supply=1000000000000000000000000000
# cat $HOME/.cantod/config/genesis.json | jq -r --arg total_supply "$total_supply" '.app_state["bank"]["supply"][0]["amount"]=$total_supply' > $HOME/.cantod/config/tmp_genesis.json && mv $HOME/.cantod/config/tmp_genesis.json $HOME/.cantod/config/genesis.json

echo $KEYRING
echo $KEY
# Sign genesis transaction
cantod gentx $KEY 10000000000000000000000abasecoin --keyring-backend $KEYRING --chain-id $CHAINID
#cantod gentx $KEY2 10000000000000000000000abasecoin --keyring-backend $KEYRING --chain-id $CHAINID

# Collect genesis tx
cantod collect-gentxs

# Run this to ensure everything worked and that the genesis file is setup correctly
cantod validate-genesis

if [[ $1 == "pending" ]]; then
  echo "pending mode is on, please wait for the first block committed."
fi

# Start the node (remove the --pruning=nothing flag if historical queries are not needed)
cantod start --pruning=nothing --trace --log_level info --minimum-gas-prices=0.0001ausd --json-rpc.api eth,txpool,personal,net,debug,web3 --rpc.laddr "tcp://0.0.0.0:26657" --api.enable true
cantod start --pruning=nothing --trace --log_level info --minimum-gas-prices=0.0001ausd --rpc.laddr "tcp://0.0.0.0:26657" --api.enable true


if [[ $1 == "pending" ]]; then
  echo "pending mode is on, please wait for the first block committed."
fi


# test send
BECH32KEY2="canto1zkmj7pzaaytpr3y8ejdvugvl8fnuzn4xd6lkg9"
EIP55KEY2="0x15B72f045dE91611c487cc9AcE219F3A67c14Ea6"
BECH32METAMASK1="canto1t33azrlyyznr586y39jsh03z3vd9w9ph5z8vf3"
# m/44'/60'/0'/0/0
# mnemonic 
# correct finger pet aisle radio lazy excite nation salt quiz breeze velvet surface tray claim force play various side salute envelope absorb opinion march
# privte key
# 0xe97242b90889a0dea849239052f9fcd2da7953b51046754939ec19ec89549863

cantod q auth account $BECH32KEY2 --keyring-backend $KEYRING 
cantod q bank balances $BECH32KEY2 --keyring-backend $KEYRING 
cantod q bank balances $BECH32METAMASK1 --keyring-backend $KEYRING 
cantod tx bank send $KEY2 $BECH32METAMASK1 1000000000000000000000abasecoin,1000000000000000000000ausd --from $KEY2 --keyring-backend $KEYRING  --chain-id $CHAINID --gas-prices 10000000000000000ausd --gas 2000000 -y


cantod q auth account $BECH32METAMASK1 --keyring-backend $KEYRING 
cantod debug addr $BECH32KEY2


