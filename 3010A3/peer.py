#!/usr/bin/python
#Comp 3010 Assignment 3
#Michael Bathie, 7835010
#bathiem

import socket
import select
import os
import sys
import random
import json
import datetime
import pprint



def get_time():
	return "["+datetime.datetime.now().strftime("%m/%d/%Y, %H:%M:%S")+"]"


#Class State:
#Using this to keep track of the state of my node
#
#Hostname, port, id, successor, and pred are as they're specified in the assignment
#
#last_known_node: Keeps track of the last node that I got a response from. This way if I run into a timeout
#while trying to join the ring I know where my spot is.
#
#joining, querying, and user_querying are just boolean values to check if any of those things are currently happening.
#querying and user_query will be true if i have either a query from another node or a query from myself that has yet to
#be handled.
#
#current_query and current_user_query are how i'm storing queries if i can't handle them immediately. This way I can still
#send them off after something like a stabilization
#
#first_enter: boolean checking if it's my first time entering the ring, tells me if i need to print my pred or not.
#
#timeout: boolean telling me if i need a timeout or not 
class State:
	def __init__(self, my_hostname, my_port):
		self.hostname = my_hostname
		self.port = my_port
		self.id = 0
		self.successor = 0
		self.pred = {"hostname": "silicon.cs.umanitoba.ca", "port": 15000, "ID": 0}
		self.last_known_node = 0
		self.joining = True
		self.querying = False
		self.current_query = 0
		self.user_querying = False
		self.current_user_query = 0
		self.first_enter = True
		self.timeout = True



	#returns a dictionary of myself. In most cases i found when i needed one part of my state i ended up needing the
	#rest of it too, so I found it easiest to just return a dictionary
	def who_am_i(self):
		return {"hostname": self.hostname, "port": self.port, "ID": self.id}



	def set_id(self, new_id):
		self.id = new_id



	def set_successor(self, successor):
		self.successor = successor



	def print_successor(self):
		print("{0}: Updating successor to: ".format(get_time())),
		pprint.pprint(self.successor)
		print("")



	#specify what info I want on the successor as the string "info" and return it
	def successor_info(self, info):
		message = ""

		if info == "hostname":
			message = self.successor["hostname"]
		elif info == "port":
			message = self.successor["port"]
		else:
			message = self.successor["ID"]

		return message



	def set_pred(self, pred):
		self.pred = pred



	def print_pred(self):
		print("{0}: Updating predecessor to: ".format(get_time())),
		pprint.pprint(self.pred)
		print("")



	#same as successor_info
	def pred_info(self, info):
		message = ""

		if info == "hostname":
			message = self.pred["hostname"]
		elif info == "port":
			message = self.pred["port"]
		else:
			message = self.pred["ID"]

		return message


	def pred_plus_succ(self):
		print("\t\t{0}: succ={1}".format(get_time(), self.successor))
		print("\t\t{0}: pred={1}\n".format(get_time(), self.pred))



	def timeout_op(self, op):
		if op == "on":
			self.timeout = True
		elif op == "off":
			self.timeout = False
		elif op == "check":
			return self.timeout



	def joining_op(self, op):
		if op == "on":
			self.joining = True
		elif op == "off":
			self.joining = False
		elif op == "check":
			return self.joining



	#have i entered the ring before
	def check_first_enter(self):
		return self.first_enter



	def set_last_known_node(self, node):
		self.last_known_node = node



	def query_op(self, op, query):
		if op == "on":
			self.querying = True
		elif op == "off":
			self.querying = False
		elif op == "check":
			return self.querying
		elif op == "set":
			self.current_query = query



	def user_query_op(self, op, query):
		if op == "on":
			self.user_querying = True
		elif op == "off":
			self.user_querying = False
		elif op == "check":
			return self.user_querying
		elif op == "set":
			self.current_user_query = query



	#check to see if i've found a previous incarnation of myself
	def found_myself(self, pred):
		return_val = False
		try:
			if (isinstance(pred, dict) and (pred["hostname"] == self.hostname and int(pred["port"]) == self.port and int(pred["ID"]) == self.id)):
				return_val =  True
			else:
				return_val = False
		except:
			return_val = False

		return return_val


