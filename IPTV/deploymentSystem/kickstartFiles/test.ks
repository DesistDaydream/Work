# This kickstart file should only be used with EL > 5 and/or Fedora > 7.
# For older versions please use the sample.ks kickstart file.

#platform=x86, AMD64, or Intel EM64T
# System authorization information
auth  --useshadow  --enablemd5
# System bootloader configuration
bootloader --location=mbr --append="crashkernel=auto"
# Partition clearing information
clearpart --all --initlabel
# Use text mode install
text
# Firewall configuration
firewall --disabled
# Run the Setup Agent on first boot
firstboot --disable
# System keyboard
keyboard us
# System language
lang en_US
# Use network installation
url --url=$tree
# If any cobbler repo definitions were referenced in the kickstart profile, include them here.
$yum_repo_stanza
# Network information
$SNIPPET('network_config')
# Reboot after installation
reboot

#Root password
rootpw --iscrypted $default_password_crypted
# SELinux configuration
selinux --disabled
# Do not configure the X Window System
skipx
# System timezone
timezone  Asia/Shanghai
# Install OS instead of upgrade
install
# Clear the Master Boot Record
zerombr
# Allow anaconda to partition the system as needed
#autopart
# Disk partitioning information
part /boot --fstype=xfs --asprimary --size=500
part biosboot --fstype=biosboot --asprimary --size=2
part pv.01 --size=1 --grow
volgroup vg0 pv.01
logvol / --fstype xfs --size=10240 --name=root --vgname=vg0
logvol swap --fstype swap --size=1024 --name=swap --vgname=vg0
logvol /var --fstype xfs --size=1 --grow --name=var --vgname=vg0

%packages
@^minimal
@core
kexec-tools
%end

%post
# 注意：正常部署的时候，不要有中文，否则安装失败
# 工作中用到的内容，根据实际情况修改响应的脚本，可以从systemInitialization.sh文件中获取
$SNIPPET('installTools.sh')
$SNIPPET('operations.sh')
%end