#!/usr/bin/env python
#coding=utf-8

import os

if __name__ == '__main__':
	print '"%s" is being executed as main program, nothing done.' % os.path.realpath(__file__)
	os._exit(0)

import bottle
from importlib import import_module

curdir = os.path.split(os.path.realpath(__file__))[0]
curdir_name = os.path.split(curdir)[1]

for root, dirs, files in os.walk(curdir):
	for name in dirs:
		if name=="example":
			continue
		file = curdir + "/" + name + "/" + name + "_route.py"
		if os.path.exists(file):
			bottle.TEMPLATE_PATH.append( curdir + "/" + name + "/" + "views/")
			import_module( curdir_name + "." + name + "." + name + "_route")
