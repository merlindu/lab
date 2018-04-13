#!/usr/bin/env python
#coding=utf-8
#IDS_FILE="ids" 
import re
import sqlite3
import os, sys, datetime
import icatch_funcs

if __name__ == '__main__':
	print '"%s" is being executed as main program, nothing done.' % sys.argv[0]
	os._exit(0)

#config_icathttp="/etc/config/icathttp"
db_file = sys.path[0] + '/videofiles.db'

#date-string type
def query_files_by_date( year, month,day ):
	year = int(year)
	month = int(month)
	day = int(day)
	
	ret = []

	conn = sqlite3.connect(db_file)
	cursor = conn.cursor() 
	
	if year == 0 and month == 0 and day == 0:
		cursor.execute('select * from filelist' )
		items = cursor.fetchall()
	
		cursor.execute( 'select count(*) from filelist' )
		total = cursor.fetchall()[0][0]
	
	else:
		date = datetime.date(year,month,day)
		cursor.execute('select * from filelist where date="' + str(date) + '"' )
		items = cursor.fetchall()
	
		cursor.execute( 'select count(*) from filelist where date="'  + str(date) + '"' )
		total = cursor.fetchall()[0][0]

	cursor.close()
	conn.close()
	ret.append( total )
	ret.append( items )
	
	return ret

def media_path_config_parse():
	file_path = "__read_file_error__"
	pathes=[]
#	try:
#		f = open ( config_icathttp )
#		while True:
#			line = f.readline()
#			if not line:
#				break
#			m = re.match("^file_path\s*=\s*\[.*\]",line)
#			if m is not None:
#				try:
#					file_path = re.split( '=', line.strip() )[1].strip().strip('\"').strip('\'')
#				except IndexError:
#					file_path = "__no_file_path__"
#		f.close()
#	except IOError:
#		pass

#	file_path = re.split( ',', file_path.strip() )
#	for path in file_path:
#		pathes.append(  path.strip().strip('\"').strip('\'') )
#	file_path = pathes

	file_path = '\'' + icatch_funcs.uci_get('httpstation.@httpstation[0].mediapath') + '\''
	file_path = file_path.replace(' ', '\',\'')
	file_path = re.split( ',', file_path.strip() )
	for path in file_path:
		pathes.append(  path.strip().strip('\"').strip('\'') )
	file_path = pathes
	
	return file_path

	
def scan_all_files():
	media_file_path = media_path_config_parse()
	try:
		for path in media_file_path:
			if not os.path.isdir( path ):
				print "Error: a config error has been ignored! path " + path + " does not exists."
				continue
			for filename in os.listdir( path ):
				fullname = path + "/" + filename
				if os.path.isfile( path + "/" + filename ):
					modifydate = datetime.datetime.fromtimestamp( os.path.getmtime( fullname) ).date() 
					thumbnail=thumbnail_generate(path,filename)
					conn = sqlite3.connect(db_file)
					cursor = conn.cursor()
					cursor.execute('insert into filelist values( "' + filename + '","'  \
						+ path +  '","' + str(modifydate) + '","'+ thumbnail + '")')
					cursor.close()
					conn.commit()
					conn.close()
	except Exception, e:
		print "exception: " + str(e)
		return -1	
	return 0

def thumbnail_generate(path,name):
	#thumbnail generate as below
	thumbnail_relative_dir = "asserts/images"
#	store_dir = bottle_py_root + "/" + thumbnail_relative_dir
	store_dir = icatch_funcs.uci_get('httpstation.@httpstation[0].bottlepythonroot') + "/" + thumbnail_relative_dir
	#generate thumbnail in store_dir
	#....
	#
	ret = "thumb_icat.jpg"
	return ret
	
def create_db():
	try:
		conn = sqlite3.connect(db_file)
		cursor = conn.cursor()
#Table filelist
#----------------------------------------------------------
#| filename  |  filefolder  |  date  |  thumbnail  |
#----------------------------------------------------------
		cursor.execute( 'create table filelist( \
						filename varchar(50) NOT NULL, \
						filefolder varchar(200) NOT NULL, \
						date date NOT NULL,\
						thumbnail varchar(200), \
						primary key(filefolder,filename) )' ) 
		cursor.close()
		conn.commit()
		conn.close()
		return 0
	except:
		return -1



if not os.path.exists(db_file):
	create_db()
	scan_all_files()
	
def re_create_db():
	if os.path.exists(db_file):
		os.remove(db_file)
	if 0 != create_db():
		return -1
	return scan_all_files()
