#!/usr/bin/env python
#coding=utf-8

import os
if __name__ == '__main__':
	print '"%s" is being executed as main program, nothing done.' % os.path.realpath(__file__)
	os._exit(0)

import sys, subprocess, re
curdir = os.path.split(os.path.realpath(__file__))[0]
tmpdir = curdir

def verify_object(obj):
	if not obj:
		return False
	if type(obj) == list:
		for i in range(len(obj)):
			ret = verify_object(obj[i])
			if ret:
				return True
	else:
		if obj:
			return True
	return False


ETC_PASSWD_FILE = tmpdir + "/etc_passwd"
class Encryption(object):
	"""docstring for Encryption"""
	def __init__(self, name):
		super(Encryption, self).__init__()
		self.name = name
	def checkpassword( self, user_id, password_hash ):
	# return value:
	# 	-1 : not found user_id
	# 	0 : check password failed
	# 	1 : check password ok
		try:
			f = open ( ETC_PASSWD_FILE )
			while True:  
				line = f.readline().strip('\n') 
				if line:
					if line.split(':')[0] == user_id:
						if password_hash == md5cal( line.split(':')[1] ):
							return 1
						else:
							return 0
				else:
					break
			f.close()
		except IOError:
			print "python error: read ID file failed!"
			return -1
		# username = uci.get('httpstation.@httpstation[0].username')
		# password = uci.get('httpstation.@httpstation[0].password')
		# if(username == user_id and md5cal(password) == password_hash):
		# 	return 1
		# return 0
	def changepassword( self, id, password ):
		f = open ( ETC_PASSWD_FILE )
		pattern = '^.*' + id + ':.*'
		new = id + ':' + password
		os.system( 'sed -i "s/' + pattern + '/' + new +  '/" ' + ETC_PASSWD_FILE )
		# uci.set('httpstation.@httpstation[0].username', id)
		# uci.set('httpstation.@httpstation[0].password', password)
		# uci.commit('httpstation')
	def md5cal(self, str):
		import hashlib
		m = hashlib.md5()
		m.update(str)
		return m.hexdigest()
encryption = Encryption("Openwrt-iCatch")


class Uci(object):
	"""docstring for uci"""
	def __init__(self, name):
		super(Uci, self).__init__()
		self.name = name
	def get(self, target):
		p = subprocess.Popen("uci get \"" + target + "\"", shell=True, stdout=subprocess.PIPE)  
		return p.communicate()[0].rstrip()
	def set(self, target, value):
		#set <config>.<section>[.<option>]=<value>
		os.system( "uci set \"" + target + "=" + value + "\"" )
	def delete(self, target):
		os.system( "uci delete \"" + target + "\"" )
	def add(self, target):
		os.system( "uci add \"" + target + "\"" )
	def commit(self, target):
		os.system( "uci commit \"" + target + "\"" )
	def add_list(self, target):
		os.system( "uci add_list \"" + target + "\"" )
uci = Uci("Openwrt-iCatch")


class Ubus(object):
	"""docstring for Ubus"""
	def __init__(self, name):
		super(Ubus, self).__init__()
		self.name = name
	def call(self, target, method):
		"""eg: ubus.call( 'network',  'reload')"""
		os.system( "ubus call " + target + " " + method )
ubus = Uci("Openwrt-iCatch")


