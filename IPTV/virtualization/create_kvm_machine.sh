#!/bin/bash
# set -x
export ImagesDir="/var/lib/libvirt/images/" # 镜像存储的位置
export BaseImg="BackingFile/centos7-2003.qcow2"  # 基础镜像的名称
export XmlsDir="/etc/libvirt/qemu/"  # xml 文件的位置
export BaseXml="centos7-2003.xml"   # 基础 xml 的名称  
export VMCpu=2 # cpu 默认为2核
export VMMem=4194304 # 内存默认为4G
export VMAddDisk # 要添加的磁盘空间
export Bridge

# 检查基础镜像和xml是否存
function Check(){
    if [[ ! -f "${XmlsDir}${BaseXml}" ]] || [[ ! -f "${ImagesDir}${BaseImg}" ]]; then
        echo "基础镜像或者基础镜像xml不存在"
        exit 1
    fi 	
}

# 检查虚拟机IP格式是否正确
function Check_vmip(){
    echo "${VMIP}" | egrep '^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$' > /dev/null
    if [[ `echo $?` != "0"  ]]; then
        echo "输入正确的ip格式"
        read  -p "输入想要创建的IP:" VMIP && Check_vmip
    fi
}

# 检查虚拟机名称
function Check_matchname(){
    if [ ! -n "${VMName}" ]; then
       echo "主机名不能为空"
       read  -t 120 -p "输入想要创建的机器名称:" VMName && Check_matchname
    fi
}

# 创建磁盘
function Create_disk(){
    chattr -i  ${ImagesDir}${BaseImg}
    qemu-img create -f qcow2 -b ${ImagesDir}$BaseImg ${ImagesDir}${VMName}.qcow2 &>/dev/null

    if [[ -n "${VMAddDisk}" ]]; then
        qemu-img resize ${ImagesDir}${VMName}.qcow2 +${VMAddDisk}G
    fi
}

# 配置 VM 信息 ，替换内存 cpu 等信息并导入
function Conf_vm_info(){
    cp  ${XmlsDir}${BaseXml}  /tmp/${VMName}.xml
    # 替换内存
    sed -i -r "s@(<memory unit='KiB'>).*(</memory>)@\1${VMMem}\2@"  /tmp/${VMName}.xml 
    sed -i -r "s@(<currentMemory unit='KiB'>).*(</currentMemory>)@\1${VMMem}\2@"   /tmp/${VMName}.xml 
    # 替换 CPU
    sed -i -r "s@(<vcpu placement='static'>).*(</vcpu>)@\1${VMCpu}\2@" /tmp/${VMName}.xml
    # 替换名字
    sed -i "s/centos7-2003/${VMName}/g" /tmp/${VMName}.xml
    # 替换桥设备
    if [[ -n "${Bridge}" ]]; then
        sed -i -r "s@(source bridge=)'br1'@\1'${Bridge}'@" /tmp/${VMName}.xml        
    fi
    # 替换 ip
    virt-edit -d ${VMName} /etc/sysconfig/network-scripts/ifcfg-eth0 -e "s#IPADDR=".*"#IPADDR="${VMIP}"#"  
}

# 创建 VM
function Start_vir(){
    virsh define /tmp/${VMName}.xml >/dev/null
    virsh desc ${VMName} --config ${VMIP}
    virsh start ${VMName} >/dev/null
    # virsh autostart ${VMName} >/dev/null
}

function Init_vm_info(){
    read -p "输入想要创建的IP:" VMIP && Check_vmip
    read -p "输入想要创建的机器名称:" VMName && Check_matchname

    while [[ ${Number} != "custom" ]] && ([[ ${changeOtherInfo} != "yes" ]] || [[ ${changeOtherInfo} != "no" ]]); do
        read -p "是否要修改桥信息以及磁盘信息?(默认500G、br1)(yes或no(default))" changeOtherInfo
        changeOtherInfo=${changeOtherInfo:="no"}

        if [[ ${changeOtherInfo} == "yes" ]]; then
            read -p "指定要修改的桥设备名称，若不指定则不修改:" Bridge
            read -p "指定要增加的磁盘空间，基础空间500G": VMAddDisk
            break
        elif [[ ${changeOtherInfo} == "no" ]]; then
            break
        fi
    done

    if [[ ${Number} == "custom" ]]; then
        read -p "指定要修改的桥设备名称:" Bridge
        read -p "指定要增加的磁盘空间，基础空间500G": VMAddDisk
        read -p "指定内存(单位是KiB)：" VMMem
        read -p "指定CPU：" VMCpu
    fi
}

main(){
    Check
    echo -e "服务器配置选项:"
    PS3="请输入配置编号(1-3):"
    select Number in "2C_4G_500G" "32C_60G_1T" "8C_16G_500G" "custom"; do
        case "${Number}" in
        "2C_4G_500G")
            Init_vm_info
            Create_disk
            Conf_vm_info
            # Start_vir
            ;;
        "32C_60G_1T")
            Init_vm_info
            VMCpu=32
            VMMem=62914560
            VMAddDisk=500
            Create_disk
            Conf_vm_info
            # Start_vir
            ;;
        "8C_16G_500G")
            Init_vm_info
            VMCpu=8
            VMMem=16777216
            Create_disk
            Conf_vm_info
            # Start_vir
            ;;
        "custom")
            Init_vm_info
            Create_disk
            Conf_vm_info
            # Start_vir
            ;;            
        *) 
            echo "请使用菜单栏中的编号"
            ;;
        esac
    done
}

main