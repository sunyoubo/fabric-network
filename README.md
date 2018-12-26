
## Hyperledger Fabric 轻量级生产环境部署
### 概述
生产环境中，orderer为一个独立的组织维护，每一个独立组织维护各种的peer节点。所有组织均为独立服务器部署。每一个组织中均有自己独立的root CA和中间CA，
中间CA为组织中的所有成员签发证书。

### 启动网络
前提：
参与初始化网络的所有组织均需要先启动各自的CA服务（root CA和中间CA）,由中间CA签发组织的根证书。所有组织的根证书发送到orderer节点，orderer节点
利用configtxgen工具和configtx.yaml配置文件生成orderer.genesis.block。

生成组织msp（注意修改脚本变量配置）：
所有组织，均需要事先生成组织msp,orderer节点集合所有的组织msp后利用configtx.yaml配置生成orderer.genesis.block，
组织和内部节点msp可以在不同目录。


组织启动CA（注意修改脚本变量配置和docker-compose-ca.yml配置）：
```
./start_ca.sh ordererorg example.com
```
或
```
./start_ca.sh org1 example.com
```
或
```
./start_ca.sh org2 example.com
```

开放data目录权限：
```
sudo chmod -R 777 ./data 
```

根据组织配置，生成组织MSP（注意修改脚本变量配置）:
```
./get_org_msp.sh
```
各组织生成组织MSP后，均发送到orderer节点，orderer根据./data/configtx.yaml中的配置存放各组织MSP,并根据该文件配置生成genesis.block。

1.orderer节点启动(收集各组织MSP并生成genesis.block，启动orderer)
```
./start_orderer.sh
```

2.peer节点启动
```
./start_peer.sh org1 example.com
```
或
```
./start_peer.sh org2 example.com
```
### 创建通道
orderer节点（拥有所有组织的msp和configtx.yaml）生成系统通道配置区块（genesis.block）并创建应用通道配置文件（channel.tx），
同时需要为每个组织的peer创建锚节点更新配置文件（anchors.tx）。所有的peer节点join channel,使用组织管理员更新对应组织的锚节点配置。
orderer 共享channel.tx文件到channel业务发起peer组织，并由该peer组织创建应用通道，各peer组织创建或获取应用通道区块（channel_name.block）
用来join到该应用通道中。同时orderer共享各组织对应的锚节点更新配置文件到对应的peer组织，以便对应的peer组织中的锚节点可以更新锚节点通道配置。

- orderer节点创建通道材料（注意修改脚本变量配置）

```
./prepare_channel.sh
```

- 业务发起组织创建应用通道或其他组织更新锚节点配置（注意修改脚本变量配置）

各组织管理员操作
```
./do_new_channel.sh
```

### 部署合约
所有的peer节点安装chaincode,选择一个peer节点实例化chaincode或升级chaincode。
- 部署或升级合约（注意修改脚本变量配置）

各组织管理员操作(注意各组织修改对应参数)
``` 
./deploy_cc.sh
```



