sed -i 's/\#UseDNS yes/UseDNS no/' /etc/ssh/sshd_config
cat >>/etc/sysctl.conf <<END
net.core.somaxconn = 65535
net.ipv4.tcp_max_syn_backlog = 65536
net.ipv4.tcp_fin_timeout = 5
net.ipv4.tcp_tw_reuse = 1
net.ipv4.ip_local_port_range = 10000 65000
vm.swappiness = 10
END
sysctl -p > /dev/null
cat >>/etc/modprobe.d/nf_conntrac.conf <<END
options nf_conntrack hashsize=16384
END
cat >>/etc/resolv.conf <<END
nameserver 223.5.5.5
END