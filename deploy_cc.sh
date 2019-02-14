#!/usr/bin/env bash

source ./scripts/utils.sh

ORG=$1
: ${ORG:="org1"}
ORG_ADMIN_NAME=${ORG}-admin   # 组织管理员名称
ORG_ADMIN_PASS=adminpw        # 组织管理员密码
CA_ADDRESS=ica-${ORG}.example.com:7054  # 组织服务CA地址

ENV_MODE=$2   # install or upgrade, 安装或者升级chain code
: ${ENV_MODE:="install"}
ENV_CHAIN_CODE_NAME=$3
: ${ENV_CHAIN_CODE_NAME:="sbccc"}
ENV_CHAIN_CODE_VERSION=$4
: ${ENV_CHAIN_CODE_VERSION:="1.0"}
ENV_CORE_PEER_LOCALMSPID=${ORG}MSP
ENV_ADMIN_MSP_DIR=/data/orgs/${ORG}/admin      # 固定值
ENV_PEER_CA_CHAINFILE=/data/${ORG}-ca-chain.pem     # 固定值
ENV_ORDER_CA_CHAINFILE=/data/ordererorg-ca-chain.pem     # 固定值
ENV_ADMIN_ENROLLMENT_URL=https://${ORG_ADMIN_NAME}:${ORG_ADMIN_PASS}@${CA_ADDRESS}
ENV_CHANNEL_NAME=supplychainchannel    #创建或更新的应用通道名
ENV_CHAIN_CODE_PATH=git.coding.net/digcreditdev/sbc-cc
ENV_INIT_ARGS='{"Args":["init"]}'    #实例化或升级参数，升级为'{"Args":["re-init"]}'
ENV_CHAIN_CODE_POLICY="OR ('org1MSP.member','org2MSP.member')"
ENV_ORDERER_ADDRESS=order1-ordererorg.example.com:7050    # 排序节点地址
ENV_CORE_PEER_TLS_CLIENTKEY_FILE=/data/tls/peer0.${ORG}.example.com-cli-client.key   # tls key
ENV_CORE_PEER_TLS_CLIENTCERT_FILE=/data/tls/peer0.${ORG}.example.com-cli-client.crt  # tls 证书
ENV_PEER_ADDRESS_LIST=peer0.${ORG}.example.com:7051,peer1.${ORG}.example.com:8051              # 组织中的peer节点列表

# check cli container
checkCliContainer docker-compose-ca.yml

docker exec -e "ENV_MODE=${ENV_MODE}" -e "ENV_ADMIN_MSP_DIR=${ENV_ADMIN_MSP_DIR}" -e "ENV_PEER_CA_CHAINFILE=${ENV_PEER_CA_CHAINFILE}" \
-e "ENV_ADMIN_ENROLLMENT_URL=${ENV_ADMIN_ENROLLMENT_URL}" -e "ENV_CHANNEL_NAME=${ENV_CHANNEL_NAME}" \
-e "ENV_ORDERER_ADDRESS=${ENV_ORDERER_ADDRESS}" -e "ENV_CORE_PEER_TLS_CLIENTKEY_FILE=${ENV_CORE_PEER_TLS_CLIENTKEY_FILE}" \
-e "ENV_CORE_PEER_TLS_CLIENTCERT_FILE=${ENV_CORE_PEER_TLS_CLIENTCERT_FILE}" -e "ENV_PEER_ADDRESS_LIST=${ENV_PEER_ADDRESS_LIST}"  \
-e "ENV_CHAIN_CODE_NAME=${ENV_CHAIN_CODE_NAME}" -e "ENV_CHAIN_CODE_VERSION=${ENV_CHAIN_CODE_VERSION}" \
-e "ENV_CHAIN_CODE_PATH=${ENV_CHAIN_CODE_PATH}" -e "ENV_INIT_ARGS=${ENV_INIT_ARGS}"  -e "ENV_CHAIN_CODE_POLICY=${ENV_CHAIN_CODE_POLICY}" \
-e "ENV_CORE_PEER_LOCALMSPID=${ENV_CORE_PEER_LOCALMSPID}" -e "ENV_ORDER_CA_CHAINFILE=${ENV_ORDER_CA_CHAINFILE}" \
fabric-cli ./scripts/org_deploy_cc.sh


