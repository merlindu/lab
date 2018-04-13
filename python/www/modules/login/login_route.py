#!/usr/bin/env python
#coding=utf-8

import os
if __name__ == '__main__':
	print '"%s" is being executed as main program, nothing done.' % os.path.realpath(__file__)
	os._exit(0)

from bottle import route, template, redirect, request
import utils

@route('/login.html')
def route_login():
	return template("login_login")
@route('/login')
def route_login_1():
	return redirect("/login.html")

@route('/logout.html')
def route_logout():
	return template("login_logout")
@route('/logout')
def route_logout_1():
	return redirect("/logout.html")

cookie_store_dir = "/tmp/icatch_auth"
@route("/login/login", method="POST")
def ajax_login_login():
	if request.is_xhr:
		eventID = request.forms.get('EventId')
		if( eventID=="login_login" ):
			name = request.forms.get( 'name' )
			password = request.forms.get( 'password' )

			if( 1 != utils.checkpassword( name, password ) ):
				return {"login":"0","cookie":"","ip":""}
			else:
				pattern = request.cookies.icatch_auth or 'none'
				if( pattern  != 'none' ):
					cookie_store_file = cookie_store_dir + "/cookie." + request.environ.get('REMOTE_ADDR')
					os.system( 'sed -i "/' + pattern + '/d" ' + cookie_store_file )

				random_t = open( "/proc/sys/kernel/random/uuid" ).readline()
				cookie_value = utils.md5cal( random_t )
				session_value = utils.md5cal( cookie_value )
				client_ip = request.environ.get('REMOTE_ADDR')
				cookie_value_post = name
				cookie_value_post = cookie_value_post + '__icat__' + session_value
				cookie_value_post = cookie_value_post + '__icat__' + cookie_value

				cookie_store_file = cookie_store_dir + "/cookie." + client_ip
				os.system("if [ ! -d " + cookie_store_dir + " ]; then mkdir -p " + cookie_store_dir +"; fi")
				os.system("echo " + cookie_value_post + ">> " + cookie_store_file )
				return {"login":"1","cookie":cookie_value,"ip":client_ip,'session':session_value}
		else:
			pass
	else:
		return -2

@route("/login/logout", method="POST")
def ajax_login_login():
	if request.is_xhr:
		eventID = request.forms.get('EventId')
		if( eventID == "login_logout" ):
			pattern = request.cookies.icatch_auth
			cookie_store_file = cookie_store_dir + "/cookie." + request.environ.get('REMOTE_ADDR')
			os.system( 'sed -i "/' + pattern + '/d" ' + cookie_store_file )
			return 'success'
		else:
			pass
	else:
		return -2