#Note: Parameters my_socket and state are the same in every function
#my_socket: just passing the socket around to perform sends
#state: passing around the state to set and check state values


#can be used to randomly generate an ID to join the ring 
def gen_id():
	return (random.randint(1, 65534))



#random query value
def gen_query():
	return (random.randint(1, 65534))



#re-joins the ring from bootstrap
def join_ring(the_socket, state):
	my_socket = the_socket
	my_state = state

	#hardcoded bootstrap
	bootstrap = ("silicon.cs.umanitoba.ca", 15000)

	#setting the last known node incase the pred of this node doesn't reply
	bootstrap_dict = {"hostname": "silicon.cs.umanitoba.ca", "port": 15000, "ID": 65535}
	my_state.set_last_known_node(bootstrap_dict)

	#create the message to ask for pred
	message = {"cmd": "pred?", "port": 15083, "ID": state.id, "hostname": str(socket.getfqdn())}
	message = json.dumps(message)

	#setting our state so we know we're currently attempting to join the ring
	my_state.joining_op("on")

	#need a timeout because we're about to send a pred? message
	my_state.timeout_op("on")

	#if we're disconnected from the ring we're going to have to join at the bootstrap node
	my_socket.sendto(message, bootstrap)



#come here whenever we get a pred? message, need to return our current pred.
#the_sender: The exact message that was sent to us as a dictionary
def handle_pred(the_socket, state, the_sender):
	my_socket = the_socket
	my_state = state
	sender = the_sender

	#i'm going to need my own state here to make a variable
	me = my_state.who_am_i()

	#who do we want to reply to
	addr = (sender["hostname"], int(sender["port"]))

	#if our pred has been set by someone, or we actually have a pred
	message = {"me": {"hostname": me["hostname"], "port": me["port"], "ID": me["ID"]}, "cmd": "myPred", "thePred": {"hostname": my_state.pred_info("hostname"), "ID": my_state.pred_info("ID"), "port": my_state.pred_info("port")}}
	message = json.dumps(message)

	print("{0}: Sending pred to {1}\n".format(get_time(), str(addr)))

	my_socket.sendto(message, addr)



