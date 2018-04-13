#!/usr/bin/env python
#coding=utf-8

import os
if __name__ == '__main__':
	print '"%s" is being executed as main program, nothing done.' % os.path.realpath(__file__)
	os._exit(0)

import sys
curdir = os.path.split(os.path.realpath(__file__))[0]
sys.path.append(curdir)

from bottle import route, template, redirect, request

@route('/network.html')
def route_network():
	return template("network_main")
@route('/network')
def route_network_1():
	return redirect("/network.html")

from utils import wireless, network
@route("/network/settings", method="POST")
def ajax_network_settings():
	if request.is_xhr:
		eventID = request.forms.get('EventId')

		if eventID == "get_saved_ap":
			return wireless.ap_saved
		elif eventID == "set_wireless":
			ret = True
			mode = request.forms.get('mode')
			ssid = request.forms.get('ssid')
			password = request.forms.get('password')
			if mode == "sta":
				save = request.forms.get('save')
				if save == "true":
					wireless.save_an_ap(ssid, password)
				adv_option = request.forms.get('adv_option')
				if adv_option == "yes":
					ipaddr = request.forms.get('ipaddr')
					gateway = request.forms.get('gateway')
					netmask = request.forms.get('netmask')
					if ipaddr and gateway and netmask:
						network.set_iface("wlan0", ipaddr, gateway, netmask)
					else:
						print "netmask: %s" %(netmask and "yes" or "no")
						ret = False
			try:
				eval("wireless.set_" + mode + "('" + ssid + "', 'psk2', '" + password + "')");
			except TypeError:
				ret = False
			return (ret and "successfully!" or "failed!")
		else:
			pass
	else:
		return -2
