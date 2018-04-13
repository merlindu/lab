#!/usr/bin/env python
#coding=utf-8
import bottle

# routes contains the HTTP handlers for our server and must be imported.
import routes

def run_app():
	routes.clean_server_cookie_files()
	bottle.run(server='wsgiref', host='0.0.0.0', port=8080, debug=True)

if __name__ == '__main__':
	run_app()
	
