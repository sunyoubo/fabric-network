#!/usr/bin/env bash

# log a message
function baseLog {
   if [[ "$1" = "-n" ]]; then
      shift
      echo -n "##### `date '+%Y-%m-%d %H:%M:%S'` $*"
   else
      echo "##### `date '+%Y-%m-%d %H:%M:%S'` $*"
   fi
}

# log a message
function log {
   baseLog "INFO: $*"
}

# Warning a message
function warning {
   baseLog "WARNING: $*"
}

# fatal a message
function fatal {
   baseLog "FATAL: $*"
   exit 1
}

# Ask user for confirmation to proceed
function askProceed() {
  read -p "Continue? [Y/n] " ans
  case "$ans" in
  y | Y | "")
    echo "proceeding ..."
    ;;
  n | N)
    echo "exiting..."
    exit 1
    ;;
  *)
    echo "invalid response"
    askProceed
    ;;
  esac
}

function clear_old_env() {

    log "Check existing docker containers "

    # Delete docker containers
    dockerContainers=$(docker ps -a | awk 'NR == 1 {next} {print $1}')
    if [[ "$dockerContainers" != "" ]]; then
       log "Remove docker containers as follows" `docker ps -a | awk 'NR == 1 {next} {print $1}'`
       askProceed
       docker rm -f ${dockerContainers} > /dev/null
       log "Delete all docker containers done"
    fi

    # Remove chaincode docker images
    chaincodeImages=`docker images | grep "^dev-peer" | awk 'NR == 1 {next} {print $3}'`
    if [[ "$chaincodeImages" != "" ]]; then
       log "Remove chaincode docker images as follows" `docker images | grep "^dev-peer" | awk 'NR == 1 {next} {print $3}'`
       askProceed
       docker rmi -f ${chaincodeImages} > /dev/null
       log "Delete chain code docker containers done"
    fi
}

# Create the TLS directories of the MSP folder if they don't exist.
# The fabric-ca-client should do this.
function fillTLSForMSP {

   if [[ $# -ne 1 ]]; then
      fatal "Usage: fillTLSForMSP <targetMSPDIR>"
   fi

   if [[ ! -d $1/tlscacerts ]]; then
      mkdir $1/tlscacerts
      cp $1/cacerts/* $1/tlscacerts
      if [[ -d $1/intermediatecerts ]]; then
         mkdir $1/tlsintermediatecerts
         cp $1/intermediatecerts/* $1/tlsintermediatecerts
      fi
   fi
}

function fillAdminCertForMSP {

   if [[ $# -ne 1 ]]; then
      fatal "Usage: copyAdminCert <target MSP_DIR>"
   fi

   MSP_DIR=$1
   dstDir=${MSP_DIR}/admincerts
   mkdir -p ${dstDir}
   cp ${ORG_ADMIN_CERT} ${dstDir}   # ORG_ADMIN_CERT来源环境变量
}

function genClientTLSCert {

   if [[ $# -ne 4 ]]; then
      fatal "Usage: genClientTLSCert <host name> <cert file> <key file>: $*"
   fi

   HOST_NAME=$1
   CERT_FILE=$2
   KEY_FILE=$3
   ENROLLMENT_URL=$4

   # Get a client cert
   fabric-ca-client enroll -d --enrollment.profile tls -u ${ENROLLMENT_URL} -M /tmp/tls --csr.hosts ${HOST_NAME}

   if [[ ! -d /data/tls ]]; then
      mkdir /data/tls
   fi
   cp /tmp/tls/signcerts/* ${CERT_FILE}
   cp /tmp/tls/keystore/* ${KEY_FILE}
   rm -rf /tmp/tls
}

function getOrgAdminMSP() {

    if [[ $# -ne 3 ]]; then
       fatal "Usage: $FUNCNAME, ADMIN_MSP_DIR CA_CHAINFILE ADMIN_ENROLLMENT_URL Receive args:$*"
    fi

    ADMIN_MSP_DIR=$1
    CA_CHAINFILE=$2
    ADMIN_ENROLLMENT_URL=$3

    export FABRIC_CA_CLIENT_HOME=${ADMIN_MSP_DIR}
    export FABRIC_CA_CLIENT_TLS_CERTFILES=${CA_CHAINFILE}

    if [[ ! -d ${ADMIN_MSP_DIR} ]]; then
        fabric-ca-client enroll -d -u ${ADMIN_ENROLLMENT_URL}
        mkdir ${ADMIN_MSP_DIR}/msp/admincerts
        cp ${ADMIN_MSP_DIR}/msp/signcerts/* ${ADMIN_MSP_DIR}/msp/admincerts
    fi
    export CORE_PEER_MSPCONFIGPATH=${ADMIN_MSP_DIR}/msp
}

# check cli container exist
function checkCliContainer() {

    COMPOST_FILE=$1

    cliId=`docker ps -a|grep 'fabric-cli'|awk '{print $1}'`
    if [[ -z ${cliId} ]] ; then
        log "Start cli container..."
        docker-compose -f ${COMPOST_FILE} up -d fabric-cli
        sleep 10
    fi

    # install other go packet for chain code
    docker exec fabric-cli go get github.com/pkg/errors
}

function verifyExecuteResult() {

    result=$1
    error_message=$2

    if [[ ${result} -ne 0 ]]; then
        fatal ${error_message}
    fi
}

function checkOS() {

    if grep -Eqi "Ubuntu 16" /etc/issue ; then
        log " Start with" `cat /etc/issue`
    elif grep -Eqi "Ubuntu 18" /etc/issue ; then
        log " Start with" `cat /etc/issue`
    else
        fatal "Only support OS: Ubuntu 16 or Ubuntu 18"
        exit 1
    fi
}

function checkDocker() {

    DOCKER_BIN_PATH=`type docker`
    if [[ "$?" -ne 0 ]] ; then
        log "Start install docker ..."

        apt-get update
        apt-get install -y apt-transport-https ca-certificates curl software-properties-common
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
        add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
        apt-get update
        apt-get install docker-ce
        verifyExecuteResult $? "Failed to install docker-ce"

        docker run hello-world
    else
        log "Docker has been installed "
    fi
}

function checkDockerCompose() {

    DOCKER_COMPOSE_BIN_PATH=`type docker-compose`
    if [[ "$?" -ne 0 ]] ; then
        log "Start install docker-compose ..."

        wget https://github.com/docker/compose/releases/download/1.20.1/docker-compose-Linux-x86_64
        chmod +x docker-compose-Linux-x86_64
        sudo mv docker-compose-Linux-x86_64 /usr/local/bin/docker-compose
        docker-compose --version

        verifyExecuteResult $? "Failed to install docker-compose"
    else
        log "docker-compose has been installed "
    fi
}