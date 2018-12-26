#!/usr/bin/env bash

source /scripts/utils.sh

log "Execute $0 args: "
env |grep 'ENV_'

function createChannel() {

    if [[ $# -ne 6 ]]; then
       fatal "Usage: $FUNCNAME CHANNEL_NAME CHANNEL_TX_FILE ORDERER_ADDRESS CA_CHAINFILE CORE_PEER_TLS_CLIENTKEY_FILE CORE_PEER_TLS_CLIENTCERT_FILE, Receive args:$*"
    fi

    log "$FUNCNAME args:$* "

    CHANNEL_NAME=$1
    CHANNEL_TX_FILE=$2
    ORDERER_ADDRESS=$3
    CA_CHAINFILE=$4
    CORE_PEER_TLS_CLIENTKEY_FILE=$5
    CORE_PEER_TLS_CLIENTCERT_FILE=$6

    # todo 检测channel是否已经存在，存在则跳过创建并打印警告信息
    peer channel create -c ${CHANNEL_NAME} -f ${CHANNEL_TX_FILE} -o ${ORDERER_ADDRESS} \
    --tls --cafile ${CA_CHAINFILE} --clientauth --keyfile ${CORE_PEER_TLS_CLIENTKEY_FILE} --certfile ${CORE_PEER_TLS_CLIENTCERT_FILE}

    verifyExecuteResult $? "Failed to create channel CHANNEL_NAME:${CHANNEL_NAME}"
}

function getChannelBlock() {

    if [[ $# -ne 5 ]]; then
       fatal "Usage: $FUNCNAME CHANNEL_NAME ORDERER_ADDRESS CA_CHAINFILE CORE_PEER_TLS_CLIENTKEY_FILE CORE_PEER_TLS_CLIENTCERT_FILE, Receive args:$*"
    fi

    log "$FUNCNAME args:$* "

    CHANNEL_NAME=$1
    ORDERER_ADDRESS=$2
    CA_CHAINFILE=$3
    CORE_PEER_TLS_CLIENTKEY_FILE=$4
    CORE_PEER_TLS_CLIENTCERT_FILE=$5

    peer channel fetch oldest ${CHANNEL_NAME}.block -c ${CHANNEL_NAME} -o ${ORDERER_ADDRESS} --tls \
    --cafile ${CA_CHAINFILE} --clientauth --keyfile ${CORE_PEER_TLS_CLIENTKEY_FILE} --certfile ${CORE_PEER_TLS_CLIENTCERT_FILE}

    verifyExecuteResult $? "Failed to fetch channel ${CHANNEL_NAME}.block"
}

function joinChannel() {

    if [[ $# -ne 6 ]]; then
       fatal "Usage: $FUNCNAME CHANNEL_NAME CA_CHAINFILE CORE_PEER_TLS_CLIENTKEY_FILE CORE_PEER_TLS_CLIENTCERT_FILE CORE_PEER_ADDRESS CORE_PEER_TLS_ROOTCERT_FILE, Receive args:$*"
    fi

    log "$FUNCNAME args:$* "

    CHANNEL_NAME=$1
    CA_CHAINFILE=$2
    CORE_PEER_TLS_CLIENTKEY_FILE=$3
    CORE_PEER_TLS_CLIENTCERT_FILE=$4
    export CORE_PEER_ADDRESS=$5
    export CORE_PEER_TLS_ROOTCERT_FILE=$6

    export CORE_PEER_TLS_ENABLED=true
    export CORE_PEER_TLS_CLIENTAUTHREQUIRED=true
    export CORE_PEER_TLS_CLIENTCERT_FILE=${CORE_PEER_TLS_CLIENTCERT_FILE}
    export CORE_PEER_TLS_CLIENTKEY_FILE=${CORE_PEER_TLS_CLIENTKEY_FILE}
    export CORE_PEER_PROFILE_ENABLED=true

    peer channel join -b ${CHANNEL_NAME}.block --tls --cafile ${CA_CHAINFILE} --clientauth \
    --keyfile ${CORE_PEER_TLS_CLIENTKEY_FILE} --certfile ${CORE_PEER_TLS_CLIENTCERT_FILE}

    verifyExecuteResult $? "Failed to join channel CHANNEL_NAME:${CHANNEL_NAME}"
}

function updateAnchor() {

    if [[ $# -ne 6 ]]; then
       fatal "$FUNCNAME CHANNEL_NAME ANCHOR_TX_FILE ORDERER_ADDRESS CA_CHAINFILE CORE_PEER_TLS_CLIENTKEY_FILE CORE_PEER_TLS_CLIENTCERT_FILE, Receive args:$*"
    fi

    log "$FUNCNAME args:$* "

    CHANNEL_NAME=$1
    ANCHOR_TX_FILE=$2
    ORDERER_ADDRESS=$3
    CA_CHAINFILE=$4
    CORE_PEER_TLS_CLIENTKEY_FILE=$5
    CORE_PEER_TLS_CLIENTCERT_FILE=$6

    peer channel update -c ${CHANNEL_NAME} -f ${ANCHOR_TX_FILE} -o ${ORDERER_ADDRESS} \
    --tls --cafile ${CA_CHAINFILE} --clientauth --keyfile ${CORE_PEER_TLS_CLIENTKEY_FILE} --certfile ${CORE_PEER_TLS_CLIENTCERT_FILE}

    verifyExecuteResult $? "Failed to update channel anchor CHANNEL_NAME:${CHANNEL_NAME}"
}


export FABRIC_CFG_PATH=${ENV_FABRIC_CFG_PATH}
export CORE_PEER_LOCALMSPID=${ENV_CORE_PEER_LOCALMSPID}

getOrgAdminMSP ${ENV_ADMIN_MSP_DIR} ${ENV_PEER_CA_CHAINFILE} ${ENV_ADMIN_ENROLLMENT_URL}

if [[ "${ENV_MODE}" == "create" ]]; then
    createChannel ${ENV_CHANNEL_NAME} ${ENV_CHANNEL_TX_FILE} ${ENV_ORDERER_ADDRESS} ${ENV_ORDER_CA_CHAINFILE} ${ENV_CORE_PEER_TLS_CLIENTKEY_FILE} ${ENV_CORE_PEER_TLS_CLIENTCERT_FILE}
fi

# 这里 CORE_PEER_TLS_CLIENTCERT_FILE 不同peer可能需要多套，目前采用一个组织一套
PEER_ADDRESS_LIST=(${ENV_PEER_ADDRESS_LIST//,/ })
for peer in ${PEER_ADDRESS_LIST[@]}; do
    if [[ ! -f "${ENV_CHANNEL_NAME}.block" ]]; then
        getChannelBlock ${ENV_CHANNEL_NAME} ${ENV_ORDERER_ADDRESS} ${ENV_ORDER_CA_CHAINFILE} ${ENV_CORE_PEER_TLS_CLIENTKEY_FILE} ${ENV_CORE_PEER_TLS_CLIENTCERT_FILE}
    fi
    joinChannel ${ENV_CHANNEL_NAME} ${ENV_ORDER_CA_CHAINFILE} ${ENV_CORE_PEER_TLS_CLIENTKEY_FILE} ${ENV_CORE_PEER_TLS_CLIENTCERT_FILE} ${peer} ${ENV_PEER_CA_CHAINFILE}
done

updateAnchor ${ENV_CHANNEL_NAME} ${ENV_ANCHOR_TX_FILE} ${ENV_ORDERER_ADDRESS} ${ENV_ORDER_CA_CHAINFILE} ${ENV_CORE_PEER_TLS_CLIENTKEY_FILE} ${ENV_CORE_PEER_TLS_CLIENTCERT_FILE}
