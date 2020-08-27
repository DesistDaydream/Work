function virtualization(){
	yum group install -y 'Virtualization Host'	
	ln -sv /usr/libexec/qemu-kvm /usr/bin/
	yum install -y tigervnc tigervnc-server virt-manager qemu-img virt-install
	systemctl start libvirtd ksm ksmtuned && systemctl enable libvirtd ksm ksmtuned
	virsh net-destroy default
	virsh net-undefine default
	systemctl restart libvirtd
}

virtualization
