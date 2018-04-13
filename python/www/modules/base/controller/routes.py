#!/usr/bin/env python
#coding=utf-8

import os
if __name__ == '__main__':
	print '%s is being executed as main program, nothing done.' % os.path.realpath(__file__)
	os._exit(0)

from bottle import route, template, static_file, redirect, error
import bottle
bottle.TEMPLATE_PATH = []
bottle.TEMPLATE_PATH.append("./modules/base/views/")

import modules.modules

COOKIE_STORE_DIR = "/tmp/icatch_auth"
def check_login_status():
	if( icatch_funcs.uci_get('httpstation.@httpstation[0].authentication') != '0' ):
		return True
	cookie_client = request.cookies.icatch_auth or 'o_o'
	session_client = request.cookies.icatch_session or 'o_o'
	try:
		f = open( COOKIE_STORE_DIR + "/cookie." + request.environ.get('REMOTE_ADDR') )
		while True:
			line = f.readline()
			if not line:
				break
			auth_store = line.strip('\n').split('__icat__')
			session_auth_store = auth_store[1]
			cookie_auth_store = auth_store[2]
			if( cookie_client == cookie_auth_store and session_client == session_auth_store ):
				return True
		f.close()
	except IOError:
		return False
	return False

def authenticate_login( fn ):
	def new_fn( *args ):
		if( not check_login_status() ):
			redirect('/login')
			return None
		return fn( *args )
	return new_fn


@route('/')
def route_root():
	return redirect('/system.html')

@route('/index.html')
def route_index():
	return template('template/template')

@route('/tpl')
def route_template():
	return template('template/template_standalone')

@error(404)
def error404(error):
	return template('common/error404')


##########################################################################
#######################static routes below################################
##########################################################################
@route('/images/<filename:re:.*\.png|.*\.jpg|.*\.ico|.*\.gif|.*\.bmp>')
def image_static(filename):
	return static_file(filename, root='./asserts/images')

@route('/css/<filename:re:.*\.css>')
def css_static(filename):
	return static_file(filename, root='./asserts/css')

@route('/js/<filename:re:.*\.js>')
def js_static(filename):
	return static_file(filename, root='./asserts/js')

@route('/iconfont/<filename:re:.*\.css|.*\.eot|.*\.ttf|.*\.woff|.*\.woff2>')
def icon_static(filename):
	return static_file(filename, root='./asserts/iconfont')

@route('/fonts/<filename:re:.*\.woff|.*\.woff2>')
def font_static(filename):
	return static_file(filename, root='./asserts/fonts')

@route('/media/<filename:re:.*\.swf>')
def swf_static(filename):
	return static_file(filename, root='./asserts/media')
