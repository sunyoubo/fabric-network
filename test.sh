#!/usr/bin/env bash

source ./scripts/utils.sh

# Test gen_channel_tx.sh
# configtxgen -profile OrgsChannel -outputCreateChannelTx /data/${ENV_CHANNEL_TX_FILE} -channelID ${ENV_CHANNEL_NAME}
# configtxgen -profile OrgsChannel -outputAnchorPeersUpdate /data/org1-mychannel-anchors.tx -channelID mychannel -asOrg org1
# configtxgen -profile OrgsChannel -outputAnchorPeersUpdate /data/org2-mychannel-anchors.tx -channelID mychannel -asOrg org2


# Test create_update_channel.sh
#export CORE_PEER_MSPCONFIGPATH=/data/orgs/org1/admin/msp
#export CORE_PEER_LOCALMSPID=org1MSP
#export FABRIC_CFG_PATH=/etc/hyperledger/fabric/
#peer channel create -c ${ENV_CHANNEL_NAME} -f ${ENV_CHANNEL_TX_FILE} -o ${ENV_ORDERER_ADDRESS} \
#    --tls --cafile ${ENV_ORDER_CA_CHAINFILE} --clientauth --keyfile ${ENV_CORE_PEER_TLS_CLIENTKEY_FILE} --certfile ${ENV_CORE_PEER_TLS_CLIENTCERT_FILE}
#
#
#export FABRIC_CA_CLIENT_HOME=/data/orgs/org1/admin
#export CORE_PEER_TLS_ENABLED=true
#export CORE_PEER_TLS_CLIENTAUTHREQUIRED=true
#export CORE_PEER_TLS_ROOTCERT_FILE=/data/org1-ca-chain.pem
#export CORE_PEER_TLS_CLIENTCERT_FILE=${ENV_CORE_PEER_TLS_CLIENTCERT_FILE}
#export CORE_PEER_TLS_CLIENTKEY_FILE=${ENV_CORE_PEER_TLS_CLIENTKEY_FILE}
#export CORE_PEER_PROFILE_ENABLED=true
#export CORE_PEER_ADDRESS=peer0.org1.example.com:7051
#peer channel join -b ${ENV_CHANNEL_NAME}.block --tls --cafile ${ENV_ORDER_CA_CHAINFILE} --clientauth \
#    --keyfile ${ENV_CORE_PEER_TLS_CLIENTKEY_FILE} --certfile ${ENV_CORE_PEER_TLS_CLIENTCERT_FILE}
#
#export CORE_PEER_ADDRESS=peer1.org1.example.com:7051
#peer channel join -b ${ENV_CHANNEL_NAME}.block --tls --cafile ${ENV_ORDER_CA_CHAINFILE} --clientauth \
#    --keyfile ${ENV_CORE_PEER_TLS_CLIENTKEY_FILE} --certfile ${ENV_CORE_PEER_TLS_CLIENTCERT_FILE}
#
#peer channel update -c ${ENV_CHANNEL_NAME} -f ${ENV_ANCHOR_TX_FILE} -o ${ENV_ORDERER_ADDRESS} \
#    --tls --cafile ${ENV_ORDER_CA_CHAINFILE} --clientauth --keyfile ${ENV_CORE_PEER_TLS_CLIENTKEY_FILE} --certfile ${ENV_CORE_PEER_TLS_CLIENTCERT_FILE}


