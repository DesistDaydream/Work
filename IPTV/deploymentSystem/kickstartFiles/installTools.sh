yum install -y bash-completion ipvsadm lrzsz net-tools psmisc telnet tcpdump vim
yum install iptables* -y
systemctl enable iptables
systemctl restart iptables
yum install -y net-snmp net-snmp-utils
sed -i  "s/access  notConfigGroup \"\"      any       noauth    exact  systemview none none/#access  notConfigGroup \"\"      any       noauth    exact  systemview none none/" /etc/snmp/snmpd.conf
net-snmp-create-v3-user -ro -A nm@tjiptv -X nm@tjiptv -a SHA -x AES nm
systemctl restart snmpd
systemctl enable snmpd
yum install -y ntp
ntpdate 182.92.12.11
sed -i '/^'server'/d' /etc/ntp.conf
sed -i '/^# Please consider joining the pool/a\server 182.92.12.11 iburst' /etc/ntp.conf
systemctl restart ntpd && systemctl enable ntpd