#!/usr/bin/env python
#coding=utf-8
#IDS_FILE="ids"
import os, sys, subprocess, re
import commands, time

if __name__ == '__main__':
	print '"%s" is being executed as main program, nothing done.' % sys.argv[0]
	os._exit(0)

#set <config>.<section>[.<option>]=<value>
def uci_get(target):
	p = subprocess.Popen("uci get \"" + target + "\"", shell=True, stdout=subprocess.PIPE)  
	return p.communicate()[0].rstrip()

def uci_set(target,value):
	os.system( "uci set \"" + target + "=" + value + "\"" )
def uci_delete(target):
	os.system( "uci delete \"" + target + "\"" )
def uci_add(target):
	os.system( "uci delete \"" + target + "\"" )
def uci_commit(target):
	os.system( "uci commit \"" + target + "\"" )
def restart_network():
	print "network restart"
	os.system("/etc/init.d/network restart")
	avahi()
def avahi():
	time.sleep(10)
	os.system("avahi-daemon -k")
	os.system("avahi-daemon -D")

def restart_firewall():
	print "firewall restart"
	os.system("/etc/init.d/firewall restart")
def save_info(wans):
	os.system("echo $wans > save_info")
	
def find_mode():
	ret1 = commands.getoutput("uci show wireless.sta.disabled")
	ret2 = commands.getoutput("uci show wireless.ap.disabled")
	if ret1 == "wireless.sta.disabled='1'" and ret2 == "wireless.ap.disabled='0'":
		return "ap"
	if ret1 == "wireless.sta.disabled='0'" and ret2 == "wireless.ap.disabled='1'":
		return "sta"

def ip_nat(wanname,lanname):
	cmd = "ifconfig %s | grep 'inet addr' | awk '{print $2}' | awk -F: '{print $2}'" %(wanname)
	wan_ip = commands.getoutput(cmd)
	print "wan_ip=",wan_ip
	cmd1 = "ifconfig %s | grep 'inet addr' | awk '{print $2}' | awk -F: '{print $2}'" %(lanname)
	lan_ip = commands.getoutput(cmd1)
	print "lan_ip=",lan_ip
	cmd2 = "ifconfig %s | grep 'inet addr' | awk '{print $4}' | awk -F: '{print $2}'" %(lanname)
	lan_mask = commands.getoutput(cmd2)
	print "lan_mask=",lan_mask
	cmd3 = "iptables -t nat -A POSTROUTING -s %s/%s -j SNAT --to-source %s" %(lan_ip,lan_mask,wan_ip)
	os.system(cmd3)
	return
def check_eth0():
		i = 30
		while i > 0:
			cmd = "ifconfig eth0 | grep 'inet addr' | awk '{print $2}' | awk -F: '{print $2}'"
			eth0_ip = commands.getoutput(cmd)
			if eth0_ip == "":
				time.sleep(1)
				print i
				i -= 1
			else:
				time.sleep(1)
				restart_firewall()
				time.sleep(3)
				ip_nat('eth0','wlan0')
				return 
		return "eth0 no ok"
def ubus_call(target,method):
	""" eg: ubus_call( 'network',  'reload') """
	os.system( "ubus call " + target + " " + method )

list_save = "/tmp/wifi/wifi_save"
def save_password(ssid,password):
	cmd = "grep %s %s" %(ssid, list_save)
	ret = commands.getoutput(cmd)
	if ret:
		cmd1 = "sed -i 's/%s.*/%s %s/g' %s" %(ssid,ssid,password,list_save)
		os.system(cmd1)
	else:		
		cmd2 = "echo '%s %s' >> %s" %(ssid,password,list_save)
		os.system(cmd2)
	return 
	
def wifi_check(ssid):
	i=30
	while i > 0:
		time.sleep(1)
		print i
		ret = commands.getoutput("wpa_cli -iwlan0 stat | grep wpa_state=COMPLETED") 
		if ret == 'wpa_state=COMPLETED':
			time.sleep(5)
			restart_firewall()
			return "connect ok"
		else:
			i -= 1
	restart_firewall()
	os.system("wifi down")
	return "timeout"

