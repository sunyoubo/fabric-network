#!/usr/bin/env bash

source /scripts/utils.sh

log "Execute $0 args: "
env |grep 'ENV_'

# 登记CA引导用户
function enrollCaAdmin() {

    if [[ $# -ne 3 ]]; then
       fatal "Usage: $FUNCNAME CA_CLIENT_HOME CA_CHAINFILE CA_ADMIN_ENROLLMENT_URL, Receive args:$*"
    fi

    log "$FUNCNAME args:$* "

    CA_CLIENT_HOME=$1
    CA_CHAINFILE=$2
    CA_ADMIN_ENROLLMENT_URL=$3

    export FABRIC_CA_CLIENT_HOME=${CA_CLIENT_HOME}
    export FABRIC_CA_CLIENT_TLS_CERTFILES=${CA_CHAINFILE}

    fabric-ca-client enroll -d -u ${CA_ADMIN_ENROLLMENT_URL}
    verifyExecuteResult $? "enroll ca admin error, CA_ADMIN_ENROLLMENT_URL:${CA_ADMIN_ENROLLMENT_URL}"

#       目录变化如下
#`-- orderer
#    |-- fabric-ca-client-config.yaml
#    `-- msp
#        |-- IssuerPublicKey
#        |-- IssuerRevocationPublicKey
#        |-- cacerts
#        |   `-- ica-ordererorg-example-com-7054.pem
#        |-- intermediatecerts
#        |   `-- ica-ordererorg-example-com-7054.pem
#        |-- keystore
#        |   `-- 1cbd500060cb8273a5977542c510705701fc77af3a48cf09f4710debc24858f0_sk
#        |-- signcerts
#        |   `-- cert.pem
#        `-- user
}

# 获取CA根证书并生成组织MSP
function getCaCerts() {

    if [[ $# -ne 2 ]]; then
       fatal "Usage: $FUNCNAME CA_ADDRESS ORG_MSP_DIR, Receive args:$*"
    fi

    log "$FUNCNAME args:$* "

    CA_ADDRESS=$1
    ORG_MSP_DIR=$2

    fabric-ca-client getcacert -d -u https://${CA_ADDRESS} -M ${ORG_MSP_DIR}
    verifyExecuteResult $? "Get Ca cert Error, -u https://${CA_ADDRESS} -M ${ORG_MSP_DIR}"
#    目录变化如下：
#        root@c92708144389:/etc/hyperledger# tree -L 4 ${ORG_MSP_DIR}
#        /data/orgs/ordererorg/msp
#        |-- IssuerPublicKey
#        |-- IssuerRevocationPublicKey
#        |-- cacerts
#        |   `-- ica-ordererorg-example-com-7054.pem
#        |-- intermediatecerts
#        |   `-- ica-ordererorg-example-com-7054.pem
#        |-- keystore
#        |-- signcerts
#        `-- user
    fillTLSForMSP ${ORG_MSP_DIR}

#    目录变化如下：
#        root@c92708144389:/etc/hyperledger# tree -L 4 ${ORG_MSP_DIR}
#        /data/orgs/ordererorg/msp
#        |-- IssuerPublicKey
#        |-- IssuerRevocationPublicKey
#        |-- cacerts
#        |   `-- ica-ordererorg-example-com-7054.pem
#        |-- intermediatecerts
#        |   `-- ica-ordererorg-example-com-7054.pem
#        |-- keystore
#        |-- signcerts
#        |-- tlscacerts
#        |   `-- ica-ordererorg-example-com-7054.pem
#        |-- tlsintermediatecerts
#        |   `-- ica-ordererorg-example-com-7054.pem
#        `-- user
}

# 获取组织admin证书并生成MSP
function getOrgAdminCerts() {

    if [[ $# -ne 6 ]]; then
       fatal "Usage: $FUNCNAME ORG_ADMIN_NAME ORG_ADMIN_PASS ORG_ADMIN_HOME CA_CHAINFILE ORG_ADMIN_ENROLLMENT_URL ORG_ADMIN_CERT, Receive args:$*"
    fi

    log "$FUNCNAME args:$* "

    ORG_ADMIN_NAME=$1
    ORG_ADMIN_PASS=$2
    ORG_ADMIN_HOME=$3
    CA_CHAINFILE=$4
    ORG_ADMIN_ENROLLMENT_URL=$5
    ORG_ADMIN_CERT=$6

    # 注册组织 admin
    fabric-ca-client register -d --id.name ${ORG_ADMIN_NAME} --id.secret ${ORG_ADMIN_PASS} --id.attrs "admin=true:ecert"
    verifyExecuteResult $? "register org admin Error, --id.name ${ORG_ADMIN_NAME} --id.secret ${ORG_ADMIN_PASS}"

    # 获取组织 admin 证书
    export FABRIC_CA_CLIENT_HOME=${ORG_ADMIN_HOME}
    export FABRIC_CA_CLIENT_TLS_CERTFILES=${CA_CHAINFILE}
    fabric-ca-client enroll  -d -u ${ORG_ADMIN_ENROLLMENT_URL}
    verifyExecuteResult $? "Enroll org admin Error, -u ${ORG_ADMIN_ENROLLMENT_URL}"

    # 拷贝 组织admin到组织msp中
    mkdir -p $(dirname "${ORG_ADMIN_CERT}")
    cp ${ORG_ADMIN_HOME}/msp/signcerts/* ${ORG_ADMIN_CERT}

    mkdir ${ORG_ADMIN_HOME}/msp/admincerts
    cp ${ORG_ADMIN_HOME}/msp/signcerts/* ${ORG_ADMIN_HOME}/msp/admincerts
}

enrollCaAdmin ${ENV_CA_CLIENT_HOME} ${ENV_CA_CHAINFILE} ${ENV_CA_ADMIN_ENROLLMENT_URL}

getCaCerts ${ENV_CA_ADDRESS} ${ENV_ORG_MSP_DIR}

getOrgAdminCerts ${ENV_ORG_ADMIN_NAME} ${ENV_ORG_ADMIN_PASS} ${ENV_ORG_ADMIN_HOME} ${ENV_CA_CHAINFILE} ${ENV_ORG_ADMIN_ENROLLMENT_URL} ${ENV_ORG_ADMIN_CERT}