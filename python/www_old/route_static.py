#!/usr/bin/env python
#coding=utf-8
"""
Routes static files.
"""
#coding=utf-8
from bottle import route, template, static_file, error
import sys,os

if __name__ == '__main__':
	print '"%s" is being executed as main program, nothing done.' % sys.argv[0]
	os._exit(0)

@error(404)
def error404(error):
	return template('error')

@route('/images/<filename:re:.*\.png|.*\.jpg|.*\.ico|.*\.gif|.*\.bmp>')
def image_static(filename):
    return static_file(filename, root='./asserts/images')
	
#@route('/bsjs/<filename:re:.*\.js>')
#def bsjs_static(filename):
#   return static_file(filename, root='./asserts/bootstrap/js')
	
#@route('/bscss/<filename:re:.*\.css|.*\.map>')
#def bscss_static(filename):
#    return static_file(filename, root='./asserts/bootstrap/css')

@route('/css/<filename:re:.*\.css>')
def css_static(filename):
    return static_file(filename, root='./asserts/css')
	
@route('/js/<filename:re:.*\.js>')
def js_static(filename):
    return static_file(filename, root='./asserts/js')
