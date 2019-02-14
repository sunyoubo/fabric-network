#!/usr/bin/env bash

if [[ ! -d blockchain-explorer ]]; then

    git clone https://github.com/hyperledger/blockchain-explorer.git
    if [[ "$?" -ne 0 ]]; then
        echo "Failed to clone https://github.com/hyperledger/blockchain-explorer.git"
        exit 1
    fi

    cd blockchain-explorer
    git checkout -b release-3.8 origin/release-3.8
    cd ..

    mkdir -p blockchain-explorer/examples/sbc_net/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/keystore
    mkdir -p blockchain-explorer/examples/sbc_net/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/signcerts

    mkdir -p blockchain-explorer/examples/sbc_net/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/
    mkdir -p blockchain-explorer/examples/sbc_net/crypto/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/tls/

    mkdir -p blockchain-explorer/examples/sbc_net/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/
    mkdir -p blockchain-explorer/examples/sbc_net/crypto/peerOrganizations/org2.example.com/peers/peer1.org2.example.com/tls/

    mkdir -p blockchain-explorer/examples/sbc_net/crypto/ordererOrganizations/example.com/users/Admin@example.com/msp/keystore

    mkdir -p blockchain-explorer/examples/sbc_net/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp/keystore
fi

cp -r ./data/orgs/org1/admin/msp/keystore/* ./blockchain-explorer/examples/sbc_net/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/keystore/
cp -r ./data/orgs/org1/admin/msp/signcerts/* ./blockchain-explorer/examples/sbc_net/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/signcerts/

cp -r ./data/org1-ca-chain.pem ./blockchain-explorer/examples/sbc_net/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
cp -r ./data/org1-ca-chain.pem ./blockchain-explorer/examples/sbc_net/crypto/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/tls/ca.crt

cp -r ./data/org2-ca-chain.pem ./blockchain-explorer/examples/sbc_net/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
cp -r ./data/org2-ca-chain.pem ./blockchain-explorer/examples/sbc_net/crypto/peerOrganizations/org2.example.com/peers/peer1.org2.example.com/tls/ca.crt

cp -r ./data/orgs/ordererorg/admin/msp/keystore/* ./blockchain-explorer/examples/sbc_net/crypto/ordererOrganizations/example.com/users/Admin@example.com/msp/keystore/
cp -r ./data/orgs/org2/admin/msp/keystore/* ./blockchain-explorer/examples/sbc_net/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp/keystore

cp explorer_config.json ./blockchain-explorer/examples/sbc_net/config.json

cd blockchain-explorer
bash ./deploy_explorer.sh sbc_net fabricmainnet_test_net

