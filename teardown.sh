#!/usr/bin/env bash

source ./scripts/utils.sh

clear_old_env

# remove all directory and files
warning "remove dir: ./data/logs/*  ./data/orgs/* ./data/tls/* ./data/*.block ./data/*.tx ./data/*.pem "
askProceed

rm -rf ./data/logs/*  ./data/orgs/* ./data/tls/* ./data/*.block ./data/*.tx ./data/*.pem
