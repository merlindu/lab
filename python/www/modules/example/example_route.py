#!/usr/bin/env python
#coding=utf-8

import os
if __name__ == '__main__':
	print '"%s" is being executed as main program, nothing done.' % os.path.realpath(__file__)
	os._exit(0)

from bottle import route, template

@route('/example.html')
def route_example():
	return template("example_main")
