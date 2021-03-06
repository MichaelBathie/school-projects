#!/usr/bin/python

import sys
from os import environ

cookies = {}
cookies['person'] = "No One"
if environ.has_key('HTTP_COOKIE'):
  for cookie in environ['HTTP_COOKIE'].split( ';' ):
    cookie = cookie.strip()
    (key, value) = cookie.split('=', 1)
    cookies[key] = value

print '''Content-type: text/html

<html>
<head>
<script type="text/javascript" src="/~zapp/events/events.js">
</script>
<title>The Amazing Calendaring App</title>
</head>
<body>
<script type="text/javascript">
loadPeople("{0}")
</script>
<form>
<p>People: 
<select id="people" onchange="loadEvents(event)">
</select>
</p>
</form>
<a href=http://www-test.cs.umanitoba.ca/~zapp/cgi-bin/event_form.cgi>Add Event</a>
<div id="details">
<span>
</span>
</div>
</body>
<html>'''.format(cookies['person'])


