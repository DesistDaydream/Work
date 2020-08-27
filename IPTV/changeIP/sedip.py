#!/usr/bin/python
def main(text):
    lines = text.splitlines()
    for line in lines:
        ip=line.split()
        ipo=ip[0]
        ipn=ip[1]
        os.system('sed -i \'s/%s/%s/g\' /etc/keepalived/keepalived.conf > /dev/null 2&>1' % (ipo,ipn))
        os.system('sed -i \'s/%s/%s/g\' /etc/sysconfig/iptables > /dev/null 2&>1' % (ipo,ipn))
        os.system('sed -i \'s/%s/%s/g\' /etc/sysconfig/network-scripts/ifcfg-lo:0 > /dev/null 2&>1' % (ipo,ipn))
        os.system('sed -i \'s/%s/%s/g\' /etc/sysconfig/network-scripts/ifcfg-eth0 > /dev/null 2&>1' % (ipo,ipn))
        os.system('sed -i \'s/%s/%s/g\' /etc/sysconfig/network-scripts/ifcfg-em1 > /dev/null 2&>1' % (ipo,ipn))
        os.system('sed -i \'s/%s/%s/g\' /etc/sysconfig/network-scripts/ifcfg-em2 > /dev/null 2&>1' % (ipo,ipn))
        os.system('sed -i \'s/%s/%s/g\' /etc/sysconfig/network-scripts/ifcfg-em3 > /dev/null 2&>1' % (ipo,ipn))
        os.system('sed -i \'s/%s/%s/g\' /etc/sysconfig/network-scripts/ifcfg-em4 > /dev/null 2&>1' % (ipo,ipn))
        os.system('sed -i \'s/%s/%s/g\' /etc/sysconfig/network-scripts/ifcfg-bond0 > /dev/null 2&>1' % (ipo,ipn))
        os.system('sed -i \'s/%s/%s/g\' /etc/sysconfig/network-scripts/ifcfg-bond1 > /dev/null 2&>1' % (ipo,ipn))
if __name__ == '__main__':
    import os
    import sys
    main(open(sys.argv[1]).read())
