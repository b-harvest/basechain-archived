# Becoming A Validator

**How to validate on the Basechain Mainnet**

*(basechain_7700-1)*

> Genesis file [Published](https://github.com/Basechain-Network/Basechain/raw/main/Mainnet/genesis.json)
> Peers list [Published](https://github.com/Basechain-Network/Basechain/blob/main/Mainnet/peers.txt)

## Hardware Requirements

### Minimum:
* 16 GB RAM
* 100 GB NVME SSD
* 3.2 GHz x4 CPU

### Recommended:
* 32 GB RAM
* 500 GB NVME SSD
* 4.2 GHz x6 CPU

### Operating System:
* Linux (x86_64) or Linux (amd64)
* Recommended Ubuntu or Arch Linux

## Install dependencies 

**If using Ubuntu:**

Install all dependencies:

`sudo snap install go --classic && sudo apt-get install git && sudo apt-get install gcc && sudo apt-get install make`

Or install individually:

* go1.18+: `sudo snap install go --classic`
* git: `sudo apt-get install git`
* gcc: `sudo apt-get install gcc`
* make: `sudo apt-get install make`

**If using Arch Linux:**

* go1.18+: `pacman -S go`
* git: `pacman -S git`
* gcc: `pacman -S gcc`
* make: `pacman -S make`

## Install `basechaind`

### Clone git repository

```bash
git clone https://github.com/Basechain-Network/Basechain.git
cd Basechain/cmd/basechaind
go install -tags ledger ./...
sudo mv $HOME/go/bin/basechaind /usr/bin/

```

### Generate and store keys

Replace `<keyname>` below with whatever you'd like to name your key.

*  `basechaind keys add <key_name>`
*  `basechaind keys add <key_name> --recover` to regenerate keys with your mnemonic
*  `basechaind keys add <key_name> --ledger` to generate keys with ledger device

Store a backup of your keys and mnemonic securely offline.

Then save the generated public key config in the main Basechain directory as `<key_name>.info`. It should look like this:

```

pubkey: {
  "@type":" ethermint.crypto.v1.ethsecp256k1.PubKey",
  "key":"############################################"
}

```

You'll use this file later when creating your validator txn.

## Set up validator

Install basechaind binary from `Basechain` directory: 

`sudo make install`

Initialize the node. Replace `<moniker>` with whatever you'd like to name your validator.

`basechaind init <moniker> --chain-id basechain_7700-1`

If this runs successfully, it should dump a blob of JSON to the terminal.

Download the Genesis file: 

`wget https://raw.githubusercontent.com/Basechain-Network/Basechain/genesis/Networks/Mainnet/genesis.json -P $HOME/.basechaind/config/` 

> _**Note:** If you later get `Error: couldn't read GenesisDoc file: open /root/.basechaind/config/genesis.json: no such file or directory` put the genesis.json file wherever it wants instead, such as:
> 
> `sudo wget https://github.com/Basechain-Network/Basechain/raw/main/Mainnet/genesis.json -P/root/.basechaind/config/`

Edit the minimum-gas-prices in `${HOME}/.basechaind/config/app.toml`:

`sed -i 's/minimum-gas-prices = "0abasecoin"/minimum-gas-prices = "0.0001abasecoin"/g' $HOME/.basechaind/config/app.toml`

Add persistent peers to `$HOME/.basechaind/config/config.toml`:
`sed -i 's/persistent_peers = ""/persistent_peers = "ec770ae4fd0fb4871b9a7c09f61764a0b010b293@164.90.134.106:26656"/g' $HOME/.basechaind/config/config.toml`

### Set `basechaind` to run automatically

* Start `basechaind` by creating a systemd service to run the node in the background: 
* Edit the file: `sudo nano /etc/systemd/system/basechaind.service`
* Then copy and paste the following text into your service file. Be sure to edit as you see fit.

```bash

[Unit]
Description=Basechain Node
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/root/
ExecStart=/root/go/bin/basechaind start --trace --log_level info --json-rpc.api eth,txpool,net,debug,web3 --api.enable
Restart=on-failure
StartLimitInterval=0
RestartSec=3
LimitNOFILE=65535
LimitMEMLOCK=209715200

[Install]
WantedBy=multi-user.target

```

## Start the node

Reload the service files: 

`sudo systemctl daemon-reload`

Create the symlinlk: 

`sudo systemctl enable basechaind.service`

Start the node: 

`sudo systemctl start basechaind && journalctl -u basechaind -f`

You should then get several lines of log files and then see: `No addresses to dial. Falling back to seeds module=pex server=node`

This is an indicator things thus far are working and now you need to create your validator txn. `^c` out and follow the next steps.

### Create Validator Transaction

Modify the following items below, removing the `<>`

- `<KEY_NAME>` should be the same as `<key_name>` when you followed the steps above in creating or restoring your key.
- `<VALIDATOR_NAME>` is whatever you'd like to name your node
- `<DESCRIPTION>` is whatever you'd like in the description field for your node
- `<SECURITY_CONTACT_EMAIL>` is the email you want to use in the event of a security incident
- `<YOUR_WEBSITE>` the website you want associated with your node
- `<TOKEN_DELEGATION>` is the amount of tokens staked by your node (`1abasecoin` should work here, but you'll also need to make sure your address contains tokens.)

```bash

basechaind tx staking create-validator \
--from <KEY_NAME> \
--chain-id basechain_7700-1 \
--moniker="<VALIDATOR_NAME>" \
--commission-max-change-rate=0.01 \
--commission-max-rate=1.0 \
--commission-rate=0.05 \
--details="<DESCRIPTION>" \
--security-contact="<SECURITY_CONTACT_EMAIL>" \
--website="<YOUR_WEBSITE>" \
--pubkey $(basechaind tendermint show-validator) \
--min-self-delegation="1" \
--amount <TOKEN_DELEGATION>abasecoin \
--fees 20abasecoin

```