class Wireless(object):
	"""docstring for Wireless"""
	def __init__(self, name):
		super(Wireless, self).__init__()
		self.name = name
		self.availabeAPs = []
		self.iwinfo = []
		self.ap_saved = dict()
	def set_sta(self, ssid, encry, password):
		uci.set( 'wireless.sta', 'wifi-iface')
		uci.set( 'wireless.sta.device', 'radio0')
		uci.set( 'wireless.sta.network', 'wlan')
		uci.set( 'wireless.sta.mode', 'sta')
		uci.set( 'wireless.sta.ssid', ssid )
		uci.set( 'wireless.sta.encryption', encry )
		uci.set( 'wireless.sta.key', password )
		uci.set( 'wireless.sta.disabled', '1' )
		uci.commit('wireless')
	def set_ap(self, ssid, encry, password):
		uci.set( 'wireless.ap', 'wifi-iface')
		uci.set( 'wireless.ap.device', 'radio0')
		uci.set( 'wireless.ap.network', 'wlan')
		uci.set( 'wireless.ap.mode', 'ap')
		uci.set( 'wireless.ap.ssid', ssid )
		uci.set( 'wireless.ap.encryption', encry )
		uci.set( 'wireless.ap.key', password )
		uci.set( 'wireless.ap.disabled', '1' )
		uci.commit('wireless')
	def save_an_ap(self, ssid, password, encry='psk2'):
		self.ap_saved.setdefault(ssid, password)
	def set_mode(self, mode):
		if( mode == 'sta' or mode == 'STA' or mode == 'station' or mode == 'Station' ):
			uci.set( 'wireless.sta.disabled', '0' )
			uci.set( 'wireless.ap.disabled', '1' )
			uci.set( 'network.wlan.proto', 'dhcp' )
			uci.set( 'network.wan.proto', 'static' )
			uci.commit('network')
			uci.commit('wireless')
		elif( mode == 'ap' or mode == 'AP' or mode == 'Ap' or mode == 'aP' ):
			uci.set( 'wireless.ap.disabled', '0' )
			uci.set( 'wireless.sta.disabled', '1' )
			uci.set( 'wireless.ap.disabled', '0' )
			uci.set( 'network.wlan.proto', 'static' )
			uci.set( 'network.wan.proto', 'dhcp' )
			uci.commit('network')	
			uci.commit('wireless')
		else:
			pass
	def scan_wifi(self, force=True):
		if not force:
			if verify_object(self.availabeAPs):
				return
		self.availabeAPs = []
		# fake_file = tmpdir + '/wifilist.txt'
		# if( os.path.exists( fake_file ) ):
		# 	f = open ( fake_file )
		# 	content_of_all = f.read()
		# else:
		p = subprocess.Popen("iwinfo wlan0 scan", shell=True, stdout=subprocess.PIPE)
		content_of_all = p.communicate()[0]

		for block in re.split( r'\s*Cell.+Address: ', content_of_all ):
			"""
			a block like blow
			Cell 01 - Address: 9C:65:F9:1C:17:34
			          ESSID: "ICALOU1C1734"
			          Mode: Master  Channel: 2
			          Signal: -45 dBm  Quality: 65/70
			          Encryption: WPA2 PSK (CCMP)
			"""
			lines = block.split('\n')
			error = True
			m = re.match( '([0-9A-F]{1,2}:){5}[0-9A-F]{1,2}', lines[0] )
			if m is not None:
				bssid = lines[0]
				ele = dict()
				for line in lines:
					try:
						mode=re.split( r'Mode:', line.strip() )[1].strip('\'').strip('\"')
						error = False
						ele.setdefault( "mode", mode )
					except IndexError:
						pass
					try:
						essid=re.split( r'ESSID:', line.strip() )[1].strip(' ').strip('\'').strip('\"')
						ele.setdefault( "essid", essid )
						error = False
					except IndexError:
						pass
					try:
						encry =  re.split( r'Encryption:', line.strip() )[1].strip(' ').strip('\'').strip('\"')
						ele.setdefault( "encryption", encry=='none' and 'none' or 'psk2' )
						error = False
					except IndexError:
						pass
					try:
						import string
						qual =  re.split( r'\s*Signal:.+Quality: ', line.strip() )[1].strip('\'').strip('\"')
						qual = str( int( string.atof( qual.split('/')[0] ) / string.atof( qual.split('/')[1] )*100 ) )
						ele.setdefault( "quality", qual )
						error = False
					except IndexError:
						pass
				if(not error):
					self.availabeAPs.append( ele )
					error = True
		return self.availabeAPs
	def get_status(self):
		self.iwinfo = []
		iwinfos = subprocess.Popen("iwinfo", shell=True, stdout=subprocess.PIPE).communicate()[0].rstrip()
		for iwinfo in re.split( r'^', iwinfos ):
			error = True
			lines = iwinfo.split('\n')
			winfo = dict()
			for line in lines:
				try:
					divs = re.split( r'ESSID:', line.strip() )
					name = divs[0].strip().strip('\'').strip('\"')
					essid = divs[1].strip().strip('\'').strip('\"')
					error = False
					winfo.setdefault( "name", name )
					winfo.setdefault( "essid", essid )
				except IndexError:
					pass
				try:
					mode = re.split( r'Mode:', line.strip() )[1].strip('\'').strip('\"').strip().split()[0]
					error = False
					winfo.setdefault( "mode", mode )
				except IndexError:
					pass
			if(not error):
				self.iwinfo.append( winfo )
		return self.iwinfo