#we received a myPred message, a lot of state to check here.
#the_sender: dictionary of who sent the data
#the_pred: dictionary of who their pred is
def handle_myPred(the_socket, state, the_sender, the_pred):
	my_socket = the_socket
	my_state = state
	sender = the_sender
	pred = the_pred
	me = my_state.who_am_i()

	#we asked someone for their pred and got a reply so this is currently the last known node
	my_state.set_last_known_node(the_sender)

	#if we're currently joining the ring
	if my_state.joining_op("check"):

		#Some people have been sending 0 as unset pred so handle that if it comes
		if (isinstance(pred, str) or isinstance(pred, int)):
			if (int(pred) == 0 or str(pred) == "0"):
				pred_id = 0

		#otherwise they do have a pred so i can just take that preds id
		else:
			pred_id = int(pred["ID"])

		#Found previous incarnation of myself
		#** or **
		#if i found my spot based on id checking
		if (pred_id <= me["ID"]):

			#set my new successor
			my_state.set_successor(the_sender)

			message = {"cmd": "setPred", "port": me["port"], "ID": me["ID"], "hostname": me["hostname"]}
			message = json.dumps(message)
			
			#check if you've entered the ring before, if you're rejoining print current pred
			if not my_state.check_first_enter():
				print("{0}: (re)joined the ring".format(get_time()))
				my_state.pred_plus_succ()
			else:
				print("{0}: joined the ring".format(get_time()))
				my_state.print_successor()

			addr = (my_state.successor_info("hostname"), my_state.successor_info("port"))

			#let my successor know that i'm its new pred
			my_socket.sendto(message, addr)

			#This means i'm currently handling a user_query (id number entered from command line).
			#I just finished joining the ring so i'm stabilized, send out the query
			if my_state.user_query_op("check", ""):
				user_message = json.dumps(my_state.current_user_query)
				my_socket.sendto(user_message, addr)
				my_state.user_query_op("off", "")

			#same as above but for queries from other nodes
			if my_state.query_op("check", ""):
				query_message = json.dumps(my_state.current_query)
				my_socket.sendto(query_message, addr)
				my_state.query_op("off", "")

			#finished joining
			my_state.joining_op("off")

			#don't need a timeout, no outgoing pred? messages
			#this call is also in the socket handler but it needs to be here as well as this fucntion
			#can called without going to the handler (through a timeout)
			my_state.timeout_op("off")

			#i entered the ring so it's not my first time anymore
			my_state.first_enter = False

		#I have yet to find my spot in the ring so send a pred? message to the next node to keep looking
		else:
			message = {"cmd": "pred?", "port": me["port"], "ID": me["ID"], "hostname": me["hostname"]}
			message = json.dumps(message)

			pred_addr = (pred["hostname"], int(pred["port"]))

			#about to send pred? so we need a timeout
			my_state.timeout_op("on")

			my_socket.sendto(message, pred_addr)

	#we're not currently trying to join the ring so we probably received a query and are stabilzing.
	#this means we need to check if the pred sent back is us, if it's not we need to re join the ring.
	else:

		#boolean to check if the pred of my successor is me
		not_me = False

		#make sure they actually have a pred set
		if isinstance(pred, dict):
			me = my_state.who_am_i()

			#im their pred so we're good
			if (pred["hostname"] == me["hostname"]) and (pred["port"] == me["port"]) and (pred["ID"] == me["ID"]):
				
				addr = (my_state.successor_info("hostname"), int(my_state.successor_info("port")))

				#being here means we don't have to re-join the ring, we're already stabilized

				#if we have any queries send them out
				if my_state.query_op("check", ""):

					query_message = json.dumps(my_state.current_query)
					my_socket.sendto(query_message, addr)
					my_state.query_op("off", "")

				if my_state.user_query_op("check", ""):

					user_message = json.dumps(my_state.current_user_query)
					my_socket.sendto(user_message, addr)
					my_state.user_query_op("off", "")

			#the pred is not me, gotta re-join the ring
			else:
				#the entire purpose of the succ_working_pred is, if I send someone a pred? while stabilizing
				#and it fails (their pred isn't me) I can just join the ring from that node instead of going up
				#to the bootstrap again
				join_ring(my_socket, my_state)

		#successor doesn't have a valid pred so obviously it's not me, re-join the ring
		else:
			not_me = True

		if not_me:
			join_ring(my_socket, my_state)



#we got a setPred message, so set our pred with the message
#the_sender: the exact message that was sent to me
#if this function is called it has already been confirmed that the_sender's id is less than mine
def handle_setPred(the_socket, state, the_sender):
	my_socket = the_socket
	my_state = state
	sender = the_sender

	new_pred = {"hostname": sender["hostname"], "port": int(sender["port"]), "ID": int(sender["ID"])}

	my_state.set_pred(new_pred)

	my_state.print_pred()



