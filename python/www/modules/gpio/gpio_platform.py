#!/usr/bin/env python
#coding=utf-8

import os
if __name__ == '__main__':
	print '"%s" is being executed as main program, nothing done.' % os.path.realpath(__file__)
	os._exit(0)

import sys, ctypes
curdir =  os.path.split(os.path.realpath(__file__))[0]
libname = curdir + "/libicatfm_fake"
#libname = "/usr/lib/libicatgpio"
lib = ctypes.cdll.LoadLibrary(libname)

from utils import verify_object

MDU_DBG_FLAG = True
def mdu_dbg(msg):
	if MDU_DBG_FLAG:
		print "mdu-dbg: " + msg

class Pin(object):
	"""docstring for Pin"""
	def __init__(self, num, name):
		super(Pin, self).__init__()
		self.name = name
		self.num = num
		self.fun = 1 #1 for function, 0 for gpio
		self.dir = "null" #"in" or "out", "null" for "no-gpio"
		self.level = -1 #1 for high, 0 for low, -1 for "no-gpio"

class I2c(object):
	"""docstring for I2c"""
	def __init__(self, sda, sck):
		super(I2c, self).__init__()
		self.sda = Pin(sda, "SDA")
		self.sck = Pin(sck, "SCK")

class Spi(object):
	"""docstring for Spi"""
	def __init__(self, csn, din, dout, clk, bsy):
		super(Spi, self).__init__()
		self.csn = Pin(csn, "CSN")
		self.din = Pin(din, "DI")
		self.dout = Pin(dout, "DO")
		self.clk = Pin(clk, "CLK")
		self.bsy = Pin(bsy, "BSY")
		self.mode = "Master" #"Master" or "Slave"

class Uart(object):
	"""docstring for Uart"""
	def __init__(self, txd, rxd, cts, rts):
		super(Uart, self).__init__()
		self.txd = Pin(txd, "TXD")
		self.rxd = Pin(rxd, "RXD")
		self.rts = Pin(rts, "RTS")
		self.cts = Pin(cts, "CTS")