def wifi_saved(ssid):
	cmd = "grep %s %s" %(ssid,list_save)
	ret = commands.getoutput(cmd)
	if ret != "":
		cmd1 = "%s | awk '{print $2}' " %(cmd)
		return commands.getoutput(cmd1)
	else:
		return 					
def dongle_exist():
	leng = commands.getoutput("lsusb | awk '{print NR}' | tail -n1")
	lengg = int (leng)
	m = 1
	while (m <= lengg):
		cmd = "lsusb | awk '{print $6}' | sed -n '%sp'" %(m)
		id = commands.getoutput(cmd)
		cmd1 = "grep -i %s %s/devices" %(id, sys.path[0] + "/shell_tmp")
		ret = commands.getoutput(cmd1)
		if ret == '':
			m +=1
		else:
			return "have a available 3gdongle, " + ret
	return "no 3gdongle available"
def network_info1():
	cmd = "netstat -nr | grep -i 'UG' | awk '{print $NF}'"
	ret = commands.getoutput(cmd)
	if ret == 'wlan0' or 'eth0':
		return ret
	elif ret == "ppp0":
		return "ppp0"
	elif ret == '':
		return "no"
	else:
		pass
		
def network_info2():
	eu = commands.getoutput("netstat -nr | grep eth0 | awk '{print $4}'")
	wu = commands.getoutput("netstat -nr | grep wlan0 | awk '{print $4}'")
	if eu == "U" and wu != "U":
		return "eth0"
	elif eu != "U" and wu == "U":
		return "wlan0"
	else:
		ret = network_info1()
		if ret == "eth0":
			return "wlan0"
		elif ret == "wlan0":
			return "eth0"
		else:
			return "no"
def check_inter():
	os.system("ping 61.135.169.105 -c 1 | grep 'time' > incheck")
	ret = commands.getoutput("cat incheck")	
	print ret
	if ret:
		return "network ok"
	else:
		return "network fail"
	
def set_wireless_sta(ssid,encry,password):
	uci_set( 'wireless.sta', 'wifi-iface')
	uci_set( 'wireless.sta.device', 'radio0')
	uci_set( 'wireless.sta.network', 'wlan')
	uci_set( 'wireless.sta.mode', 'sta')
	uci_set( 'wireless.sta.ssid', ssid )
	uci_set( 'wireless.sta.encryption', encry )
	uci_set( 'wireless.sta.key', password )
	uci_set( 'wireless.sta.disabled', '1' )
	uci_commit('wireless')

def set_wireless_ap(ssid,encry,password):
	uci_set( 'wireless.ap', 'wifi-iface')
	uci_set( 'wireless.ap.device', 'radio0')
	uci_set( 'wireless.ap.network', 'wlan')
	uci_set( 'wireless.ap.mode', 'ap')
	uci_set( 'wireless.ap.ssid', ssid )
	uci_set( 'wireless.ap.encryption', encry )
	uci_set( 'wireless.ap.key', password )
	uci_set( 'wireless.ap.disabled', '1' )
	uci_commit('wireless')

def set_wifi_mode( mode ):
	if( mode == 'sta' or mode == 'STA' or mode == 'station' or mode == 'Station' ):
		uci_set( 'wireless.sta.disabled', '0' )
		uci_set( 'wireless.ap.disabled', '1' )
		uci_set( 'network.wlan.proto', 'dhcp' )
		uci_set( 'network.wan.proto', 'static' )
		uci_commit('network')
		uci_commit('wireless')
	elif( mode == 'ap' or mode == 'AP' or mode == 'Ap' or mode == 'aP' ):
		uci_set( 'wireless.ap.disabled', '0' )
		uci_set( 'wireless.sta.disabled', '1' )
		uci_set( 'wireless.ap.disabled', '0' )
		uci_set( 'network.wlan.proto', 'static' )
		uci_set( 'network.wan.proto', 'dhcp' )
		uci_commit('network')	
		uci_commit('wireless')
	else:
		pass