#we got a find message from some other node in the ring.
#query: the exact message that was sent to us
#hops has already been incremented in a previous function
def handle_find(the_socket, state, query):
	my_socket = the_socket
	my_state = state
	my_query = query
	me = my_state.who_am_i()

	#setting state to hold on to this query incase i must re-join to handle it
	#and setting state to say that im currently handling a query from another node
	my_state.query_op("set", my_query)
	my_state.query_op("on", "")

	#if my id is greater than the query value i can handle it
	if (int(me["ID"]) >= int(my_query["query"])):

		addr = (my_query["hostname"], int(my_query["port"]))

		#easier to just modify their message and send it back to them
		my_query["hostname"] = me["hostname"]
		my_query["port"] = me["port"]
		my_query["ID"] = me["ID"]
		my_query["cmd"] = "owner"

		message = json.dumps(my_query)

		#not handling a query anymore
		my_state.query_op("off", "")

		my_socket.sendto(message, addr)

	#I cannot handle this query, gotta pass it up to my successor
	#In this case I want to stabilize. One caveate though, if i'm currently joining the ring through a
	#stabilization I don't want to ask for my successor again. Instead I won't do anything as from the top
	#if this function i've already overwritten the query so i'll just handle it after the join through checks
	#you can see in handle_myPred
	elif not my_state.joining_op("check"):

		#before i pass this query up to my successor i need to make sure my successor thinks im its pred
		addr = (my_state.successor_info("hostname"), int(my_state.successor_info("port")))

		message = {"cmd": "pred?", "port": me["port"], "ID": me["ID"], "hostname": me["hostname"]}
		message = json.dumps(message)

		#about to send pred? so i better have a timeout
		my_state.timeout_op("on")
		my_socket.sendto(message, addr)


#got an owner message, all i need here is what they sent me to print it out
def handle_owner(message):
	msg = message

	owner = {"hostname": msg["hostname"], "port": msg["port"], "ID": msg["ID"]}

	print("{0}: It took {1} hops for our query to be answered. The owner was: ".format(get_time(), msg["hops"])),
	pprint.pprint(owner)
	print("")


#this function will take care of anything the user types in on the command prompt
#message: whatever they typed in
def handle_user(the_socket, state, message):
	msg = message.strip()
	my_socket = the_socket
	my_state = state
	me = my_state.who_am_i()

	#return with nothing indicate you need to stop the program
	if not msg:
		print("user ended process...\n")
		my_socket.close()
		sys.exit()

	#otherwise we have a query
	elif msg.isdigit():
		query = int(msg)

		#while query is out of bounds generate new ones
		while not(query > my_state.id and query < 65536):
			query = gen_query()

		#we're not handling a user query
		my_state.user_query_op("on", "")

		new_query = {"cmd": "find", "hostname": me["hostname"], "port": me["port"], "ID": me["ID"], "hops": 0, "query": query}

		#store the query incase we can't send it out right away
		my_state.user_query_op("set", new_query)

		#this check follows the same logic as it does in the handle_find above.
		if not my_state.joining_op("check"):
			addr = (my_state.successor_info("hostname"), int(my_state.successor_info("port")))

			message = {"cmd": "pred?", "port": me["port"], "ID": me["ID"], "hostname": me["hostname"]}
			message = json.dumps(message)

			my_state.timeout_op("on")
			my_socket.sendto(message, addr)

	#assuming it's fine to ignore everything else the user could type in


#takes care of anything that's valid enough and came through my socket
#data: the message that was sent to my socket
def handle_socket(the_socket, state, data):
	my_socket = the_socket
	my_state = state
	msg = data

	try:
		#get the command
		cmd = msg["cmd"].strip()
	except:
		print("{0}: Message received had no cmd, ignoring...\n".format(get_time()))

	#check which command we're dealing with
	if cmd == "pred?":

		handle_pred(the_socket, my_state, msg)

	elif cmd == "myPred":

		#easier to split up sender and pred instead of sending the whole message to handler
		sender = msg["me"]
		pred = msg["thePred"]

		#if a myPred was received we can turn off the timeout for now
		my_state.timeout_op("off")
		handle_myPred(my_socket, my_state, sender, pred)

	elif cmd == "setPred":
		
		#make sure this is someone who can actually be my pred
		if int(msg["ID"]) < my_state.id:
			handle_setPred(my_socket, my_state, msg)

		#otherwise dont let them
		else:
			print("Someone tried to set my pred with a higher id than me!".format(get_time()))
			pprint.pprint(msg)
			print("")

			addr = (msg["hostname"], int(msg["port"]))
			warning = "You're trying to set yourself as my pred when your id is higher than mine!"
			my_socket.sendto(warning, addr)

	elif cmd == "find":
		
		#store the query we received
		my_state.query_op("set", msg)

		#might as well set the hops now
		msg["hops"] = int(msg["hops"]) + 1

		handle_find(my_socket, my_state, msg)

	elif cmd == "owner":

		handle_owner(msg)

	else:

		#so i can see what kind of messages other people are sending me
		print("{0}: Got a whacky cmd message --> {1}".format(get_time(), cmd))



