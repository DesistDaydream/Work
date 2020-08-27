#!/bin/bash
#
export DevName
export IP="10.10.100.249/24"
export GW="10.10.100.254"
export DNS="223.5.5.5"
export Bond0SlaveDev=(ens3 ens10)
export Bond1SlaveDev=(ens11 ens12)
export VLANID=(2300 80 81 82)
# export DEV=`nmcli --fields DEVICE device status | egrep "^ens*|^eth*|^em*"`
export OPTIONS="mode=balance-xor,miimon=100,xmit_hash_policy=layer3+4"
# export OPTIONS="mode=active-backup"

function CheckDev(){
	nmcli connection show | grep ${DevName} > /dev/null
	if [[ $? == 0 ]];then
		echo "error:${DevName}已存在" && exit ;
	fi
}

function CreateBond(){
	nmcli connection add type bond con-name ${DevName} ifname ${DevName} \
	ipv4.method "${METHOD}" ipv4.addresses "${IP}" ipv4.gateway "${GW}" ipv4.dns "${DNS}" \
	ipv6.method disabled \
	bond.options "${OPTIONS}"

	DEV=(${1})
	for i in ${DEV[*]};do
		nmcli connection add type ethernet ifname ${i} master ${DevName}
	done
}

function UpBond(){
	DEV=(${1})
	for i in ${DEV[*]};do
		nmcli con up bond-slave-${i}
	done
}

function AddBond0(){
	METHOD="manual"

	CheckDev
	CreateBond "${Bond0SlaveDev[*]}"
	UpBond "${Bond0SlaveDev[*]}"
}

function AddBond1(){
	METHOD="disabled"
	unset IP GW DNS

	CheckDev
	CreateBond "${Bond1SlaveDev[*]}"
	UpBond "${Bond1SlaveDev[*]}"
}

function AddBridge(){
	CheckDev
	for i in ${VLANID[*]};do 
		nmcli con add type bridge con-name br1.${i} ifname br1.${i} \
		ipv4.method disabled \
		ipv6.method disabled
		nmcli con add type vlan con-name vlan${i} dev bond1 id ${i} master br1.${i}
	done
}

function main(){
	DevName="${1}"
	case ${1} in
	"bond0")
		AddBond0
		;;
	"bond1")
		AddBond1
		;;
	"bridge")
		AddBridge
		;;
	*)
		echo "使用 XX.sh bond0 或者 XX.sh bond1 执行命令" && exit;
	esac	
}

main "${1}"