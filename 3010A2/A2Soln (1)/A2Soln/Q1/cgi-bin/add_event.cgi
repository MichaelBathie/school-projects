#!/usr/bin/python

import sys
from os import environ
import os
import json

# I'm just assuming there is one line of query text...
queryText = sys.stdin.readline()

fields = {}
for keyValuePair in queryText.split( '&' ):
  keyValuePair = keyValuePair.strip()
  (key, value) = keyValuePair.split( '=' )
  # need to correct for spaces and new lines (there's probably a better way, but I'm not too concerned here)
  fields[ key ] = value.replace( "+", "%20" ).replace( "%0D%0A", "<br>" )


fileName = "../events/" + fields['person'] + ".json"
# if the file exists, read in the contents
if os.path.isfile(fileName):
  with open(fileName) as eventFile:
    theEvents = json.load(eventFile)
#    theEvents = json.loads( eventFile.read() )

# no file, we need to create an events list (and add the person to the people file)
else:
  theEvents = []
  
  with open("../events/people.json") as peopleFile:
    people = json.load(peopleFile)
#    people = json.loads( peopleFile.readline() )
    
  people.append(fields['person'])

  with open("../events/people.json", "w") as peopleFile:
    json.dump(people, peopleFile)
#    peopleFile.write( json.dumps(people) )
    
    
# build a dictionary for the new event and put it in our event list, in date sorted order
newEvent = {'name': fields['name'], 'date': fields['date'], 'desc': fields['desc']}

# note that I'm simply inserting into an already sorted list....
locn = 0
for nextEvent in theEvents:
	if nextEvent['date'] > newEvent['date']:
		theEvents.insert(locn, newEvent)
		break
	locn += 1
# handle running off the end of the list
if locn == len(theEvents):
	theEvents.append(newEvent)

# write out the new event list, no need to be fancy -- overwriting is fine
with open(fileName, "w") as eventFile:
  json.dump(theEvents, eventFile)
#  eventFile.write( json.dumps(theEvents) )

# return to the main page and have it reload with the new data
print '''Content-type: text/html
Set-Cookie: person={0}

<html><head>
<META HTTP-EQUIV="REFRESH" CONTENT="0;URL=http://www-test.cs.umanitoba.ca/~zapp/cgi-bin/events.cgi">
</head></html>'''.format(fields['person'])
