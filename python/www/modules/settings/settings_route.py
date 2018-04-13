#!/usr/bin/env python
#coding=utf-8

import os
if __name__ == '__main__':
	print '"%s" is being executed as main program, nothing done.' % os.path.realpath(__file__)
	os._exit(0)

from bottle import route, template, request

@route('/settings')
def route_settings():
	return template("settings_main")
