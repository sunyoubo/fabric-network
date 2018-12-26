#!/usr/bin/env bash

sleep 30

#fabric-ca-client getcacert -u ${PARENT_URL} -M ${FABRIC_CA_CLIENT_HOME}/msp
#FABRIC_CA_SERVER_INTERMEDIATE_TLS_CERTFILES=""

# Initialize the intermediate CA
fabric-ca-server init -b ${BOOTSTRAP_USER_PASS} -u ${PARENT_URL} --db.type mysql --db.datasource "${MYSQL_USER_PASS}@tcp(${MYSQL_HOST}:3306)/fabric_ca?parseTime=true"

# 产生文件：
#root@426c7198e8c9:/etc/hyperledger# tree -L 4 fabric-ca
#fabric-ca
#|-- IssuerPublicKey
#|-- IssuerRevocationPublicKey
#|-- ca-cert.pem
#|-- ca-chain.pem
#|-- fabric-ca-server-config.yaml
#`-- msp
#    |-- cacerts
#    |-- keystore
#    |   |-- IssuerRevocationPrivateKey
#    |   |-- IssuerSecretKey
#    |   `-- dc67843205245fdb79cd443ebdfb327a1e7af5fa889b62b053d22643af6e365c_sk
#    |-- signcerts
#    `-- user


# Copy the intermediate CA's certificate chain to the data directory to be used by others
cp ${FABRIC_CA_SERVER_HOME}/ca-chain.pem ${TARGET_CHAINFILE}

# Start the intermediate CA
fabric-ca-server start --db.type mysql --db.datasource "${MYSQL_USER_PASS}@tcp(${MYSQL_HOST}:3306)/fabric_ca?parseTime=true"

# 文件变化如下：
#fabric-ca
#|-- IssuerPublicKey
#|-- IssuerRevocationPublicKey
#|-- ca-cert.pem
#|-- ca-chain.pem
#|-- fabric-ca-server-config.yaml
#|-- msp
#|   |-- cacerts
#|   |-- keystore
#|   |   |-- 08160eee1ce519caa6c87d6b6a243395b64224898dd1c9c62d32f33e33ba4198_sk
#|   |   |-- IssuerRevocationPrivateKey
#|   |   |-- IssuerSecretKey
#|   |   `-- dc67843205245fdb79cd443ebdfb327a1e7af5fa889b62b053d22643af6e365c_sk
#|   |-- signcerts
#|   `-- user
#`-- tls-cert.pem
