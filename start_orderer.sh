#!/usr/bin/env bash

# import utils.sh
source ./scripts/utils.sh

function generateGenesisBlock() {

    docker exec fabric-cli configtxgen -configPath /data/ -profile OrgsOrdererGenesis -outputBlock /data/orderer.genesis.block
    verifyExecuteResult $? "Failed to generate orderer genesis block..."
}

# check cli container
checkCliContainer docker-compose-ca.yml

# generate genesis.block for orderer
generateGenesisBlock

docker-compose -f docker-compose-order.yml up -d