#!/bin/bash
#version 1.2
#vizarzhou
function virinfo {
echo "|----------vmname-----------|---CPU---|----mem----|---------ipaddr----------|------hostname------|----------Hipaddr---------|"
for a in `virsh list | grep running |awk '{print $2}'`
do
###############  name lan  ######################################
#echo "$a"
NNum=25
Nnum=`echo "$a" |wc -L`
#echo $Snum
LAN=$[ $NNum - $Nnum ]
#echo $LAN
for (( i=0; i < $LAN ; i++ ))
do
	a=$a" "
done
################   cpu   ########################################
cpu=`virsh dominfo $a|grep CPU\(s\)|awk '{print $2}'`
CNum=5
Cnum=`echo "$cpu" |wc -L`
CLAN=$[ $CNum - $Cnum ]
for (( i=0; i < $CLAN ; i++ ))
do
	cpu=$cpu" "
done
################   IP   ##########################################
IP=`virt-cat -d $a /etc/sysconfig/network-scripts/ifcfg-eth0 | grep -v ^# |grep IPADDR`
INum=24
inum=`echo "$IP" |wc -L`
ILAN=$[ $INum - $inum ]
for (( i=0; i < $ILAN ; i++ ))
do
	IP=$IP" "
done
################  mem   ##########################################
mem=`virsh dommemstat $a|grep actual|awk '{print $2}'`
mem=$[ $mem / 1024 /1024 ]G
MNum=7
mnum=`echo "$mem" |wc -L`
MLAN=$[ $MNum - $mnum ]
for (( i=0; i < $MLAN ; i++ ))
do
	mem=$mem" "
done

################  hostname ########################################
hostname=`hostname`
HNum=20
Hnum=`echo "$hostname"|wc -L`
HLAN=$[ $HNum - $Hnum ]
for (( i=0; i < $HLAN ; i++ ))
do
	hostname=$hostname" "
done
################  hostip   ########################################
HIP=`cat /etc/sysconfig/network-scripts/ifcfg-bond0 | grep -v ^# |grep IPADDR`
HINum=24
hinum=`echo "$HIP" |wc -L`
HILAN=$[ $HINum - $hinum ]
for (( i=0; i < $HILAN ; i++ ))
do
	HIP=$HIP" "
done
echo \|\#\|"$a"\|"   ""$cpu"     \|"    ""$mem"\|"$IP" \|"$hostname"\|"$HIP"\|\#\|
echo "|---------------------------------------------------------------------------------------------------------------------------|"
done
}


function vcpu {
TotalCPU=`lscpu | grep ^CPU\(s\)| awk '{print $2}'`
UseCPU=0
for a in `virsh list | grep running |awk '{print $1}'` 
do 
	cpu=`virsh dominfo $a|grep CPU\(s\)|awk '{print $2}'`
	UseCPU=$[ $UseCPU + $cpu ]
done
echo "    $TotalCPU CPUs is use $UseCPU"
}



function vmem {
Totalmem=`free -g| grep Mem | awk '{print $2}'`
Usemem=0
for a in `virsh list | grep running |awk '{print $1}'`
do
	mem=`virsh dommemstat $a|grep actual|awk '{print $2}'`
	Usemem=$[ $Usemem + $mem ]
done
Usemem=$[ $Usemem / 1024 / 1024 ]
echo "    ""$Totalmem"G mems use "$Usemem"G
}

virinfo

echo "######### total #########"
vcpu
vmem
echo "#########################"