# Test org_deploy_cc.sh
#ENV_PEER_CA_CHAINFILE=/data/org1-ca-chain.pem
#    export CORE_PEER_TLS_ENABLED=true
#    export CORE_PEER_TLS_CLIENTAUTHREQUIRED=true
#    export CORE_PEER_TLS_CLIENTCERT_FILE=${ENV_CORE_PEER_TLS_CLIENTCERT_FILE}
#    export CORE_PEER_TLS_CLIENTKEY_FILE=${ENV_CORE_PEER_TLS_CLIENTKEY_FILE}
#    export CORE_PEER_PROFILE_ENABLED=true
#
#    export CORE_PEER_LOCALMSPID=org1MSP
#    export CORE_PEER_ADDRESS=peer0.org1.example.com:7051
#    export CORE_PEER_TLS_ROOTCERT_FILE=/data/org1-ca-chain.pem
#
#peer chaincode install -n ${ENV_CHAIN_CODE_NAME} -v ${ENV_CHAIN_CODE_VERSION} -p ${ENV_CHAIN_CODE_PATH} --tls --cafile ${ENV_ORDER_CA_CHAINFILE} --clientauth \
#    --keyfile ${ENV_CORE_PEER_TLS_CLIENTKEY_FILE} --certfile ${ENV_CORE_PEER_TLS_CLIENTCERT_FILE}
#
#peer chaincode instantiate -C ${ENV_CHANNEL_NAME} -n ${ENV_CHAIN_CODE_NAME} -v ${ENV_CHAIN_CODE_VERSION} -c "${ENV_INIT_ARGS}" \
#    -P "${ENV_CHAIN_CODE_POLICY}" -o ${ENV_ORDERER_ADDRESS}  --tls --cafile ${ENV_ORDER_CA_CHAINFILE} --clientauth \
#    --keyfile ${ENV_CORE_PEER_TLS_CLIENTKEY_FILE} --certfile ${ENV_CORE_PEER_TLS_CLIENTCERT_FILE}
#
#peer chaincode list --installed -C ${ENV_CHANNEL_NAME} --tls --cafile ${ENV_ORDER_CA_CHAINFILE} --clientauth \
#    --keyfile ${ENV_CORE_PEER_TLS_CLIENTKEY_FILE} --certfile ${ENV_CORE_PEER_TLS_CLIENTCERT_FILE}
#
#peer chaincode list --instantiated -C ${ENV_CHANNEL_NAME} --tls --cafile ${ENV_ORDER_CA_CHAINFILE} --clientauth \
#    --keyfile ${ENV_CORE_PEER_TLS_CLIENTKEY_FILE} --certfile ${ENV_CORE_PEER_TLS_CLIENTCERT_FILE}
#
#
#peer chaincode install -n ${ENV_CHAIN_CODE_NAME} -v 2.0 -p ${ENV_CHAIN_CODE_PATH} --tls --cafile ${ENV_ORDER_CA_CHAINFILE} --clientauth \
#    --keyfile ${ENV_CORE_PEER_TLS_CLIENTKEY_FILE} --certfile ${ENV_CORE_PEER_TLS_CLIENTCERT_FILE}
#peer chaincode upgrade -o ${ENV_ORDERER_ADDRESS} -C ${ENV_CHANNEL_NAME} -n ${ENV_CHAIN_CODE_NAME} -v 2.0 \
#    -c '{"Args":["re-init"]}' -P "${ENV_CHAIN_CODE_POLICY}" --tls --cafile ${ENV_ORDER_CA_CHAINFILE} --clientauth \
#    --keyfile ${ENV_CORE_PEER_TLS_CLIENTKEY_FILE} --certfile ${ENV_CORE_PEER_TLS_CLIENTCERT_FILE}


peer chaincode invoke -C mychannel -n mycc2 -c '{"Args":["initMarble","marble1","blue","70","tom"]}' --tls --cafile /data/ordererorg-ca-chain.pem  --clientauth \
    --keyfile ${CORE_PEER_TLS_CLIENTKEY_FILE} --certfile ${CORE_PEER_TLS_CLIENTCERT_FILE}

peer chaincode query -C mychannel -n mycc2 -c '{"Args":["readMarble","marble1"]}' --tls --cafile /data/ordererorg-ca-chain.pem  --clientauth \
    --keyfile ${CORE_PEER_TLS_CLIENTKEY_FILE} --certfile ${CORE_PEER_TLS_CLIENTCERT_FILE}


sudo scp -r data/orgs/org1 blockchain@192.168.1.131:/home/blockchain/fabric/fabric-mainnet/data/orgs

sudo scp -r data/orgs/org2 blockchain@192.168.1.131:/home/blockchain/fabric/fabric-mainnet/data/orgs


sudo scp mychannel.tx ordererorg-ca-chain.pem org1-mychannel-anchors.tx blockchain@192.168.1.38:/home/blockchain/fabric/fabric-mainnet/data/

sudo scp ordererorg-ca-chain.pem org2-mychannel-anchors.tx blockchain@192.168.1.42:/home/blockchain/fabric/fabric-mainnet/data/


docker-compose -f docker-compose-peer.yml up -d peer0.org1.example.com