#platform=x86, AMD64, or Intel EM64T
# System authorization information
auth  --useshadow  --enablemd5
# Use text mode install
text
# Firewall configuration
firewall --disabled
# SELinux configuration
selinux --disabled
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
# Do not configure the X Window System
skipx
# System timezone
timezone  Asia/Shanghai
# Install OS instead of upgrade
install
# Clear the Master Boot Record
zerombr
# System bootloader configuration
bootloader --location=mbr --append="crashkernel=auto"
# Partition clearing information
clearpart --all --initlabel
# Allow anaconda to partition the system as needed
#autopart
# Disk partitioning information
part /boot --fstype=xfs --asprimary --size=500
part biosboot --fstype=biosboot --asprimary --size=2
part pv.01 --size=1 --grow
volgroup vg0 pv.01
logvol swap --fstype swap --size=1024 --name=swap --vgname=vg0
logvol / --fstype xfs --size=1 --grow --name=root --vgname=vg0

%pre
$SNIPPET('pre_install_network_config')
%end

%packages
@^minimal-environment
@core
kexec-tools
%end

%post
$SNIPPET('installTools_centos8.sh')
$SNIPPET('operations.sh')
%end
