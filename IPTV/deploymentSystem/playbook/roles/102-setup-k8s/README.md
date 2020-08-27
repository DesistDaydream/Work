# 使用该role时需要修改的内容  
1. defaults目录下的变量值  
   1. MASTER_VIP的值为空时，kubeadm-config.yaml文件内controlPlaneEndpoint的值为当前host的ip；如果不为空则使用MASTER_VIP的值作为controlPlaneEndpoint的值。
      1. Note: master的主机名一定要带有master，如果是高可用集群，则主机名需要带-，即master-，比如master-1。  
2. 注意keepalived.conf.j2模板里INTERFACE_NAME的值，不同主机的网卡名不同
3. 注意keepalived.conf.j2模板里VIRTUAL_ROUTER_ID的值，同网段如果有别的keepalived具有相同的值，则该keepalived服务起不来