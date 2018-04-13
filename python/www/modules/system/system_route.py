#!/usr/bin/env python
#coding=utf-8
import bottle
from bottle import route, run, template, static_file, redirect, request, error
import os, sys, random, re

if __name__ == '__main__':
	print '"%s" is being executed as main program, nothing done.' % os.path.realpath(__file__)
	os._exit(0)

@route('/system.html')
def route_system():
	return template("system_main")
@route('/home')
def route_system_1():
	return redirect("/system.html")
