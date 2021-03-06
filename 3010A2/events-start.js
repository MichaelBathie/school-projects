// global request and XML document objects
var peopleReq = new XMLHttpRequest();
var eventsReq = new XMLHttpRequest();
var currName = "No One";
var myPeople = ["No One"];

//set the name that should be selected (from cookies) on page load
function setSelected(theName) {
  var ele = document.getElementById("people").options;
  var i = 0;

  while (i < ele.length) {
    if (ele[i].text  === theName)
      break;
    i++;
  }

  document.getElementById("people").selectedIndex = i;
}

// retrieve people list
function loadPeople(name)
{ 
  // load in the current person as well
  currName = name
  
  // TODO: insert retrieval code here
  peopleReq.onreadystatechange = processPeopleReq;
  peopleReq.open('GET', 'People.json', true);
  peopleReq.setRequestHeader("Cache-Control", "no-cache", "no-store", "must-revalidate");
  peopleReq.send(null);
  
}

// handle receiving of people list
function processPeopleReq()
{ 
  // only if req shows "loaded"
  if (peopleReq.readyState == 4)
  { 
    // only if "OK"
    if (peopleReq.status == 200)
    { 
      var myJSONTxt = peopleReq.responseText;
      myPeople = JSON.parse(myJSONTxt);
      myPeople = myPeople["names"];

      buildPeopleList();

      // only load events if we actually have data...
      if ( myPeople.length > 0 )
      {
        // if we don't have a valid cookie, just pick the first one -- not required by assignment
        if (currName == "No One" && myPeople.length)
        {
          currName = myPeople[0];
        }

        if (currName != "")
        {
          doEventRequest();
        }
      }
      // default text if there's no people data
      else
      {
        div = document.getElementById("details");
        div.innerHTML = "<h1>Events</h1><hr/>";
      }
    }
    else
    {
      alert("There was a problem retrieving the people list:\n" + peopleReq.statusText);
    }
  }
}

// add item to select element the less
// elegant, but compatible way.
function appendToSelect(select, value, content, name)
{
  var opt;
  opt = document.createElement("option");
  opt.value = value;

  // make sure we select the current option -- not required but it looks better
  if ( name == currName )
    opt.selected = true;

  opt.appendChild(content);
  select.appendChild(opt);
}

// fill People select list with items
function buildPeopleList()
{
  var select = document.getElementById("people");
  var activeCurr = false;

  // add each person to the People select element
  for (var i = 0; i < myPeople.length; i++)
  {
    appendToSelect(select, i, document.createTextNode(myPeople[i]), myPeople[i] );

    if (myPeople[i] == currName)
      activeCurr = true;
  }

  // make sure that the current name we have from a cookie is still alive
  if (!activeCurr)
    currName = "No One";
}

function doEventRequest()
{
  // TODO: insert event retrieval request
  eventsReq.onreadystatechange = processEventsReq;
  eventsReq.open('GET', 'People.json', true);
  eventsReq.send(null);

  // would be nice to remember each change...
  document.cookie = "person=" + currName;
}

//retrieve event list for the selected person
function loadEvents(event) //**this probably goes in the select element
{
  // get the key for the selected person
  //var selected = document.getElementById("people").value
  currName = myPeople[event.target.value];

  doEventRequest();
}

//retrieve event list for the selected person
function loadEvents(event) //**this probably goes in the select element
{
  // get the key for the selected person
  //var selected = document.getElementById("people").value
  currName = myPeople[event.target.value];

  doEventRequest();
}

// handle receiving of event list
function processEventsReq()
{
  // only if req shows "loaded"
  if (eventsReq.readyState == 4)
  {
    // only if "OK"
    if (eventsReq.status == 200)
    {
      var content = "<h2>" + currName + "'s Events</h2>\n<hr/>\n";
      var myJSONTxt = eventsReq.responseText;
      var people = JSON.parse(myJSONTxt);
      var myEvents = people[currName];

      for (var i = 0; i < myEvents.length; i++)
      {
        // get information for each event and build up my HTML
        content += "<p><b>" + unescape(decodeURI(myEvents[i].name));
        content += "</b><br>\n<i>" + myEvents[i].date + "</i><br><br>\n" + unescape(decodeURI(myEvents[i].desc)) + "\n</p>\n\n";
      }

      div = document.getElementById("details");
      div.innerHTML = "";
      // blast new HTML content into "details" <div>
      div.innerHTML = content;
    }
    else
    {
      alert("There was a problem retrieving the event data:\n" +
            eventsReq.statusText);
    }
  }
}