#!/usr/bin/env python
#coding=utf-8

import os
if __name__ == '__main__':
	print '"%s" is being executed as main program, nothing done.' % os.path.realpath(__file__)
	os._exit(0)

import sys
curdir = os.path.split(os.path.realpath(__file__))[0]
sys.path.append(curdir)

from bottle import route, template, redirect, request

@route('/media/real.html')
def route_meida_real():
	return template("media_real")
@route('/real')
def route_meida_real_1():
	return redirect("/media/real.html")
@route('/media/real')
def route_meida_real_2():
	return redirect("/media/real.html")


@route('/media/library.html')
def route_meida_library():
	return template("media_library")
@route('/playback')
def route_meida_library_1():
	return redirect("/media/library.html")
@route('/media/library')
def route_meida_library_2():
	return redirect("/media/library.html")


@route("/media/real", method="POST")
def ajax_media_real():
	if request.is_xhr:
		eventID = request.forms.get('EventId')
		pass
	else:
		return -2

from utils import playback_db as db
@route("/media/library", method="POST")
def ajax_media_library():
	if request.is_xhr:
		eventID = request.forms.get('EventId')
		if eventID == "update_gallery_by_date":
			year = request.forms.get( 'year' )
			month = request.forms.get( 'month' )
			day = request.forms.get( 'day' )
			ret = []
			info = db.query_files_by_date(year, month, day)
			total = info[0]
			for i in range(total):
				file = dict()
				file.setdefault("name", str(info[1][i][0]))
				file.setdefault("path", str(info[1][i][1]))
				file.setdefault("date", str(info[1][i][2]))
				file.setdefault("thumbnail", str(info[1][i][3]))
				ret.append(file)
			return str(ret)
		elif eventID == "rescan_all_files":
			ret = db.re_create_db()
			if ret==0:
				return "0"
			else:
				return "-1"
		elif( eventID == "show_all_media" ):
			ret = []
			info = db.query_files_by_date(0, 0, 0)
			total = info[0]
			for i in range(total):
				file = dict()
				file.setdefault("name", str(info[1][i][0]))
				file.setdefault("path", str(info[1][i][1]))
				file.setdefault("date", str(info[1][i][2]))
				file.setdefault("thumbnail", str(info[1][i][3]))
				ret.append(file)
			return str(ret)
		else:
			pass
	else:
		return -2
