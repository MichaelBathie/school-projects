#!/usr/bin/python
#Michael Bathie, 7835010

import sys
import os
import json

cookies = {}
#get cookies
if os.environ.has_key('HTTP_COOKIE'):
  for cookie in os.environ['HTTP_COOKIE'].split(';'):
    key, value = cookie.split('=', 1)
    cookies[key] = value

inputs = sys.stdin.readline()
fields = {}
test = 0

#if there was basically nothing entered don't bother
if len(inputs) > 10:
  #parse all the input
  for keyValuePair in inputs.split( '&' ):
    (key, value) = keyValuePair.strip().split( '=' )
    value = value.replace('+', ' ')
    value = value.replace('%2F', '/')
    fields[ key ] = value

  #from https://www.youtube.com/watch?v=QrRcZmDaO_I -------------|
  #Basically how to append a json file in python, just changed it to work with my data structures
  def jsonWrite(data, fileName="People.json"):
      with open (fileName, "w") as f:
          json.dump(data, f, indent=2)
  #open and load in the json file
  with open ("People.json") as file:
    data = json.load(file)
    check = False

    #if that person has already been created
    if(fields["personName"] in data):
      temp = data[fields["personName"]]
      generate = {"name": fields["eventName"], "desc": fields["eventDesc"], "date": fields["eventDate"]}
      temp.append(generate)
      temp.sort(key=lambda x:x['date'])
    #if that person has not been created, create them
    else :
      temp = data
      data["names"].append(fields["personName"])
      data[fields["personName"]] = [{"name": fields["eventName"], "desc": fields["eventDesc"], "date": fields["eventDate"]}]

  #write the data back to the json file to store it
  jsonWrite(data)
  #--------------------------------------------------------------|

print ('Content-Type:text/html')
print
print ('<html><head>')
print ('<title>Calendar</title>')
print ('<script src="events-start.js"></script>')
print ('</head>')
print ('<body onload="loadPeople()">')
print ('<form method="post" action="http://www-test.cs.umanitoba.ca/~bathiem/cgi-bin/Event.cgi">')
print ('<label for="name"> Choose a name: </label>')
print ('<select name="name" id="people" value={this.state.value}  onchange="loadEvents(event)">')
print ('<option value="">Choose a Person</option>')
print ('</select>')
print ('<div id="details"></div>')
print ('<br><br><input type="submit" value="Create a new event">' )
print ('</form>')
print ('<script> window.onload=loadPeople("{}"); </script>').format(cookies["person"])
print ('<script> window.onload=setSelected("{}"); </script>').format(cookies["person"])
print ('</body></html>')