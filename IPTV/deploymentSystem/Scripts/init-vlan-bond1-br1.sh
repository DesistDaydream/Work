################## VLAN init ###########################################
for VlanID in 80 81 82 83 84 85 86 87 2300;do
	cat > /etc/sysconfig/network-scripts/ifcfg-bond1.$VlanID <<END
BONDING_OPTS="mode=2 miimon=100 xmit_hash_policy=layer3+4"
TYPE=Bond
BONDING_MASTER=yes
DEVICE=bond1.$VlanID
ONBOOT=yes
BRIDGE=br1.$VlanID
BOOTPROTO=static
USERCTL=no
VLAN=yes
END
	cat > /etc/sysconfig/network-scripts/ifcfg-br1.$VlanID << END
TYPE=Bridge
DEVICE=br1.$VlanID
ONBOOT=yes
BOOTPROTO=static
USERCTL=no
END
done
########################################################################