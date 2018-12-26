#!/usr/bin/env bash

source ./scripts/utils.sh

ENV_CHANNEL_NAME=mychannel   # 应用通道名
ENV_PEER_ORGS=org1,org2      # peer组织，多个组织使用“，”分割，不需要多余空格
ENV_CHANNEL_TX_FILE=${ENV_CHANNEL_NAME}.tx         #固定值
ENV_ANCHOR_TX_FILE=${ENV_CHANNEL_NAME}-anchors.tx  #固定值

# check cli container
checkCliContainer docker-compose-ca.yml

docker exec -e "ENV_CHANNEL_TX_FILE=${ENV_CHANNEL_TX_FILE}" -e "ENV_CHANNEL_NAME=${ENV_CHANNEL_NAME}" \
-e "ENV_PEER_ORGS=${ENV_PEER_ORGS}"  -e "ENV_ANCHOR_TX_FILE=${ENV_ANCHOR_TX_FILE}" fabric-cli ./scripts/gen_channel_tx.sh
