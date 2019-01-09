#!/usr/bin/env bash

git clone https://github.com/hyperledger/blockchain-explorer.git
if [[ "$?" -ne 0 ]]; then
    echo "Failed to clone https://github.com/hyperledger/blockchain-explorer.git"
    exit 1
fi

cd blockchain-explorer
git checkout -b release-3.8 origin/release-3.8
cd ..

mkdir -p blockchain-explorer/examples/sbc_net/crypto
cp -r ./artifacts/channel/crypto-config/* ./blockchain-explorer/examples/sbc_net/crypto/

cp explorer_config.json ./blockchain-explorer/examples/sbc_net/config.json

cd blockchain-explorer
bash ./deploy_explorer.sh sbc_net artifacts_default