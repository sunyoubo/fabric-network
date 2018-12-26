#!/usr/bin/env bash

# 该程序用于应用通道发起组织创建通道并更新该组织锚节点配置，也用于非业务发起组织更新组织锚节点配置

source ./scripts/utils.sh

ORG=org2          # 组织名称
ORG_ADMIN_NAME=${ORG}-admin   # 组织管理员名称
ORG_ADMIN_PASS=adminpw        # 组织管理员密码
CA_ADDRESS=ica-org2.example.com:7054  # 组织服务CA地址

ENV_MODE=update   # create or update, 只有需要创建channel的组织设置为create,否则为update
ENV_CORE_PEER_LOCALMSPID=${ORG}MSP
ENV_ADMIN_MSP_DIR=/data/orgs/${ORG}/admin      # 固定值
ENV_PEER_CA_CHAINFILE=/data/${ORG}-ca-chain.pem     # 固定值
ENV_ORDER_CA_CHAINFILE=/data/ordererorg-ca-chain.pem     # 固定值
ENV_ADMIN_ENROLLMENT_URL=https://${ORG_ADMIN_NAME}:${ORG_ADMIN_PASS}@${CA_ADDRESS}
ENV_CHANNEL_NAME=mychannel    #创建或更新的应用通道名
ENV_CHANNEL_TX_FILE=/data/${ENV_CHANNEL_NAME}.tx  # 固定值
ENV_ORDERER_ADDRESS=order1-ordererorg.example.com:7050    # 排序节点地址
ENV_CORE_PEER_TLS_CLIENTKEY_FILE=/data/tls/peer0.org2.example.com-cli-client.key   # tls key
ENV_CORE_PEER_TLS_CLIENTCERT_FILE=/data/tls/peer0.org2.example.com-cli-client.crt  # tls 证书
ENV_PEER_ADDRESS_LIST=peer0.org2.example.com:7051,peer1.org2.example.com:7051      # 组织中的peer节点列表
ENV_ANCHOR_TX_FILE=/data/${ORG}-${ENV_CHANNEL_NAME}-anchors.tx                                  # 锚节点更新配置文件
ENV_FABRIC_CFG_PATH=/etc/hyperledger/fabric/    # peer 配置文件目录，包含core.yaml文件


# check cli container
checkCliContainer docker-compose-ca.yml

docker exec -e "ENV_MODE=${ENV_MODE}" -e "ENV_ADMIN_MSP_DIR=${ENV_ADMIN_MSP_DIR}" -e "ENV_ORDER_CA_CHAINFILE=${ENV_ORDER_CA_CHAINFILE}" \
-e "ENV_ADMIN_ENROLLMENT_URL=${ENV_ADMIN_ENROLLMENT_URL}" -e "ENV_CHANNEL_NAME=${ENV_CHANNEL_NAME}" \
-e "ENV_CHANNEL_TX_FILE=${ENV_CHANNEL_TX_FILE}" -e "ENV_ORDERER_ADDRESS=${ENV_ORDERER_ADDRESS}" \
-e "ENV_CORE_PEER_TLS_CLIENTKEY_FILE=${ENV_CORE_PEER_TLS_CLIENTKEY_FILE}" \
-e "ENV_CORE_PEER_TLS_CLIENTCERT_FILE=${ENV_CORE_PEER_TLS_CLIENTCERT_FILE}" -e "ENV_PEER_ADDRESS_LIST=${ENV_PEER_ADDRESS_LIST}" \
-e "ENV_ANCHOR_TX_FILE=${ENV_ANCHOR_TX_FILE}" -e "ENV_CORE_PEER_LOCALMSPID=${ENV_CORE_PEER_LOCALMSPID}" \
-e "ENV_PEER_CA_CHAINFILE=${ENV_PEER_CA_CHAINFILE}" \
fabric-cli ./scripts/create_update_channel.sh

