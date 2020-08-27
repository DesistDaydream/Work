#!/bin/bash
#
function install(){
	RELEASE=$(cat /etc/redhat-release | awk '{print $4}' | awk -F. '{print $1}')
	yum upgrade -y
	TOOLS=(bash-completion ipvsadm psmisc tcpdump telnet vim)
	for tool in ${TOOLS[*]}; do
		yum install -y ${tool}
	done
####### install iptables ###########
	if [[ ${RELEASE} == 7 ]]; then
		yum install iptables* -y
		systemctl enable iptables
		systemctl restart iptables
	fi
######### install snmpd #############
	yum install -y net-snmp net-snmp-utils
	sed -i -r "s@^(access  notConfigGroup \"\"      any       noauth    exact  systemview none none)@#\1@" /etc/snmp/snmpd.conf
	net-snmp-create-v3-user -ro -A nm@tjiptv -X nm@tjiptv -a SHA -x AES nm
	systemctl restart snmpd
	systemctl enable snmpd
######### install ntp   #############
	yum install -y chrony
	case ${RELEASE} in
	"7")		
		sed -i 's/^server 0.centos.pool.ntp.org iburst/server 182.92.12.11 iburst/' /etc/chrony.conf
		sed -i '/centos.pool.ntp.org/d' /etc/chrony.conf
		;;
	"8")
		sed -i 's/^pool 2.centos.pool.ntp.org iburst/server 182.92.12.11 iburst/' /etc/chrony.conf
		;;
	esac
	systemctl restart chronyd && systemctl enable chronyd
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

function development(){
########## setup  user and group ################
	groupadd -g 500 developers
	useradd -g developers -u 500 yanfa
	echo yf@tjiptv | passwd --stdin yanfa
########## setup permission #####################
	setfacl -R -d -m g:developers:rwx /usr/local
	setfacl -R  -m g:developers:rwx /usr/local
########## umask ##################################
	cat > /etc/profile.d/for_developers.sh <<END
if [ "\`id -gn\`" = "developers" ];then
    umask 002
fi
	alias rm='rm -i'
	alias cp='cp -i'
	alias mv='mv -i'
END
########## set ulimit ######################################################################
	cat > /etc/security/limits.d/developers.conf <<END
@developers  soft  nofile  524288
@developers  hard  nofile  524288
END
}

function operations(){
	chmod +x /etc/rc.d/rc.local
	sed -i 's/SELINUX=.*/SELINUX=disabled/' /etc/selinux/config
	sed -i 's/^#UseDNS.*/UseDNS no/' /etc/ssh/sshd_config
	cat > /etc/sysctl.d/ope-sysctl.conf <<END
net.core.somaxconn = 65535
net.ipv4.tcp_max_syn_backlog = 65536
net.ipv4.tcp_fin_timeout = 5
net.ipv4.tcp_tw_reuse = 1
net.ipv4.ip_local_port_range = 10000 65000
vm.swappiness = 10
END
	sysctl -p /etc/sysctl.d/* > /dev/null

########## set iptables track ###############################################################
	cat > /etc/modprobe.d/nf_conntrac.conf <<END
options nf_conntrack hashsize=16384
END

########## add DNS  #########################################################################
	cat > /etc/resolv.conf <<END
nameserver 223.5.5.5
END
}

function virtualization(){
	yum group install -y 'Virtualization Host'
	ln -sv /usr/libexec/qemu-kvm /usr/local/bin/
	yum install -y xorg-x11-xauth xorg-x11-server-utils virt-manager qemu-img virt-install
	systemctl start libvirtd ksm ksmtuned && systemctl enable libvirtd ksm ksmtuned
	virsh net-destroy default
	virsh net-undefine default
	systemctl restart libvirtd
}

function Confirm(){
	read -p "将要进行 ${OPTION} 操作，请确认(yes|no):" Confirm
	while [ "${Confirm}" != "yes" ]; do
	    if [ "${Confirm}" == "no" ]; then
	    	exit 0;
	    else
			Confirm
	    fi
	done
}

function main(){
	PS3="Please give me num [0-6]:"
	OPTIONS=("Install Tools" "Config Unit" "Init Development Config" "Init Operations Config" "Install Virtualization" "Exit")
	select OPTION in "${OPTIONS[@]}";do
		case ${OPTION} in
		"${OPTIONS[0]}")
			Confirm
			install
			;;
		"${OPTIONS[1]}")
			Confirm
			unit
			;;
		"${OPTIONS[2]}")
			Confirm
			development
			;;
		"${OPTIONS[3]}")
			Confirm
			operations
			;;
		"${OPTIONS[4]}")
			Confirm
			virtualization
			;;
		"${OPTIONS[5]}")
			echo "Program Exited, goodbye!^_^";
			exit 0
			;;
		*)
			echo "Unrecognized Number，Please use [0-5]"
			;;
		esac
	done
}

main