config_ntw="/etc/config/network"
def get_iface_name():
	ifnames = []
	try:
		f = open ( config_ntw )
		while True:
			line = f.readline()
			if not line:
				break
			m = re.match("^config.+interface.*",line)
			if m is not None:
				try:
					ifname = re.split( r'\s+', line.strip() )[2]
				except IndexError:
					ifname = "unnamed"
				ifnames.append(  ifname.strip('\'').strip('\"')  )
		f.close()
	except IOError:
		print "python error: read network config file failed!"
		pass
	return ifnames

config_wls="/etc/config/wireless"
def get_wireless_wifi_device_section():
	wifi_ifaces =[]
	try:
		f = open ( config_wls )
		while True:
			line = f.readline()
			if not line:
				break
			m = re.match("^config.+wifi-iface.*",line)
			if m is not None:
				try:
					wifi_iface = re.split( r'\s+', line.strip() )[2]
				except IndexError:
					wifi_iface = "unnamed"
				wifi_ifaces.append(  wifi_iface.strip('\'').strip('\"')  )
		f.close()
	except IOError:
		print "python error: read wireless config file failed!"
		pass
	return wifi_ifaces

def checkpassword( user_id, password_hash ):
#return value:
#	-1 : not found user_id
#	 0 : check password failed
#    1 : check password ok
#	try:
#		f = open ( IDS_FILE )
#		while True:  
#			line = f.readline().strip('\n') 
#			if line:
#				if line.split(':')[0] == user_id:
#					if password_hash == md5cal( line.split(':')[1] ):
#						return 1
#					else:
#						return 0
#			else:
#				break
#		f.close()
#	except IOError:
#		print "python error: read ID file failed!"
#		return -1
	username = uci_get('httpstation.@httpstation[0].username')
	password = uci_get('httpstation.@httpstation[0].password')
	if(username == "" or password == ""):
		return 1
	if(username == user_id and md5cal(password) == password_hash):
		return 1
	return 0	

		
def changepassword( id, password ):
#	f = open ( IDS_FILE )
#	pattern = '^.*' + id + ':.*'
#	new = id + ':' + password
#	os.system( 'sed -i "s/' + pattern + '/' + new +  '/" ' + IDS_FILE )
	uci_set('httpstation.@httpstation[0].username', id)
	uci_set('httpstation.@httpstation[0].password', password)
	uci_commit('httpstation')

def md5cal(str):
	import hashlib
	m = hashlib.md5()
	m.update(str)
	return m.hexdigest()
		
def wifi_scan():
	#file_in_disk='/home/merlin/ming.du/webframework/bottle/icalou/base/wifilist'
	file_in_disk='/home/merlin/ming.du/webframework/bottle/icalou/base/iwinfo_wlan0_scan'
	if( os.path.exists( file_in_disk ) ):
		f = open ( file_in_disk )
		content_of_file = f.read()
	else:
		p = subprocess.Popen("iwinfo wlan0 scan", shell=True, stdout=subprocess.PIPE)
		content_of_file = p.communicate()[0]

	i = 0
	ret=[]

	for block in re.split( r'\s*Cell.+Address: ', content_of_file ):
		"""
		a block like blow
		Cell 01 - Address: 9C:65:F9:1C:17:34
		          ESSID: "ICALOU1C1734"
		          Mode: Master  Channel: 2
		          Signal: -45 dBm  Quality: 65/70
		          Encryption: WPA2 PSK (CCMP)
		"""
		lines = block.split('\n')
		flag = 0
		m = re.match( '([0-9A-F]{1,2}:){5}[0-9A-F]{1,2}', lines[0] )
		if m is not None:
			bssid = lines[0]
			ele=[]
			for line in lines:
				try:
					mode=re.split( r'Mode:', line.strip() )[1].strip('\'').strip('\"')
					flag = 1
				except IndexError:
					pass

				try:
					essid=re.split( r'ESSID:', line.strip() )[1].strip(' ').strip('\'').strip('\"')
					ele.append( essid )
					flag = 1
				except IndexError:
					pass
				try:
					key_on_off =  re.split( r'Encryption:', line.strip() )[1].strip(' ').strip('\'').strip('\"')
					ele.append( key_on_off=='none' and 'none' or 'psk2')
					flag = 1
				except IndexError:
					pass

				try:
					import string
					qual =  re.split( r'\s*Signal:.+Quality: ', line.strip() )[1].strip('\'').strip('\"')
					qual = str( int( string.atof( qual.split('/')[0] ) / string.atof( qual.split('/')[1] )*100 ) )
					ele.append( qual )
					flag = 1
				except IndexError:
					pass

			if( flag == 1 ):
				ret.append( ele )
				flag = 0

	return ret


