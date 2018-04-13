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
from gpio_board import chip_evb as chip

@route('/peripheral.html')
def route_gpio():
	return template("gpio_main")
@route('/gpio')
def route_gpio_1():
	return redirect("/peripheral.html")
@route('/peripheral')
def route_gpio_2():
	return redirect("/peripheral.html")

@route("/gpio/peripheral", method="POST")
def ajax_gpio_peripheral():
	if request.is_xhr:
		eventID = request.forms.get('EventId')
		if eventID == "device_operate":
			cmd = request.forms.get("cmd")
			dev = request.forms.get("dev")
			chnl = request.forms.get("chnl")

			if "add" !=cmd and "remove" != cmd:
				print 'form request argument error, oprate must be "add" or "remove"'
				return -1
			if "i2c" != dev and "spi" != dev and "uart" != dev:
				print 'form request argument error, wrong device type!'
				return -1

			if "add" == cmd:
				pinmux = request.forms.get("pinmux")
				if "spi" == dev:
					pinmux = pinmux + ", " + request.forms.get("slave")
				ret = eval( "chip.add_" + dev + "_dev(" + chnl + ", " + pinmux + ")" )
			else:
				ret = eval( "chip.remove_" + dev + "_dev(" + chnl + ")" )
			return str(ret)

		elif eventID == "get_per_dev_status":
			dev = request.forms.get("dev")
			if "i2c" != dev and "spi" != dev and "uart" != dev:
				print 'form request argument error, wrong device type!'
				return -1
			ret = dict()
			stat = eval("chip.get_" + dev + "_status()")
			for i in range(len(stat)):
				ret.setdefault( "chn" + str(i), stat[i] )
			return str(ret)

		elif eventID == "get_pin_status":
			nr = chip.count
			ret = dict()
			for i in range(nr):
				pin = chip.get_pin_status(i)
				cell = {"name":pin.name, "func":pin.fun, "dir":pin.dir, "level":pin.level}
				ret.setdefault( "pin" + str(i), cell )
			return ret
			
		else:
			pass
	else:
		return -2