if __name__ == "__main__":
	done = False

	#keep track of our state as we move through the program in order to 
	#messages correctly depending on what we're doing.
	my_state = State(socket.getfqdn(), 15083)

	#if we're not passed an ID at runtime just randomly generate one to join with
	if len(sys.argv) == 1:
		my_state.set_id(gen_id())

	#otherwise we're taking the value that was passed as an arg
	else:
		id_arg = int(sys.argv[1])

		if id_arg >= 1 and id_arg <= 65534:
			my_state.set_id(id_arg)

		#if the id passed isn't valid just generate one
		else:
			my_state.set_id(gen_id())

	print("My id is --> {0}".format(my_state.id))
	print("Make sure to use the same id if you're re-running from the same machine!")

	#my address and port
	address = ('', 15083)

	my_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

	try:
	    my_socket.bind(address)

  	except socket.error as e:
	    print "could not bind with '{0}'".format(e.strerror)
	    my_socket.close()
	    done = True

	#join the ring for the first time
	join_ring(my_socket, my_state)

	#file descriptor for my socket
	socketfd =  my_socket.fileno()

	#simultaneously block on our socket and stdin. 
	while not done:

		try:
			#check state to determine if we're going to need a timeout or not
			if my_state.timeout_op("check"):
				(readers, writers, errors) = select.select([socketfd, sys.stdin], [], [], 2)
			else:
				(readers, writers, errors) = select.select([socketfd, sys.stdin], [], [])

			if not readers:

				#this is basically saying, im trying to join a ring and someone didn't reply with their pred.
				#In this case im just going to set myself as their pred.
				if my_state.joining_op("check"):
					print("{0}: Timeout! Someone didn't reply with their pred when I was joining the ring. I'm going to join at the last known node.\n".format(get_time()))

					#pretending I received a myPred message but passing my last known node as the sender of the message and 0 as the pred.
					#this simulates the last known node as not having a pred at all so I automatically insert myself there.
					handle_myPred(my_socket, my_state, my_state.last_known_node, 0)

				#successor didn't reply with their pred on stabilization before sending query, have to re-join the ring from bootstrap
				elif my_state.query_op("check", "") or my_state.user_query_op("check", ""):
					print("{0}: Timeout! I was trying to query but my successor didn't reply to my \"pred?\" message. I'm going to re-join the ring from the bootstrap\n".format(get_time()))
					join_ring(my_socket, my_state)

			else:

				for msg in readers:

					#message from the user
					if msg ==  sys.stdin:

						#read it in and handle it
						user_data = sys.stdin.readline()

						handle_user(my_socket, my_state, user_data)

					#from the socket
					elif msg == socketfd:

						#receive json object from our socket.
						data = my_socket.recv(4096)

						#used incase what was sent wasn't a json object so i can print
						#it to see what it is
						temp_store = data

						try:
							data = json.loads(data)
						except:
							print("{0}: Received message that wasn't a json object, ignoring... {1}\n".format(get_time(), temp_store))

						#message is valid
						if isinstance(data, dict):
							#print out whatever i receive for testing
							#pprint.pprint(data)
							handle_socket(my_socket, my_state, data)

		#Everything below is cleanup
		#Specfically to catch socket errors
		except socket.error as e:
			print(e)
			print("socket error --> quitting...\n")
			my_socket.close()
			done = True

		#using this to catch every other exception that was showing up
		except Exception:
			print("stopped --> quitting...\n")
			my_socket.close()
			done = True