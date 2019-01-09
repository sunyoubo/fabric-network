#!/usr/bin/env bash

source ./scripts/utils.sh

ORG=$1
DOMAIN=$2
: ${ORG:="ordererorg"}
: ${DOMAIN:="example.com"}    # 注意和compose文件中的service对应

# check operate system
checkOS

# check docker whether has been installed
checkDocker

# check docker compost whether has been installed
checkDockerCompose

# clear fabric environment
clear_old_env

docker-compose -f docker-compose-ca.yml up -d rca-mysql-${ORG} ica-mysql-${ORG}

sleep 60

docker-compose -f docker-compose-ca.yml up -d rca-${ORG}.${DOMAIN} ica-${ORG}.${DOMAIN}