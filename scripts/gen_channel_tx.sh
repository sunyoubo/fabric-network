#!/usr/bin/env bash

source /scripts/utils.sh

log "Execute $0 args: "
env |grep 'ENV_'

# 生成应用通道配置文件
function createChannelTx() {

    if [[ $# -ne 2 ]]; then
       fatal "Usage: $FUNCNAME CHANNEL_TX_FILE CHANNEL_NAME, Receive args:$*"
    fi
    CHANNEL_TX_FILE=$1
    CHANNEL_NAME=$2

    configtxgen -profile OrgsChannel -outputCreateChannelTx /data/${CHANNEL_TX_FILE} -channelID ${CHANNEL_NAME}
    verifyExecuteResult $? "Failed to generate channel configuration transaction"
}

# 生成组织锚节点配置文件
function getOrgAnchorsTX () {

    if [[ $# -ne 3 ]]; then
       fatal "Usage: $FUNCNAME ANCHOR_TX_FILE CHANNEL_NAME ORG_NAME, Receive args:$*"
    fi
    ANCHOR_TX_FILE=$1
    CHANNEL_NAME=$2
    ORG_NAME=$3

    configtxgen -profile OrgsChannel -outputAnchorPeersUpdate /data/${ORG_NAME}-${ANCHOR_TX_FILE} -channelID ${CHANNEL_NAME} -asOrg ${ORG_NAME}
    verifyExecuteResult $? "Failed to generate anchor peer update for ${ORG_MSP}"
}

cd /data
export FABRIC_CFG_PATH=/data

createChannelTx ${ENV_CHANNEL_TX_FILE} ${ENV_CHANNEL_NAME}

PEER_ORG_LIST=(${ENV_PEER_ORGS//,/ })
for ORG in ${PEER_ORG_LIST[@]}; do
    getOrgAnchorsTX ${ENV_ANCHOR_TX_FILE} ${ENV_CHANNEL_NAME} ${ORG}
done


