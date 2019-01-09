#!/usr/bin/env bash

docker ps -a|grep 'blockchain-explorer*'  | awk '{print $1}'|xargs docker stop
docker ps -a|grep 'blockchain-explorer*'  | awk '{print $1}'|xargs docker rm