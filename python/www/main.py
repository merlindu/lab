#!/usr/bin/env python
#coding=utf-8
import os, sys

workdir = os.path.split(os.path.realpath(__file__))[0]
os.chdir(workdir)

sys.path.append(workdir)
sys.path.append( workdir +"/modules/base/controller" )
import bottle, routes

def flup_fcgi_server():
	from flup.server.fcgi import WSGIServer
	WSGIServer(bottle.default_app()).run()

def bottle_default_server():
	bottle.run(server='wsgiref', host='0.0.0.0', port=8008, debug=True)

if __name__ == '__main__':
	try:
		flup_fcgi_server()
	except:
		bottle_default_server()