wireless = Wireless("Openwrt-iCatch")
wireless.save_an_ap("TP-24-1212", "keykeykey")


ETC_CONFIG_NETWORK="/etc/config/network"
class Network(object):
	"""docstring for Network"""
	def __init__(self, name):
		super(Network, self).__init__()
		self.name = name
		self.ifnames = []
	def get_ifnames(self):
		try:
			f = open ( ETC_CONFIG_NETWORK )
			while True:
				line = f.readline()
				if not line:
					break
				m = re.match("^config.+interface.*",line)
				if m is not None:
					try:
						ifname = re.split( r'\s+', line.strip() )[2] # eg: config interface 'loopback', ifname = 'loopback'
					except IndexError:
						ifname = "unnamed"
					self.ifnames.append(  ifname.strip('\'').strip('\"')  )
			f.close()
		except IOError:
			print "python error: read network config file failed!"
			pass
		return self.ifnames
	def restart(self):
		os.system("/etc/init.d/network restart")
	def set_iface(self, ifname, ipaddr, gateway, netmask, dhcp=False):
		print "ifname: " + ifname + ", ipaddr: " + ipaddr + ", gateway: " + gateway + ", netmask: " + netmask
		valid = subprocess.Popen('ifconfig | grep "^' + ifname +'"', shell=True, stdout=subprocess.PIPE).communicate()[0]
		while True:
			if not valid:
				break
			if ifname==uci.get("network.@interface[" + i + "].ifname"):
				uci.set("network.@interface[" + i + "].proto", dhcp and "dhcp" or "static")
				uci.set("network.@interface[" + i + "].ipaddr", ipaddr)
				uci.set("network.@interface[" + i + "].gateway", gateway)
				uci.set("network.@interface[" + i + "].netmask", netmask)
				uci.commit("network")
				return
	def get_info(self):
		iface = dict()
		ret=[]
		file_in_disk='/home/merlin/ming.du/webframework/bottle/icalou/base/ifconfig'
		if os.path.exists(file_in_disk):
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

							iface.setdefault( "ifname", ifname )
							iface.setdefault( "hwaddr", hwaddr )
							iface.setdefault( "ipaddr", ipaddr )
							iface.setdefault( "bcast", bcast )
							iface.setdefault( "mask", mask )
							ret.append( iface )
							iface = dict()
		return ret
network = Network("Openwrt-iCatch")


#ETC_CONFIG_ICATHTTP="/etc/config/icathttp"
ETC_CONFIG_ICATHTTP="/home/ming.du/src/httpstation.bsp3.svn/media.txt"
DB_FILE = tmpdir + '/videofiles.db'
import sqlite3, datetime

