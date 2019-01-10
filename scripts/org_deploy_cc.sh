#!/usr/bin/env bash

source /scripts/utils.sh

log "Execute $0 args: "
env |grep 'ENV_'

function setPeerEnv() {

    if [[ $# -ne 5 ]]; then
       fatal "Usage: $FUNCNAME PEER_LOCALMSPID PEER_ADDRESS ROOT_CERT CORE_PEER_TLS_CLIENTCERT_FILE CORE_PEER_TLS_CLIENTKEY_FILE, Receive args:$*"
    fi

    log "$FUNCNAME args:$* "

    PEER_LOCALMSPID=$1
    PEER_ADDRESS=$2
    ROOT_CERT=$3
    CORE_PEER_TLS_CLIENTCERT_FILE=$4
    CORE_PEER_TLS_CLIENTKEY_FILE=$5

    export CORE_PEER_LOCALMSPID=${PEER_LOCALMSPID}
    export CORE_PEER_ADDRESS=${PEER_ADDRESS}
    export CORE_PEER_TLS_ROOTCERT_FILE=${ROOT_CERT}
    export CORE_PEER_TLS_CLIENTCERT_FILE=${CORE_PEER_TLS_CLIENTCERT_FILE}
    export CORE_PEER_TLS_CLIENTKEY_FILE=${CORE_PEER_TLS_CLIENTKEY_FILE}
    export CORE_PEER_TLS_ENABLED=true
    export CORE_PEER_TLS_CLIENTAUTHREQUIRED=true
    export CORE_PEER_PROFILE_ENABLED=true
}

function installChainCode() {

    if [[ $# -ne 6 ]]; then
       fatal "Usage: $FUNCNAME CHAIN_CODE_NAME CHAIN_CODE_VERSION CHAIN_CODE_PATH ORDER_CA_CHAINFILE
       CORE_PEER_TLS_CLIENTKEY_FILE CORE_PEER_TLS_CLIENTCERT_FILE, Receive args:$*"
    fi

    log "$FUNCNAME args:$* "

    CHAIN_CODE_NAME=$1
    CHAIN_CODE_VERSION=$2
    CHAIN_CODE_PATH=$3
    ORDER_CA_CHAINFILE=$4
    CORE_PEER_TLS_CLIENTKEY_FILE=$5
    CORE_PEER_TLS_CLIENTCERT_FILE=$6

    peer chaincode install -n ${CHAIN_CODE_NAME} -v ${CHAIN_CODE_VERSION} -p ${CHAIN_CODE_PATH} --tls --cafile ${ORDER_CA_CHAINFILE} --clientauth \
    --keyfile ${CORE_PEER_TLS_CLIENTKEY_FILE} --certfile ${CORE_PEER_TLS_CLIENTCERT_FILE}

    verifyExecuteResult $? "Failed to install chain code for org peers"
}

function upgradeChainCode() {

    if [[ $# -ne 8 ]]; then
       fatal "Usage: $FUNCNAME CHANNEL_NAME CHAIN_CODE_NAME CHAIN_CODE_VERSION CHAIN_CODE_POLICY ORDERER_ADDRESS
       ORDER_CA_CHAINFILE CORE_PEER_TLS_CLIENTKEY_FILE CORE_PEER_TLS_CLIENTCERT_FILE, Receive args:$*"
    fi

    log "$FUNCNAME args:$* "

    CHANNEL_NAME=$1
    CHAIN_CODE_NAME=$2
    CHAIN_CODE_VERSION=$3
    CHAIN_CODE_POLICY=$4
    ORDERER_ADDRESS=$5
    ORDER_CA_CHAINFILE=$6
    CORE_PEER_TLS_CLIENTKEY_FILE=$7
    CORE_PEER_TLS_CLIENTCERT_FILE=$8

    peer chaincode upgrade -o ${ORDERER_ADDRESS} -C ${CHANNEL_NAME} -n ${CHAIN_CODE_NAME} -v ${CHAIN_CODE_VERSION} \
    -c '{"Args":["re-init"]}' -P "${CHAIN_CODE_POLICY}" --tls --cafile ${ORDER_CA_CHAINFILE} --clientauth \
    --keyfile ${CORE_PEER_TLS_CLIENTKEY_FILE} --certfile ${CORE_PEER_TLS_CLIENTCERT_FILE}

    verifyExecuteResult $? "Failed to upgrade chain code for org peers"
}

function instantiateChainCode() {

    if [[ $# -ne 9 ]]; then
       fatal "Usage: $FUNCNAME CHANNEL_NAME CHAIN_CODE_NAME CHAIN_CODE_VERSION INIT_ARGS CHAIN_CODE_POLICY
       ORDERER_ADDRESS ORDER_CA_CHAINFILE CORE_PEER_TLS_CLIENTKEY_FILE CORE_PEER_TLS_CLIENTCERT_FILE, Receive args:$*"
    fi

    log "$FUNCNAME args:$* "

    CHANNEL_NAME=$1
    CHAIN_CODE_NAME=$2
    CHAIN_CODE_VERSION=$3
    INIT_ARGS=$4
    CHAIN_CODE_POLICY=$5
    ORDERER_ADDRESS=$6
    ORDER_CA_CHAINFILE=$7
    CORE_PEER_TLS_CLIENTKEY_FILE=$8
    CORE_PEER_TLS_CLIENTCERT_FILE=$9

    peer chaincode instantiate -C ${CHANNEL_NAME} -n ${CHAIN_CODE_NAME} -v ${CHAIN_CODE_VERSION} -c "${INIT_ARGS}" \
    -P "${CHAIN_CODE_POLICY}" -o ${ORDERER_ADDRESS}  --tls --cafile ${ORDER_CA_CHAINFILE} --clientauth \
    --keyfile ${CORE_PEER_TLS_CLIENTKEY_FILE} --certfile ${CORE_PEER_TLS_CLIENTCERT_FILE}

#    verifyExecuteResult $? "Failed to instantiate chain code for channel CHANNEL_NAME:${CHANNEL_NAME}"
}

listInstalledChaincode() {

    if [[ $# -ne 4 ]]; then
       fatal "Usage: $FUNCNAME CHANNEL_NAME ORDER_CA_CHAINFILE CORE_PEER_TLS_CLIENTKEY_FILE CORE_PEER_TLS_CLIENTCERT_FILE, Receive args:$*"
    fi

    log "$FUNCNAME args:$* "

    CHANNEL_NAME=$1
    ORDER_CA_CHAINFILE=$2
    CORE_PEER_TLS_CLIENTKEY_FILE=$3
    CORE_PEER_TLS_CLIENTCERT_FILE=$4

    peer chaincode list --installed -C ${CHANNEL_NAME} --tls --cafile ${ORDER_CA_CHAINFILE} --clientauth \
    --keyfile ${CORE_PEER_TLS_CLIENTKEY_FILE} --certfile ${CORE_PEER_TLS_CLIENTCERT_FILE}

    log "----------------------------------------------------------------------------"

    verifyExecuteResult $? "Failed to list install chain code from CHANNEL_NAME:${CHANNEL_NAME}"
}

listInstantiateChaincode() {

    if [[ $# -ne 4 ]]; then
       fatal "Usage: $FUNCNAME CHANNEL_NAME ORDER_CA_CHAINFILE CORE_PEER_TLS_CLIENTKEY_FILE CORE_PEER_TLS_CLIENTCERT_FILE, Receive args:$*"
    fi

    log "$FUNCNAME args:$* "

    CHANNEL_NAME=$1
    ORDER_CA_CHAINFILE=$2
    CORE_PEER_TLS_CLIENTKEY_FILE=$3
    CORE_PEER_TLS_CLIENTCERT_FILE=$4

    peer chaincode list --instantiated -C ${CHANNEL_NAME} --tls --cafile ${ORDER_CA_CHAINFILE} --clientauth \
    --keyfile ${CORE_PEER_TLS_CLIENTKEY_FILE} --certfile ${CORE_PEER_TLS_CLIENTCERT_FILE}

    log "----------------------------------------------------------------------------"

    verifyExecuteResult $? "Failed to list instantiated chain code from CHANNEL_NAME:${CHANNEL_NAME}"
}

getOrgAdminMSP ${ENV_ADMIN_MSP_DIR} ${ENV_ORDER_CA_CHAINFILE} ${ENV_ADMIN_ENROLLMENT_URL}

PEER_ADDRESS_LIST=(${ENV_PEER_ADDRESS_LIST//,/ })
for peer in ${PEER_ADDRESS_LIST[@]}; do
    setPeerEnv ${ENV_CORE_PEER_LOCALMSPID} ${peer} ${ENV_PEER_CA_CHAINFILE}  ${ENV_CORE_PEER_TLS_CLIENTCERT_FILE} ${ENV_CORE_PEER_TLS_CLIENTKEY_FILE}

    installChainCode ${ENV_CHAIN_CODE_NAME} ${ENV_CHAIN_CODE_VERSION} ${ENV_CHAIN_CODE_PATH} ${ENV_ORDER_CA_CHAINFILE} \
    ${ENV_CORE_PEER_TLS_CLIENTKEY_FILE} ${ENV_CORE_PEER_TLS_CLIENTCERT_FILE}
done

if [[ "${ENV_MODE}" == "install" ]]; then
    instantiateChainCode ${ENV_CHANNEL_NAME} ${ENV_CHAIN_CODE_NAME} ${ENV_CHAIN_CODE_VERSION} ${ENV_INIT_ARGS} \
    "${ENV_CHAIN_CODE_POLICY}" ${ENV_ORDERER_ADDRESS} ${ENV_ORDER_CA_CHAINFILE} ${ENV_CORE_PEER_TLS_CLIENTKEY_FILE} \
    ${ENV_CORE_PEER_TLS_CLIENTCERT_FILE}
else
    upgradeChainCode ${ENV_CHANNEL_NAME} ${ENV_CHAIN_CODE_NAME} ${ENV_CHAIN_CODE_VERSION} "${ENV_CHAIN_CODE_POLICY}" ${ENV_ORDERER_ADDRESS} \
    ${ENV_ORDER_CA_CHAINFILE} ${ENV_CORE_PEER_TLS_CLIENTKEY_FILE} ${ENV_CORE_PEER_TLS_CLIENTCERT_FILE}
fi

listInstalledChaincode ${ENV_CHANNEL_NAME} ${ENV_ORDER_CA_CHAINFILE} ${ENV_CORE_PEER_TLS_CLIENTKEY_FILE} \
${ENV_CORE_PEER_TLS_CLIENTCERT_FILE}

sleep 10

listInstantiateChaincode ${ENV_CHANNEL_NAME} ${ENV_ORDER_CA_CHAINFILE} ${ENV_CORE_PEER_TLS_CLIENTKEY_FILE} \
${ENV_CORE_PEER_TLS_CLIENTCERT_FILE}
