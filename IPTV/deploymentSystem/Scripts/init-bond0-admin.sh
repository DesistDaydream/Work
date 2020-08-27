#!/bin/bash
#
net_conf_dir=/etc/sysconfig/network-scripts
bond0_file=ifcfg-bond0
source ./init-bonding.conf

set | grep "`cat ./init-bonding.conf | awk -F "=" '{print $1}'`"

echo -n 'Please print "yes" to continue or "no" to cancel: '
read AGREE
while [ "${AGREE}" != "yes" ]; do
    if [ "${AGREE}" == "no" ]; then
        exit 0;
    else
        echo -n 'Please print "yes" to continue or "no" to cancel: '
        read AGREE
    fi
done

# load bonding module
cat > /etc/modprobe.d/bonding.conf << EOF
alias bond0 bonding
EOF

modprobe bonding

# config interface 
cp $net_conf_dir/ifcfg-* /tmp

cat > $net_conf_dir/$bond0_file << EOF
BONDING_OPTS="mode=balance-xor miimon=100 xmit_hash_policy=layer3+4"
TYPE=Bond
DEVICE=bond0
IPADDR=${IPADDR}
NETMASK=${NETMASK}
GATEWAY=${GATEWAY}
ONBOOT=yes
BOOTPROTO=none
USERCTL=no
EOF
 
cat > $net_conf_dir/ifcfg-${DEVICE1} << EOF
DEVICE=${DEVICE1} 
ONBOOT=yes
MASTER=bond0
SLAVE=yes
BOOTPROTO=none
USERCTL=no
EOF

cp $net_conf_dir/ifcfg-${DEVICE1} $net_conf_dir/ifcfg-${DEVICE2}
sed -i "s/\(DEVICE=\)${DEVICE1}/\1${DEVICE2}/" $net_conf_dir/ifcfg-${DEVICE2}

# reboot network server 
systemctl restart network
