#!/usr/bin/env bash

# import utils.sh
source /scripts/utils.sh

# 登记CA引导身份
fabric-ca-client enroll -d -u https://${CA_ADMIN_USER_PASS}@${CA_ADDRESS} --caname ${CA_NAME}
#文件变化如下
#/opt/gopath/src/github.com/hyperledger/fabric/peer
#|-- fabric-ca-client-config.yaml
#`-- msp
#    |-- IssuerPublicKey
#    |-- IssuerRevocationPublicKey
#    |-- cacerts
#    |   `-- ica-org1-example-com-7054-ica-org1-example-com.pem
#    |-- intermediatecerts
#    |   `-- ica-org1-example-com-7054-ica-org1-example-com.pem
#    |-- keystore
#    |   `-- ca3359d0fb085055c73be7e1e012d3616243b168d3318c3ea54a7db2f025c6b3_sk
#    |-- signcerts
#    |   `-- cert.pem
#    `-- user

# 注册peer
fabric-ca-client register -d --id.name ${PEER_NAME} --id.secret ${PEER_PASS} --id.type peer

# Generate server TLS cert and key pair for the peer
fabric-ca-client enroll -d --enrollment.profile tls -u https://${PEER_NAME}:${PEER_PASS}@${CA_ADDRESS} -M /tmp/tls --csr.hosts ${PEER_HOST}
# Copy the TLS key and cert to the appropriate place
mkdir -p ${PEER_HOME}/tls
cp /tmp/tls/signcerts/* ${CORE_PEER_TLS_CERT_FILE}
cp /tmp/tls/keystore/* ${CORE_PEER_TLS_KEY_FILE}
rm -rf /tmp/tls

# Generate client TLS cert and key pair for the peer
genClientTLSCert ${PEER_NAME} ${CORE_PEER_TLS_CLIENTCERT_FILE} ${CORE_PEER_TLS_CLIENTKEY_FILE} https://${PEER_NAME}:${PEER_PASS}@${CA_ADDRESS}

# Generate client TLS cert and key pair for the peer CLI
genClientTLSCert ${PEER_NAME} /data/tls/${PEER_NAME}-cli-client.crt /data/tls/${PEER_NAME}-cli-client.key https://${PEER_NAME}:${PEER_PASS}@${CA_ADDRESS}

# Enroll the peer to get an enrollment certificate and set up the core's local MSP directory
fabric-ca-client enroll -d -u https://${PEER_NAME}:${PEER_PASS}@${CA_ADDRESS} -M ${CORE_PEER_MSPCONFIGPATH}
#目录变化：
#/opt/gopath/src/github.com/hyperledger/fabric/peer/
#|-- fabric-ca-client-config.yamlER_NAME}:${PEER_PASS}@${CA_ADDRESS} -M ${CORE_P
#|-- msp
#|   |-- IssuerPublicKey
#|   |-- IssuerRevocationPublicKey
#|   |-- cacerts
#|   |   |-- ica-org1-example-com-7054-ica-org1-example-com.pem  # 旧文件
#|   |   `-- ica-org1-example-com-7054.pem
#|   |-- intermediatecerts
#|   |   |-- ica-org1-example-com-7054-ica-org1-example-com.pem  # 旧文件
#|   |   `-- ica-org1-example-com-7054.pem
#|   |-- keystore
#|   |   |-- 992eb21e64bae19752dba981bb23ee18af6ab65f4dee12f8e0812d5fb99c66a8_sk
#|   |   `-- ca3359d0fb085055c73be7e1e012d3616243b168d3318c3ea54a7db2f025c6b3_sk  # 旧文件
#|   |-- signcerts
#|   |   `-- cert.pem
#|   `-- user
#`-- tls
#    |-- server.crt
#    `-- server.key

fillTLSForMSP ${CORE_PEER_MSPCONFIGPATH}

fillAdminCertForMSP ${CORE_PEER_MSPCONFIGPATH}

# Start the peer
log "Starting peer ${PEER_NAME} with MSP at ${CORE_PEER_MSPCONFIGPATH} "
env | grep CORE
peer node start

