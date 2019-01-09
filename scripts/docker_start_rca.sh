#!/usr/bin/env bash

sleep 20

fabric-ca-server init -b ${BOOTSTRAP_USER_PASS} --db.type mysql --db.datasource "${MYSQL_USER_PASS}@tcp(${MYSQL_HOST}:3306)/fabric_ca?parseTime=true"
#产生如下文件：
#root@49765fb0f69e:/etc/hyperledger# tree -L 4 fabric-ca
#fabric-ca
#|-- IssuerPublicKey
#|-- IssuerRevocationPublicKey
#|-- ca-cert.pem
#|-- fabric-ca-server-config.yaml
#`-- msp
#    `-- keystore
#        |-- 0574ba70d2e1f40f310de4aae6e55671484cded9cfee11260f95949b3ca3eda6_sk
#        |-- IssuerRevocationPrivateKey
#        `-- IssuerSecretKey


# Copy the root CA's signing certificate to the data directory to be used by others
cp ${FABRIC_CA_SERVER_HOME}/ca-cert.pem ${TARGET_CERTFILE}

# Start the root CA
fabric-ca-server start --db.type mysql --db.datasource "${MYSQL_USER_PASS}@tcp(${MYSQL_HOST}:3306)/fabric_ca?parseTime=true"

# /etc/hyperledger/fabric-ca 目录变化如下
#fabric-ca
#|-- IssuerPublicKey
#|-- IssuerRevocationPublicKey
#|-- ca-cert.pem
#|-- fabric-ca-server-config.yaml
#|-- msp
#|   |-- cacerts
#|   |-- keystore
#|   |   |-- 0574ba70d2e1f40f310de4aae6e55671484cded9cfee11260f95949b3ca3eda6_sk
#|   |   |-- IssuerRevocationPrivateKey
#|   |   |-- IssuerSecretKey
#|   |   `-- b4123e7e17772a11e973680e023902f740091a2900c153f79b93cdbfb3452fab_sk
#|   |-- signcerts
#|   `-- user
#`-- tls-cert.pem
