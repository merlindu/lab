#!/usr/bin/env python
#coding=utf-8
import icatch_funcs
import commands
import os
import time

def dailer():
	isp = icatch_funcs.isp_select()
	if isp == "no 3gdongle available":
		return "no 3gdongle available"
	cmd = 'find /dev/ -name "ttyUSB*"'
	ret = commands.getoutput(cmd)
	if ret == '':
		os.system("eject /dev/sr0")
		i = 1
		while i < 20:
			time.sleep(1)
			print i
			i += 1	
	cmd1 = 'pppd call %s-dailer &' %(isp)
	os.system(cmd1)
	time.sleep(8)
	ret1 =icatch_funcs.find_ppp0()
	if ret1 == "":
		os.system("pkill pppd")
		return "dailer fail"
	else:	
		icatch_funcs.network_info1()
		lanname=icatch_funcs.network_info2()
		print "lanname=",lanname
		if lanname == "wlan0":
			wan_old = "eth0"
		else:
			wan_old = "wlan0"
		cmd2 = "sed -i 's/%s/ppp/g' /etc/config/firewall" %(wan_old)
		os.system(cmd2)
		icatch_funcs.restart_firewall()	
		icatch_funcs.ip_nat('ppp0',lanname)
		return "dailer success"

if __name__=='__main__':
	print "start dailer"
	dailer()	
