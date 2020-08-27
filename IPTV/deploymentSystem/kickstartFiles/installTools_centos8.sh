yum install -y bash-completion ipvsadm lrzsz net-tools psmisc telnet tcpdump vim
yum install -y net-snmp net-snmp-utils
sed -i  "s/access  notConfigGroup \"\"      any       noauth    exact  systemview none none/#access  notConfigGroup \"\"      any       noauth    exact  systemview none none/" /etc/snmp/snmpd.conf
net-snmp-create-v3-user -ro -A nm@tjiptv -X nm@tjiptv -a SHA -x AES nm
systemctl restart snmpd
systemctl enable snmpd
yum install -y chrony
sed -i 's/^pool 2.centos.pool.ntp.org iburst/server 182.92.12.11 iburst/g' /etc/chrony.conf
systemctl restart chronyd && systemctl enable chronyd