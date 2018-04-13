#!/usr/bin/env python
#coding=utf-8
"""
an ajax handle callback
"""
#coding=utf-8
from bottle import route, template, request
import bottle
import os,sys
import icatch_funcs
import icatch_playback
from fm_gpio import chip as fm_chip
import commands

if __name__ == '__main__':
	print '"%s" is being executed as main program, nothing done.' % sys.argv[0]
	os._exit(0)

cookie_store_dir = "/tmp/icatch_auth"

@route("/ajax")
def ajax_get():
	return template('error')

@route("/ajax",method='POST')
def ajax_post():
	if request.is_xhr:	
		eventID = request.forms.get('EventId')
		#if( eventID != "icat_login" and not login_status() ):
		#	print '[icat-bottle] Invalid request, the POST has been rejected.\n'
		#	return
		if( eventID=="icat_login" ):
			name = request.forms.get( 'name' )
			password = request.forms.get( 'password' )

			if( 1 != icatch_funcs.checkpassword( name, password ) ):
				return {"login":"0","cookie":"","ip":""}
			else:
				pattern = request.cookies.icatch_auth or 'none'
				if( pattern  != 'none' ):
					cookie_store_file = cookie_store_dir + "/cookie." + request.environ.get('REMOTE_ADDR')
					os.system( 'sed -i "/' + pattern + '/d" ' + cookie_store_file )

				random_t = open( "/proc/sys/kernel/random/uuid" ).readline()
				cookie_value = icatch_funcs.md5cal( random_t )
				session_value = icatch_funcs.md5cal( cookie_value )
				client_ip = request.environ.get('REMOTE_ADDR')
				cookie_value_post = name
				cookie_value_post = cookie_value_post + '__icat__' + session_value
				cookie_value_post = cookie_value_post + '__icat__' + cookie_value

				cookie_store_file = cookie_store_dir + "/cookie." + client_ip
				os.system("if [ ! -d " + cookie_store_dir + " ]; then mkdir -p " + cookie_store_dir +"; fi")
				os.system("echo " + cookie_value_post + ">> " + cookie_store_file )
				return {"login":"1","cookie":cookie_value,"ip":client_ip,'session':session_value}
		elif( eventID == "icat_logout" ):
			pattern = request.cookies.icatch_auth
			cookie_store_file = cookie_store_dir + "/cookie." + request.environ.get('REMOTE_ADDR')
			os.system( 'sed -i "/' + pattern + '/d" ' + cookie_store_file )
			return 'success'

		elif eventID == "gpio_operate":
			cmd = request.forms.get("cmd")
			if "add" !=cmd and "remove" != cmd:
				print 'form request argument error, oprate must be "add" or "remove"'
				return -1
			dev = request.forms.get("dev")
			chnl = request.forms.get("chnl")
			chnl = int(chnl)
			if "add" == cmd:
				pinmux = request.forms.get("pinmux")
				pinmux = int(pinmux)

			if "i2c" == dev:
				if "add" == cmd:
					ret = fm_chip.add_i2c_dev(chnl, pinmux)
				else:
					ret = fm_chip.remove_i2c_dev(chnl)
			elif "spi" == dev:
				if "add" == cmd:
					slave = int(request.forms.get("slave"))
					ret = fm_chip.add_spi_dev(chnl, pinmux, 0)
				else:
					ret = fm_chip.remove_spi_dev(chnl)
			elif "uart" ==dev:
				if "add" == cmd:
					ret = fm_chip.add_uart_dev(chnl, pinmux)
				else:
					ret = fm_chip.remove_uart_dev(chnl)
			else:
				print 'form request argument error, device type error'
				return -1
			return str(ret)
		elif eventID == "get_per_dev_status":
			dev = request.forms.get("dev")
			ret = {"return": 0}
			if "i2c" == dev:
				stat = fm_chip.get_i2c_status()
				for i in range(len(stat)):
					ret.setdefault("chn"+str(i), stat[i])
			elif "spi" == dev:
				stat = fm_chip.get_spi_status()
				for i in range(len(stat)):
					ret.setdefault("chn"+str(i), stat[i])
			elif "uart" ==dev:
				stat = fm_chip.get_uart_status()
				for i in range(len(stat)):
					ret.setdefault("chn"+str(i), stat[i])
			else:
				print 'form request argument error, device type error'
				return -1
			return str(ret)

		elif eventID == "get_pin_status":
			nr = fm_chip.count
			ret = {"return": 0}
			for i in range(nr):
				pin = fm_chip.get_pin_status(i)
				cell = {"name": pin.name,"func":pin.fun,"dir":pin.dir,'level':pin.level}
				ret.setdefault("pin"+str(i), cell)
			return ret

		elif( eventID=="auto_wifi"):
			com1 = commands.getoutput("uci show wireless.sta.disabled")
			com2 = commands.getoutput("iwconfig wlan0 | grep Point | awk '{print $NF}'")
			if com1 == "wireless.sta.disabled='0'" and com2 != "Not-Associated":
				return 
			ret = commands.getoutput( sys.path[0] + "/shell_tmp/wifi_auto")
			if ret:
				cmd1 = "echo '%s' | awk '{print $1}'" %(ret)
				cmd2 = "echo '%s' | awk '{print $2}'" %(ret)
				ssid = commands.getoutput(cmd1)
				password = commands.getoutput(cmd2)
				icatch_funcs.set_wireless_sta(ssid, password and 'psk2' or 'none', password  or 'none')
				icatch_funcs.set_wifi_mode( 'sta' )
				os.system("sync")
				icatch_funcs.restart_network()
				ret1 = icatch_funcs.wifi_check(ssid)
				if ret1 == "connect ok":
					ipret = icatch_funcs.ip_nat('wlan0','eth0')
					return
			else:	
				return
		elif( eventID=="select_auto" ):
			ssid = request.forms.get( 'ssid' )
			cmd = "iwinfo wlan0 scan | grep %s -A 3 | grep Encryption | awk '{print $2}'" %(ssid)
			psd = commands.getoutput(cmd)
			if psd != 'none':
				ret = icatch_funcs.wifi_saved(ssid)
				if ret:
					password = ret
					icatch_funcs.set_wireless_sta(ssid, password and 'psk2', password)
					icatch_funcs.set_wifi_mode( 'sta' )
					icatch_funcs.restart_network()
					os.system("sync")
					ret1 = icatch_funcs.wifi_check(ssid)
					if ret1 == "connect ok":
						ipret = icatch_funcs.ip_nat('wlan0','eth0')
					netcheck = icatch_funcs.check_inter()
					if netcheck == "network ok":
						return "connect success"
					else:
						return "connect fail"
				else:
					return "please input password"
			else:
				icatch_funcs.set_wireless_sta(ssid,'none','none')
				icatch_funcs.set_wifi_mode( 'sta' )
				os.system("sync")
				icatch_funcs.restart_network()
				ret1 = icatch_funcs.wifi_check(ssid)
				if ret1 == "connect ok":
					ipret = icatch_funcs.ip_nat('wlan0','eth0')
				netcheck = icatch_funcs.check_inter()
				if netcheck == "network ok":
					return "connect success"
				else:
					return "connect fail"
			
		elif( eventID=="password_connect" ):
			password = request.forms.get( 'password' )
			ssid = request.forms.get( 'ssid' )	
			pack = request.forms.get( 'pack' )
			icatch_funcs.set_wireless_sta(ssid, password and 'psk2', password)
			icatch_funcs.set_wifi_mode( 'sta' )
			os.system("sync")
			icatch_funcs.restart_network()
			ret1 = icatch_funcs.wifi_check(ssid)
			if ret1 == "connect ok":
				ipret = icatch_funcs.ip_nat('wlan0','eth0')
				if pack == "true":
					icatch_funcs.save_password(ssid,password)
					os.system("sync")
			netcheck = icatch_funcs.check_inter()
			if netcheck == "network ok":
				return "connect success"
			else:
				return "connect fail"
		elif( eventID=="set_ap" ):
			print "set_ap"
			ssid = request.forms.get( 'ap_name') or 'icat_ap'
			password = request.forms.get( 'ap_password' )
			icatch_funcs.set_wireless_ap( ssid, password and 'psk2' or 'none', password  or 'none' )
			icatch_funcs.set_wifi_mode( 'ap' )
			os.system("sync")
			icatch_funcs.restart_network()
			ret = icatch_funcs.check_eth0()
			if ret == "eth0 no ok":
				return "no find eth0 IP"
			return "for ap, ssid = " + ssid + ', password = ' + password	
		elif( eventID=="break_off" ):
			print "break_off"
			os.system('wifi down')
			return "close down"

		elif( eventID=="dongle_on" ):
			os.system("/etc/init.d/net_dongle start &")
		
		elif( eventID=="dongle_off" ):
			print "dongle auto off"
			os.system("/etc/init.d/net_dongle stop")

		elif( eventID=="account_setting" ):
			account = request.forms.get( 'account' )
			pwd = request.forms.get( 'pwd' )
			icatch_funcs.changepassword( account, pwd )
			return 'The password of ' + account + ' has been changed.'
		elif( eventID == "re_scan_all_media" ):
			ret = icatch_playback.re_create_db()
			if( ret == 0 ):
				return "Update media list successfully!"
			else:
				return "Error, Update media list failed!"
		elif( eventID == "show_all_media" ):
			return template('playback_list', year=0,month=0,day=0)
		elif( eventID=="checkpassword" ):
			account = request.forms.get( 'account' )
			password = request.forms.get( 'password' )
			status =  icatch_funcs.checkpassword( account, password )
			return status == 1 and '1' or '0'
		elif( eventID=="unload" ):
			wans = request.forms.get( 'wans' )			
			icatch_funcs.save_info(wans)	
			return 
			
		elif( eventID == "calendarPOST" ):
			year = request.forms.get( 'year' )
			month = request.forms.get( 'month' )
			day = request.forms.get( 'day' )
			return template('playback_list', year=year,month=month,day=day)
			
		else:
			pass
	else:
		return -2