def get_wan_info():
	wanname = network_info1()
	if wanname == '':
		wanname = "no"
	cmd = "ifconfig | grep -i %s -A 1 | tail -n 1" %(wanname)
	ret = commands.getoutput(cmd)
	return ret
def get_lan_info():
	lanname = network_info2()
	print "lanname"
	print lanname
	if lanname == 'eth0':
		cmd = "ifconfig | grep -i eth0 -A 1 | tail -n 1"
		ret = commands.getoutput(cmd)
		return ret
	if lanname == 'wlan0':
		cmd = "ifconfig | grep -i wlan0 -A 1 | tail -n 1" 
		ret1 = commands.getoutput(cmd)
		return ret1
	else: 
		pass
def dailer():
	isp = isp_select()
	if isp == "no 3gdongle available":
		return "no 3gdongle available"
	cmd = 'find /dev/ -name "ttyUSB*"'
	ret = commands.getoutput(cmd)
	if ret == "":
		os.system("eject /dev/sr0")
		i = 1
		while i < 20:
			time.sleep(1)
			i += 1
			print i
	cmd1 = 'pppd call %s-dailer &' %(isp)
	os.system(cmd1)
	ret1 = find_ppp0()
	if ret1 == "":
		return "dailer fail"
	else:
		return 'dailer success'
def isp_select():
	ret1 = dongle_exist()
	if ret1 == "no 3gdongle available":
		return "no 3gdongle available"
	cmd = "echo '%s' | awk '{print $NF}'" %(ret1)
	print cmd
	ret = commands.getoutput(cmd)	
	return ret   

def find_ppp0():
	cmd = 'ifconfig | grep ppp0'
	ret = commands.getoutput(cmd)
	return ret

def get_net_info():
	ele=[]
	ret=[]
	file_in_disk='/home/merlin/ming.du/webframework/bottle/icalou/base/ifconfig'
	if( os.path.exists( file_in_disk ) ):
		f = open ( file_in_disk )
		content_of_file = f.read()
	else:
		p = subprocess.Popen("ifconfig", shell=True, stdout=subprocess.PIPE)
		content_of_file = p.communicate()[0]

	lines =  content_of_file.split('\n')
	length =  len(lines)
	i = 0
	while( i < length ):
		m = re.match( '.+\s+Link encap:.+', lines[i] )
		if m is not None:
			j = i
			i += 1
			
			while i < length:
				m = re.match( '.+\s+Link encap:.+', lines[i] )
				if m is not None:
					break
				else:
					k = i
					i += 1
					m = re.match( '.*inet addr:.*Bcast:.*Mask:', lines[k] )
					if m is not None:
						firstline = re.split( r'\s+', lines[j].strip(' ') )
						ifname = firstline[0].strip(' ')
						hwaddr = firstline[-1].strip(' ')

						line = lines[k].split(":")
						ipaddr =  line[1].split(" ")[0]
						bcast =  line[2].split(" ")[0]
						mask =  line[3].split(" ")[0]

						ele.append( ifname )
						ele.append( hwaddr )
						ele.append( ipaddr )
						ele.append( bcast )
						ele.append( mask )
						ret.append( ele )
						ele = []
	return ret

def get_wifi_info():
	ret = ['mode','ssid']
	ifnames = get_wireless_wifi_device_section()
	for ifname in ifnames:
		if( uci_get('wireless.' + ifname + '.disabled') == '0' ):
			ret[0] = uci_get('wireless.' + ifname + '.mode')
			ret[1] = uci_get('wireless.' + ifname + '.ssid')
			return ret
	return ret
