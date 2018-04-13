#!/usr/bin/env python
#coding=utf-8

import os
if __name__ == '__main__':
	print '"%s" is being executed as main program, nothing done.' % os.path.realpath(__file__)
	os._exit(0)

import sys,gpio_platform
from gpio_platform import Pin, I2c, Spi, Uart, Chip

FM_PIN_TOTAL = 60
FM_PERI_NAME = "FM peripheral IO"

#platform available, EVB board support
EVB_I2C =	[	[I2c(30, 31), I2c(43, 44)], \
				[I2c(26, 27), I2c(42, 41), I2c(48, 49), I2c(50, 51)], \
				[I2c(20, 25), I2c(50, 51), I2c(58, 59)] \
			]	
EVB_SPI =	[	[Spi(28, 29, 30, 31, 46), Spi(41, 42, 43, 44, 46)], \
				[Spi(24, 25, 26, 27, 28), Spi(46, 47, 48, 49, 28)], \
				[Spi(48, 49, 50, 51, 55), Spi(56, 57, 58, 59, 55)] \
			]		
EVB_UART =	[	[Uart(21, 22, 2, 3), Uart(30, 31, 29, 28), Uart(43, 44, 41, 42), Uart(21, 22, 4, 3)], \
				[Uart(26, 27, 24, 25), Uart(48, 49, 46, 47)], \
				[Uart(41, 42, 45, 46), Uart(52, 53, 54, 55)] \
			]
chip_evb = Chip(FM_PERI_NAME, FM_PIN_TOTAL, EVB_I2C, EVB_SPI, EVB_UART)


#SBC board available
SBC_I2C = [ [I2c(30, 31)] ]
SBC_SPI = [ [] ]
SBC_UART = [ [] ]
chip_sbc = Chip(FM_PERI_NAME, FM_PIN_TOTAL, SBC_I2C, SBC_SPI, SBC_UART)


board = chip_sbc
