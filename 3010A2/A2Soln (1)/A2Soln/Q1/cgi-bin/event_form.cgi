#!/usr/bin/python

import sys
from os import environ

cookies = {}
if environ.has_key('HTTP_COOKIE'):
  for cookie in environ['HTTP_COOKIE'].split( ';' ):
    cookie = cookie.strip()
    (key, value) = cookie.split('=', 1)
    cookies[key] = value

if not cookies.has_key('person') or cookies['person'] == "No One":
  cookies['person'] = ""

print '''Content-type: text/html

<html><head><title>Add Event</title></head>
<body>
<form method=POST action=http://www-test.cs.umanitoba.ca/~zapp/cgi-bin/add_event.cgi>
Please enter the event information.<br><br>
User: <input type=text name="person" value="{0}">
Event Name: <input type=text name="name"><br>
Date (yyyy-mm-dd): <input type=text name="date"><br>
Event Description:<br> <TEXTAREA NAME="desc" ROWS=5 COLS=80></TEXTAREA><br>
<input type=submit value="Add Event"><br>
</form>
</body></html>'''.format(cookies['person'])
