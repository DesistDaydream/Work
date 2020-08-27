# 目录及文件简要说明  
1. 使用如下命令写明是何人进行系统初始化的  
cat <<EOF > /root/install.log  
#install 2019.5.23 lichenhao  
#verify TIME NAME  
EOF  

multipath.conf	#该文件放在/etc/目录下，“多路径”所用配置  

## whitelist 白名单程序说明
1. release-1.0 为最初版本，各个CDN作为子命令存在  
2. release-2.0 合并子命令，已flag形式区分CDN，但是还没有完善的可以在不清空ipset规则的情况下更新ip