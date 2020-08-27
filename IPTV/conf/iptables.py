#!/usr/bin/python
f = open('ip.txt')
for each_line in f:
	each_line = each_line.strip()
	print '-A INPUT  -s %s -p tcp -m state --state NEW -m multiport --dports 80,1935,4000,4001 -j ACCEPT' % ( each_line )
f.close()
