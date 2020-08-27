#!/bin/bash

# 安装依赖组件
yum -y install epel-release
yum -y install cifs-utils cifs-utils-devel jq util-linux coreutils wget

VOLUME_PLUGIN_DIR="/usr/libexec/kubernetes/kubelet-plugins/volume/exec"

# 创建cifs的插件目录
mkdir -p "$VOLUME_PLUGIN_DIR/fstab~cifs"

# 下载cifs初始化脚本
cd "$VOLUME_PLUGIN_DIR/fstab~cifs"
wget https://raw.githubusercontent.com/fstab/cifs/master/cifs &> /dev/null

# 执行初始化操作
chmod 755 "$VOLUME_PLUGIN_DIR/fstab~cifs/cifs"
sh $VOLUME_PLUGIN_DIR/fstab~cifs/cifs init

#kubectl apply -f cifs-secret.yml
#kubectl apply -f pod.yml