class Chip(object):
	"""
		@name: chip name, such as "FM"
		@pin: supported pins, count = len(pin)
		@i2c: all supported I2C channel and pinmux corresponding
		@spi: all supported SPI channel and pinmux corresponding
		@uart: all supported UART channel and pinmux corresponding
		@i2c_stat: record the current pinmux of n I2C channels, 0xff means current channel is off
		@spi_stat: record the current pinmux of n SPI channels, 0xff means current channel is off
		@uart_stat: record the current pinmux of n UART channels, 0xff means current channel is off
	"""
	def __init__(self, name, nm, i2c, spi, uart):
		super(Chip, self).__init__()
		self.name = name
		self.count = nm #all pin count number
		self.i2c = i2c
		self.spi = spi
		self.uart = uart

		self.pin = []
		self.i2c_stat = []
		self.spi_stat = []
		self.uart_stat = []

		if nm > 0:
			for i in range(nm):
				self.pin.append( Pin(i, "FMIO"+str(i)) )
		if verify_object(i2c):
			for i in range(len(i2c)):
				self.i2c_stat.append(0xff) #pinmux, 0xff means off
				for j in range(len(i2c[i])):
					if i2c[i][j].sda.num >= nm or i2c[i][j].sda.num >= nm:
						raise Exception("Chip initial failed, \
							I2c arguments error: pin num beyond the range of total pin number.")
		if verify_object(spi):
			for i in range(len(spi)):
				self.spi_stat.append(0xff) #pinmux, 0xff means off
				for j in range(len(spi[i])):
					if spi[i][j].csn.num >= nm or spi[i][j].din.num >= nm \
						or spi[i][j].dout.num >= nm or spi[i][j].clk.num >= nm or spi[i][j].bsy.num >= nm:
						raise Exception("Chip initial failed, \
							Spi arguments error: pin num beyond the range of total pin number.")
		if verify_object(uart):
			for i in range(len(uart)):
				self.uart_stat.append(0xff) #pinmux, 0xff means off
				for j in range(len(uart[i])):
					if uart[i][j].txd.num >= nm or uart[i][j].rxd.num >= nm \
						or uart[i][j].cts.num >= nm or uart[i][j].rts.num >= nm:
						raise Exception("Chip initial failed, \
							Uart arguments error: pin num beyond the range of total pin number.")
	def update_pin_arrt(self, num, name = "error", is_fun = 99, dir = "unknown", level = 99):
		if(pin>=self.count):
			print "argument error: pin number!"
			return -1
		if name != "error":
			self.pin[num].name = name
		if is_fun != 99:
			self.pin[num].fun = is_fun #1 for function, 0 for gpio
		if dir != "unknown":
			self.pin[num].dir = dir #"in" or "out", "null" for "no-gpio"
		if level != 99:
			self.pin[num].level = -1 #1 for high, 0 for low, -1 for "no-gpio"

	def get_pin_status(self, pin):
		if(pin>=self.count):
			print "argument error: pin number!"
			return -1
		return self.pin[pin]

	"""
	return value for get_xxx_status / add_xxx_dev / remove_xxx_dev:
		0 : success
		-1: argument error
		-2: operate ignored(repeat operate)
		-3: C lib return error
	"""
	def get_i2c_status(self): #return pinmuxs, 0xff means off
		mdu_dbg(sys._getframe().f_code.co_name)
		return self.i2c_stat
	def add_i2c_dev(self, chnl, pinmux):
		mdu_dbg(sys._getframe().f_code.co_name + " chnl: " + str(chnl) + ", pinmux: " + str(pinmux))
		chnls = len(self.i2c_stat)
		if chnl >= chnls:
			print "argument error: channel!"
			return -1
		muxs = len(self.i2c[chnl])
		if pinmux >= muxs:
			print "argument error: pinmux!"
			return -1

		if 0xff != self.i2c_stat[chnl]:
			print "I2C channel %d is already ready, do nothing!" % chnl
			return -2
		if 0 != lib.add_i2c_dev(chnl, pinmux):
			print "add I2C device(channel %d) failed!" % chnl
			return -3
		sda = self.i2c[chnl][pinmux].sda
		sck = self.i2c[chnl][pinmux].sck
		self.pin[sda.num].name = sda.name + "-" + str(chnl)
		self.pin[sck.num].name = sck.name + "-" + str(chnl)
		self.i2c_stat[chnl] = pinmux
		return 0

	def remove_i2c_dev(self, chnl):
		mdu_dbg(sys._getframe().f_code.co_name + " chnl: " + str(chnl))
		chnls = len(self.i2c_stat)
		if chnl >= chnls:
			print "argument error: channel!"
			return -1

		pinmux = self.i2c_stat[chnl]
		if 0xff == pinmux:
			print "I2C channel %d is already absent, do nothing!" % chnl
			return -2
		if 0 != lib.remove_i2c_dev(chnl):
			print "remove I2C device(channel %d) failed!" % chnl
			return -3
		sda = self.i2c[chnl][pinmux].sda
		sck = self.i2c[chnl][pinmux].sck
		self.pin[sda.num].name = "FMIO-"+ str(sda.num)
		self.pin[sck.num].name = "FMIO-"+ str(sck.num)
		self.i2c_stat[chnl] = 0xff
		return 0

	def get_spi_status(self): #return pinmuxs, 0xff means off
		mdu_dbg(sys._getframe().f_code.co_name)
		return self.spi_stat
	def add_spi_dev(self, chnl, pinmux, is_slave):
		mdu_dbg(sys._getframe().f_code.co_name + " chnl: " \
			+ str(chnl) + ", pinmux: " + str(pinmux) + ", is_slave: " + str(is_slave))
		chnls = len(self.spi_stat)
		if chnl >= chnls:
			print "argument error: channel!"
			return -1
		muxs = len(self.spi[chnl])
		if pinmux >= muxs:
			print "argument error: pinmux!"
			return -1

		if 0xff != self.spi_stat[chnl]:
			print "SPI/GSI channel %d is already ready, do nothing!" % chnl
			return -2
		if 0 != lib.add_spi_dev(chnl, pinmux, is_slave):
			print "add SPI device(channel %d) failed!" % chnl
			return -3
		csn = self.spi[chnl][pinmux].csn
		din = self.spi[chnl][pinmux].din
		dout = self.spi[chnl][pinmux].dout
		clk = self.spi[chnl][pinmux].clk
		bsy = self.spi[chnl][pinmux].bsy
		self.mode = is_slave == 1 and "slave" or "Master" # slave or master
		self.pin[csn.num].name = csn.name + "-" + str(chnl)
		self.pin[din.num].name = din.name + "-" + str(chnl)
		self.pin[dout.num].name = dout.name + "-" + str(chnl)
		self.pin[clk.num].name = clk.name + "-" + str(chnl)
		self.pin[bsy.num].name = bsy.name + "-" + str(chnl)
		self.spi_stat[chnl] = pinmux
		return 0

	def remove_spi_dev(self, chnl):
		mdu_dbg(sys._getframe().f_code.co_name + " chnl: " + str(chnl))
		chnls = len(self.spi_stat)
		if chnl >= chnls:
			print "argument error: channel!"
			return -1

		pinmux = self.spi_stat[chnl]
		if 0xff == pinmux:
			print "SPI/GSI channel %d is already absent, do nothing!" % chnl
			return -2
		if 0 != lib.remove_spi_dev(chnl):
			print "remove SPI device(channel %d) failed!" % chnl
			return -3
		csn = self.spi[chnl][pinmux].csn
		din = self.spi[chnl][pinmux].din
		dout = self.spi[chnl][pinmux].dout
		clk = self.spi[chnl][pinmux].clk
		bsy = self.spi[chnl][pinmux].bsy

		self.pin[csn.num].name = "FMIO-"+ str(csn.num)
		self.pin[din.num].name = "FMIO-"+ str(din.num)
		self.pin[dout.num].name = "FMIO-"+ str(dout.num)
		self.pin[clk.num].name = "FMIO-"+ str(clk.num)
		self.pin[bsy.num].name = "FMIO-"+ str(bsy.num)
		self.spi_stat[chnl] = 0xff
		return 0

	def get_uart_status(self): #return pinmuxs, 0xff means off
		mdu_dbg(sys._getframe().f_code.co_name)
		return self.uart_stat
	def add_uart_dev(self, chnl, pinmux):
		mdu_dbg(sys._getframe().f_code.co_name + " chnl: " + str(chnl) + ", pinmux: " + str(pinmux))
		chnls = len(self.uart_stat)
		if chnl >= chnls:
			print "argument error: channel!"
			return -1
		muxs = len(self.uart[chnl])
		if pinmux >= muxs:
			print "argument error: pinmux!"
			return -1

		if 0xff != self.uart_stat[chnl]:
			print "UART channel %d is already ready, do nothing!" % chnl
			return -2
		if 0 != lib.add_uart_dev(chnl, pinmux):
			print "add UART device(channel %d) failed!" % chnl
			return -3
		txd = self.uart[chnl][pinmux].txd
		rxd = self.uart[chnl][pinmux].rxd
		rts = self.uart[chnl][pinmux].rts
		cts = self.uart[chnl][pinmux].cts

		self.pin[txd.num].name = txd.name + "-" + str(chnl)
		self.pin[rxd.num].name = rxd.name + "-" + str(chnl)
		self.pin[rts.num].name = cts.name + "-" + str(chnl)
		self.pin[cts.num].name = rts.name + "-" + str(chnl)
		self.uart_stat[chnl] = pinmux
		return 0

	def remove_uart_dev(self, chnl):
		mdu_dbg(sys._getframe().f_code.co_name + " chnl: " + str(chnl))
		chnls = len(self.uart_stat)
		if chnl >= chnls:
			print "argument error: channel!"
			return -1
		pinmux = self.uart_stat[chnl]
		if 0xff == pinmux:
			print "UART channel %d is already absent, do nothing!" % chnl
			return -2
		if 0 != lib.remove_uart_dev(chnl):
			print "add UART device(channel %d) failed!" % chnl
			return -3
		txd = self.uart[chnl][pinmux].txd
		rxd = self.uart[chnl][pinmux].rxd
		rts = self.uart[chnl][pinmux].rts
		cts = self.uart[chnl][pinmux].cts

		self.pin[txd.num].name = "FMIO-"+ str(txd.num)
		self.pin[rxd.num].name = "FMIO-"+ str(rxd.num)
		self.pin[rts.num].name = "FMIO-"+ str(rts.num)
		self.pin[cts.num].name = "FMIO-"+ str(cts.num)
		self.spi_stat[chnl] = 0xff
		return 0
