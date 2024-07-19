FROM ubuntu:latest 

# add your keyname
ARG KEY_NAME <add your keyname>

# add the nickname for your validator on the network
ARG MONIKER <add your moniker>

# add the network id
ARG NETWORK_ID basechain_9624-1

# arbitrary validator metadata
ARG DETAILS <details as string>

# add amount you're delegating
ARG TOKEN_DELEGATION <amount>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update &&\ 
	apt-get install -y apt-utils git git-extras software-properties-common vim \
	wget ca-certificates curl build-essential libssl-dev make openssh-server snap

RUN snap install go --classic

# builds out basechaind
RUN git clone https://github.com/Canto-Network/Canto-Testnet
WORKDIR /Canto-Testnet/cmd/basechaind
RUN go install -tags ledger ./... &&\
    mv $HOME/go/bin/basechaind /usr/bin/

# generate keys
RUN basechaind keys add $KEY_NAME
    # basechaind keys add $KEY_NAME --recover &&\
    # basechaind keys add $KEY_NAME --ledger

# initialize node
RUN basechaind init $MONIKER --chain-id basechain_9624-1

# get genesis file
RUN wget https://github.com/Canto-Network/Canto-Testnet-v2/raw/main/genesis.json -P $HOME/.basechaind/config/
RUN sed -i 's/minimum-gas-prices = ""/minimum-gas-prices = "0.0001abasechain"/g' $HOME/.basechaind/config/app.toml
RUN wget https://github.com/Canto-Network/Canto-Testnet-v2/raw/main/Docker/basechaind.service -P $HOME/systemd/system/

# run basechaind
WORKDIR /Canto-Testnet/cmd/basechaind
RUN sudo systemctl daemon-reload &&\
    sudo systemctl enable basechaind.service &&\
    systemctl start basechaind && journalctl -u basechaind -f

ENTRYPOINT ["/bin/bash"]
