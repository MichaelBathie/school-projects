#!/usr/bin/python
#Michael Bathie, 7835010

import sys
import os

cookies = {}
#get cookies
if os.environ.has_key('HTTP_COOKIE'):
  for cookie in os.environ['HTTP_COOKIE'].split(';'):
    key, value = cookie.split('=', 1)
    cookies[key] = value

print ('Content-Type:text/html')
print
print ('<html><head>')
print ('<title>Event</title>')
print ('<script src="events-start.js"></script>')
print ('</head><body>')
print ('<form method="post" action="http://www-test.cs.umanitoba.ca/~bathiem/cgi-bin/Calendar.cgi">')
print ('Name: <br>')
print ('<input type="text" name="personName" value="{}">').format(cookies["person"])
print ('<br> <br>')
print ('Event Name: <br>')
print ('<input type="text" name="eventName"> <br> <br>')
print ('Event Description: <br>')
print ('<textarea name="eventDesc" style="width:500px; height:200px;"></textarea> <br> <br>')
print ('Date:')
print ('<input type="text" name="eventDate" placeholder="YYYY-MM-DD"> <br> <br>')
print ('<input type="submit" value="Create Event">')
print ('</form>')
print ('</body></html>')