#!/usr/bin/env bash

# import utils.sh
source /scripts/utils.sh

if [[ ! -d ${ORDERER_GENERAL_LOCALMSPDIR}/cacerts ]];then
    # 登记CA引导身份
    fabric-ca-client enroll -d -u https://${CA_ADMIN_USER_PASS}@${CA_ADDRESS} --caname ${CA_NAME}

    # 注册orderer, 多个orderer时，各自分别注册
    fabric-ca-client register -d --id.name ${ORDERER_NAME} --id.secret ${ORDERER_PASS} --id.type orderer

    # Enroll to get orderer's TLS cert (using the "tls" profile)
    fabric-ca-client enroll -d --enrollment.profile tls -u https://${ORDERER_NAME}:${ORDERER_PASS}@${CA_ADDRESS} -M /tmp/tls --csr.hosts ${ORDERER_HOST}
    # Copy the TLS key and cert to the appropriate place
    TLSDIR=${ORDERER_HOME}/tls
    mkdir -p ${TLSDIR}
    cp /tmp/tls/keystore/* ${ORDERER_GENERAL_TLS_PRIVATEKEY}
    cp /tmp/tls/signcerts/* ${ORDERER_GENERAL_TLS_CERTIFICATE}
    rm -rf /tmp/tls

    # 获取order证书
    fabric-ca-client enroll -u https://${ORDERER_NAME}:${ORDERER_PASS}@${CA_ADDRESS} -M ${ORDERER_GENERAL_LOCALMSPDIR}

    fillTLSForMSP ${ORDERER_GENERAL_LOCALMSPDIR}

    fillAdminCertForMSP ${ORDERER_GENERAL_LOCALMSPDIR}
fi

# Start the orderer
env | grep ORDERER
orderer start