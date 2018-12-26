#!/usr/bin/env bash

ORG=$1
DOMAIN=$2
: ${ORG:="org1"}
: ${DOMAIN:="example.com"}

docker-compose -f docker-compose-peer.yml up -d peer0.${ORG}.${DOMAIN} peer1.${ORG}.${DOMAIN}


