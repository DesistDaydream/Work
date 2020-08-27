#!/bin/bash 
#
function install(){
	yum upgrade -y
	TOOLS=(telnet net-tools lrzsz tshark vim bash-completion ipvsadm)
	for tool in ${TOOLS[*]}; do
		yum install -y ${tool}
	done
####### install iptables ###########
	yum install iptables* -y
	systemctl enable iptables
	systemctl restart iptables
######### install snmpd #############
	yum install -y net-snmp net-snmp-utils
	sed -i  "s/access  notConfigGroup \"\"      any       noauth    exact  systemview none none/#access  notConfigGroup \"\"      any       noauth    exact  systemview none none/" /etc/snmp/snmpd.conf
	net-snmp-create-v3-user -ro -A nm@tjiptv -X nm@tjiptv -a SHA -x AES nm
	systemctl restart snmpd
	systemctl enable snmpd
######### install ntp   #############
	yum install -y ntp
	ntpdate 182.92.12.11
	sed -i '/^'server'/d' /etc/ntp.conf
	sed -i '/^# Please consider joining the pool/a\server 182.92.12.11 iburst' /etc/ntp.conf
	systemctl restart ntpd
	systemctl enable ntpd
}

function unit(){
	for SYS in `systemctl list-unit-files | grep enable | grep service |awk '{print $1}'`; do
		systemctl disable ${SYS}
	done
	for i in crond.service getty@.service iptables.service irqbalance.service lvm2-monitor.service ntpd.service rsyslog.service snmpd.service sshd.service; do
		systemctl enable ${i} && systemctl start ${i}
	done
	systemctl list-unit-files | grep enable
}

function operations(){
	chmod +x /etc/rc.d/rc.local
	sed -i 's/SELINUX=.*/SELINUX=disabled/' /etc/selinux/config
	sed -i 's/\#UseDNS yes/UseDNS no/' /etc/ssh/sshd_config
###若为centos6则net.core.somaxconn = 65536
	cat >>/etc/sysctl.conf <<END
net.core.somaxconn = 65535
net.ipv4.tcp_max_syn_backlog = 65536
net.ipv4.tcp_fin_timeout = 5
net.ipv4.tcp_tw_reuse = 1
net.ipv4.ip_local_port_range = 10000 65000
vm.swappiness = 10
END
	sysctl -p > /dev/null

########## set iptables track ###############################################################
	cat >>/etc/modprobe.d/iptables.conf <<END
options nf_conntrack hashsize=16384
END

########## add DNS  #########################################################################
	cat >>/etc/resolv.conf <<END
nameserver 223.5.5.5
END
}

install

unit

operations