class MediaLibrary(object):
	"""docstring for MediaLibrary"""
	def __init__(self, name):
		super(MediaLibrary, self).__init__()
		self.name = name

	#date-string type
	def query_files_by_date(self, year, month,day ):
		year = int(year)
		month = int(month)
		day = int(day)

		ret = []
		conn = sqlite3.connect(DB_FILE)
		cursor = conn.cursor()
		if year == 0 and month == 0 and day == 0:
			cursor.execute('select * from filelist' )
			items = cursor.fetchall()
			cursor.execute( 'select count(*) from filelist' )
			total = cursor.fetchall()[0][0]
		else:
			date = datetime.date(year,month,day)
			cursor.execute('select * from filelist where date="' + str(date) + '"' )
			items = cursor.fetchall()

			cursor.execute( 'select count(*) from filelist where date="'  + str(date) + '"' )
			total = cursor.fetchall()[0][0]
		cursor.close()
		conn.close()

		ret.append( total )
		ret.append( items )
		return ret
	def media_path_config_parse(self):
		file_path = "__read_file_error__"
		pathes=[]
		# try:
		# 	f = open ( ETC_CONFIG_ICATHTTP )
		# 	while True:
		# 		line = f.readline()
		# 		if not line:
		# 			break
		# 		m = re.match("^file_path\s*=\s*\[.*\]",line)
		# 		if m is not None:
		# 			try:
		# 				file_path = re.split( '=', line.strip() )[1].strip().strip('\"').strip('\'')
		# 			except IndexError:
		# 				file_path = "__no_file_path__"
		# 	f.close()
		# except IOError:
		# 	pass
		# file_path = re.split( ',', file_path.strip() )
		# for path in file_path:
		# 	pathes.append(  path.strip().strip('\"').strip('\'') )
		# file_path = pathes
		file_path = '\'' + uci.get('httpstation.@httpstation[0].mediapath') + '\''
		file_path = file_path.replace(' ', '\',\'')
		file_path = re.split( ',', file_path.strip() )
		for path in file_path:
			pathes.append( path.strip().strip('\"').strip('\'') )
		file_path = pathes
		print file_path
		return file_path
	def media_path_config_parse_t(self):
		pathes=[]
		pathes.append("/home/ming.du/template/media")
		file_path = pathes
		print file_path
		return file_path
	def scan_all_files(self):
		media_file_path = self.media_path_config_parse()
		try:
			for path in media_file_path:
				if not os.path.isdir( path ):
					print "Error: a config error has been ignored! path " + path + " does not exists."
					continue
				for filename in os.listdir( path ):
					fullname = path + "/" + filename
					if os.path.isfile( path + "/" + filename ):
						modifydate = datetime.datetime.fromtimestamp( os.path.getmtime( fullname) ).date()
						thumbnail=self.thumbnail_generate(path,filename)
						conn = sqlite3.connect(DB_FILE)
						cursor = conn.cursor()
						cursor.execute('insert into filelist values("' + filename + '","' \
							+ path + '","' + str(modifydate) + '","'+ thumbnail + '")')
						cursor.close()
						conn.commit()
						conn.close()
		except Exception, e:
			print "exception: " + str(e)
			return -1
		return 0
	def thumbnail_generate(self, path,name):
		#thumbnail generate as below
		#thumbnail_relative_dir = "asserts/images"
		#store_dir = uci.get('httpstation.@httpstation[0].bottlepythonroot') + "/" + thumbnail_relative_dir
		#generate thumbnail in store_dir
		#....
		#
		ret = "thumb_icat.jpg"
		return ret
	def create_db(self):
		"""
		Table filelist:
		---------------------------------------------------
		| filename  |  filefolder  |  date  |  thumbnail  |
		---------------------------------------------------
		"""
		try:
			conn = sqlite3.connect(DB_FILE)
			cursor = conn.cursor()
			cursor.execute( 'create table filelist( \
							filename varchar(50) NOT NULL, \
							filefolder varchar(200) NOT NULL, \
							date date NOT NULL, \
							thumbnail varchar(200), \
							primary key(filefolder,filename) )' )
			cursor.close()
			conn.commit()
			conn.close()
			return 0
		except:
			return -1
	def re_create_db(self):
		if os.path.exists(DB_FILE):
			os.remove(DB_FILE)
		if 0 != self.create_db():
			return -1
		return self.scan_all_files()
playback_db = MediaLibrary("playback-iCatch")

if not os.path.exists(DB_FILE):
	playback_db.create_db()
	playback_db.scan_all_files()


class MediaReal(object):
	"""docstring for MediaReal"""
	def __init__(self, name):
		super(MediaReal, self).__init__()
		self.name = name
meida_playreal = MediaReal("playreal-iCatch")
