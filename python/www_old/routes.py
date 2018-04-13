#!/usr/bin/env python
#coding=utf-8
"""
Routes and views for the bottle application.
"""
#coding=utf-8
from bottle import route, template, redirect, request
import bottle
import os, sys

import icatch_funcs
import route_async
import route_static

if __name__ == '__main__':
	print '"%s" is being executed as main program, nothing done.' % sys.argv[0]
	os._exit(0)

#setting temlate files located directory
root_dir = sys.path[0]
os.chdir(root_dir)
print '[icat-bottle] Current work directory: '  + root_dir + '\n'

for path in bottle.TEMPLATE_PATH:
	if( path == './'):
		bottle.TEMPLATE_PATH.remove( path )

print "template path include: ",
for path in bottle.TEMPLATE_PATH:
	print path + ' ',
print "\n"

cookie_store_dir = "/tmp/icatch_auth"

def icatch_auth( fn ):
	def new_fn( *args ):
		if( icatch_funcs.uci_get('httpstation.@httpstation[0].authentication') == '1' ):
			if( not login_status() ):
				redirect('/login')

				return None
		return fn( *args )
	return new_fn

@route('/system')
@icatch_auth
def sytem():
	cookie_client = request.cookies.icatch_auth or 'o_o'
	session_client = request.cookies.icatch_session or 'o_o'
	try:
		f = open( cookie_store_dir + "/cookie." + request.environ.get('REMOTE_ADDR') )
		while True:
			line = f.readline()
			if not line:
				break
			m = re.match( '.+' + session_client + '.+' + cookie_client, line )
			if m is not None:
				name = line.split('__icat__')[0]
		f.close()
	except IOError:
		name = ''
	return template('system',account = name )
	
@route('/')
def html_index():
	redirect('/home')

@route('/home')
def html_home():
	return template('home')

@route('/network')
@icatch_auth
def ntw_settings():
	return template('network')

@route('/login')
def login():
	return template('login')

@route('/logout')
@icatch_auth
def logout():
	return template('logout')

@route('/net_static')
@icatch_auth
def network_static():
	return template('net_static')

@route('/real')
@icatch_auth
def play_real():
	return template('play_real')

@route('/playback')
def vlc_play():
	return template( "playback" )

@route('/gpio')
def sytem():
	return template('peripheral/gpio')

def login_status():
	cookie_client = request.cookies.icatch_auth or 'o_o'
	session_client = request.cookies.icatch_session or 'o_o'
	try:
		f = open( cookie_store_dir + "/cookie." + request.environ.get('REMOTE_ADDR') )
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

def clean_server_cookie_files():
	os.system("if [ -d " + cookie_store_dir + " ]; then rm -rf " + cookie_store_dir + "; fi")
