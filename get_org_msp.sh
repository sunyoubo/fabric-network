#!/usr/bin/env bash

source ./scripts/utils.sh

ORG=org2
CA_ADMIN_NAME=ica-${ORG}-admin
CA_ADMIN_PASS=adminpw

ENV_ORG_ADMIN_NAME=${ORG}-admin   # 组织管理员名称
ENV_ORG_ADMIN_PASS=adminpw        # 组织管理员密码
ENV_CA_ADDRESS=ica-${ORG}.example.com:7054  # 组织服务CA地址
ENV_ORG_MSP_DIR=/data/orgs/${ORG}/msp     # 组织msp路径
ENV_CA_ADMIN_ENROLLMENT_URL=https://${CA_ADMIN_NAME}:${CA_ADMIN_PASS}@${ENV_CA_ADDRESS}  # CA 引导用户配置
ENV_ORG_ADMIN_ENROLLMENT_URL=https://${ENV_ORG_ADMIN_NAME}:${ENV_ORG_ADMIN_PASS}@${ENV_CA_ADDRESS}  # 固定值
ENV_CA_CHAINFILE=/data/${ORG}-ca-chain.pem  # 组织根证书
ENV_CA_CLIENT_HOME=/etc/hyperledger/orderer # ca客户端home, peer节点为：/opt/gopath/src/github.com/hyperledger/fabric/peer
ENV_ORG_ADMIN_HOME=/data/orgs/${ORG}/admin                # 组织admin home目录
ENV_ORG_ADMIN_CERT=${ENV_ORG_MSP_DIR}/admincerts/cert.pem # 组织msp中admin证书路径

# 检查fabric-cli容器
checkCliContainer docker-compose-ca.yml

docker exec -e "ENV_CA_CLIENT_HOME=${ENV_CA_CLIENT_HOME}" -e "ENV_CA_CHAINFILE=${ENV_CA_CHAINFILE}" \
-e "ENV_CA_ADMIN_ENROLLMENT_URL=${ENV_CA_ADMIN_ENROLLMENT_URL}" -e "ENV_CA_ADDRESS=${ENV_CA_ADDRESS}" \
-e "ENV_ORG_MSP_DIR=${ENV_ORG_MSP_DIR}" -e "ENV_ORG_ADMIN_NAME=${ENV_ORG_ADMIN_NAME}" -e "ENV_ORG_ADMIN_PASS=${ENV_ORG_ADMIN_PASS}" \
-e "ENV_ORG_ADMIN_HOME=${ENV_ORG_ADMIN_HOME}" -e "ENV_ORG_ADMIN_ENROLLMENT_URL=${ENV_ORG_ADMIN_ENROLLMENT_URL}" -e "ENV_ORG_ADMIN_CERT=${ENV_ORG_ADMIN_CERT}"\
fabric-cli ./scripts/gen_org_msp.sh

