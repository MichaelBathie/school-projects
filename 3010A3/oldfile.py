#!/usr/bin/python
#Michael Bathie, 7835010

import traceback
import socket
import select
import os
import sys
import random
import json
import copy
import datetime
import pprint

class State:
	def __init__(self, my_hostname, my_port):
		self.hostname = my_hostname
		self.port = my_port
		self.id = 0
		self.successor = 0
		self.pred = 0
		self.last_known_node = 0
		self.joining = True
		self.querying = False
		self.current_query = 0
		self.user_querying = False
		self.current_user_query = 0
		self.first_enter = True
		self.timeout = True

	def get_time(self):
		return datetime.datetime.now().strftime("%m/%d/%Y, %H:%M:%S")

	def who_am_i(self):
		return {"hostname": self.hostname, "port": self.port, "ID": self.id}

	def set_id(self, new_id):
		self.id = new_id

	def set_successor(self, successor):
		self.successor = successor

	def print_successor(self):
		print("My successor:")
		pprint.pprint(self.successor)
		print("")

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
		print("My pred:")
		pprint.pprint(self.pred)
		print("")

	def pred_info(self, info):
		message = ""

		if info == "hostname":
			message = self.pred["hostname"]
		elif info == "port":
			message = self.pred["port"]
		else:
			message = self.pred["ID"]

		return message

	def need_timeout(self):
		self.timeout = True

	def no_timeout(self):
		self.timeout = False

	def check_timeout(self):
		return self.timeout

	def timeout_op(self, op):
		if op == "on":
			self.timeout = True
		elif op == "off":
			self.timeout = False
		elif op == "check":
			return self.timeout

	def currently_joining(self):
		self.joining = True

	def not_joining(self):
		self.joining = False

	def check_joining(self):
		return self.joining

	def check_first_enter(self):
		return self.first_enter

	def set_last_known_node(self, node):
		self.last_known_node = node

	def have_query(self):
		return self.querying

	def handling_query(self):
		self.querying = True

	def not_handling_query(self):
		self.querying = False

	def set_current_query(self, query):
		self.current_query = query

	def have_user_query(self):
		return self.user_querying

	def handling_user_query(self):
		self.user_querying = True

	def not_handling_user_query(self):
		self.user_querying = False

	def set_current_user_query(self, query):
		self.current_user_query = query

	def found_myself(self, pred):
		if (isinstance(pred, dict) and (pred["hostname"] == self.hostname and int(pred["port"]) == self.port and int(pred["ID"]) == self.id)):
			return True
		else:
			return False


#can be used to randomly generate an ID to join the ring 
def gen_id():
	return (random.randint(1, 65534))

def gen_query():
	return (random.randint(1, 65534))

def join_ring(the_socket, state):
	my_socket = the_socket
	my_state = state

	bootstrap = ("silicon.cs.umanitoba.ca", 15000)

	#create the message to ask for pred
	message = {"cmd": "pred?", "port": 15083, "ID": state.id, "hostname": str(socket.getfqdn())}
	message = json.dumps(message)

	#setting the last known node incase the pred of this node doesn't reply
	bootstrap_dict = {"hostname": "silicon.cs.umanitoba.ca", "port": 15000, "ID": 65535}
	my_state.set_last_known_node(bootstrap_dict)

	#setting our state so we know we're currently attempting to join the ring
	my_state.currently_joining()

	#need a timeout because we're about to send a pred? message
	my_state.need_timeout()

	#if we're disconnected from the ring we're going to have to join at the bootstrap node
	my_socket.sendto(message, bootstrap)


def handle_pred(the_socket, state, the_sender):
	my_socket = the_socket
	my_state = state
	sender = the_sender

	addr = (sender["hostname"], int(sender["port"]))

	if isinstance(my_state.pred, dict):

		message = {"me": {"hostname": str(socket.getfqdn()), "port": 15083, "ID": my_state.id}, "cmd": "myPred", "thePred": {"hostname": my_state.pred_info("hostname"), "ID": my_state.pred_info("ID"), "port": my_state.pred_info("port")}}
		message = json.dumps(message)
		my_socket.sendto(message, addr)

	else:

		message = json.dumps(my_state.pred)
		my_socket.sendto(message, addr)

def handle_myPred(the_socket, state, the_sender, the_pred):
	my_socket = the_socket
	my_state = state
	sender = the_sender
	pred = the_pred

	my_state.set_last_known_node(the_sender)

	if my_state.check_joining():

		#If the node i asked doesn't have a pred i'm going to say that its pred ID is 0.
		#This will make it so ill automatically set myself as its pred
		if (isinstance(pred, str) or isinstance(pred, int)):
			if (int(pred) == 0 or str(pred) == "0"):
				pred_id = 0
		else:
			pred_id = int(pred["ID"])

		#this entire if statement is check if i found a previous incarnation of myself. If this happens I obviously want
		#to overwrite it as having 2 of myself in the ring is not good. 
		#** or **
		#if i found my spot based on id checking
		if (isinstance(pred, dict) and (pred["hostname"] == str(socket.getfqdn()) and int(pred["port"]) == 15083 and int(pred["ID"]) == my_state.id)) or (pred_id < my_state.id):

			#set my new successor
			my_state.set_successor(the_sender)
			print("New successor!")
			my_state.print_successor()

			message = {"cmd": "setPred", "port": 15083, "ID": state.id, "hostname": str(socket.getfqdn())}
			message = json.dumps(message)
			
			#check if you've entered the ring before, if you're rejoining print current pred
			if not my_state.check_first_enter():
				my_state.print_pred()

			addr = (my_state.successor_info("hostname"), my_state.successor_info("port"))

			my_socket.sendto(message, addr)

			if my_state.have_user_query():
				user_message = json.dumps(my_state.current_user_query)
				my_socket.sendto(user_message, addr)
				my_state.not_handling_user_query()

			if my_state.have_query():
				query_message = json.dumps(my_state.current_query)
				my_socket.sendto(query_message, addr)
				my_state.not_handling_query()

			my_state.not_joining()
			my_state.first_enter = False

		#gotta keep looking
		else:
			message = {"cmd": "pred?", "port": 15083, "ID": state.id, "hostname": str(socket.getfqdn())}
			message = json.dumps(message)

			pred_addr = (pred["hostname"], int(pred["port"]))

			#about to send pred? so we need a timeout
			my_state.need_timeout()

			my_socket.sendto(message, pred_addr)

	#we're not currently trying to join the ring so we probably received a query and are stabilzing.
	#this means we need to check if the pred sent back is us, if it's not we need to re join the ring.
	else:
		not_me = False

		if isinstance(pred, dict):
			me = my_state.who_am_i()

			#im their pred so we're good
			if (pred["hostname"] == me["hostname"]) and (pred["port"] == me["port"]):
				
				addr = (my_state.successor_info("hostname"), int(my_state.successor_info("port")))

				if my_state.have_query():

					query_message = json.dumps(my_state.current_query)
					my_socket.sendto(query_message, addr)
					my_state.not_handling_query()

				if my_state.have_user_query():

					user_message = json.dumps(my_state.current_user_query)
					my_socket.sendto(user_message, addr)
					my_state.not_handling_user_query()

			else:
				not_me = True
		else:
			not_me = True

		if not_me:
			join_ring(my_socket, my_state)


def handle_setPred(the_socket, state, the_sender):
	my_socket = the_socket
	my_state = state
	sender = the_sender

	new_pred = {"hostname": sender["hostname"], "port": int(sender["port"]), "ID": int(sender["ID"])}

	print("My new pred:")
	pprint.pprint(new_pred)
	print("")

	my_state.set_pred(new_pred)

def handle_find(the_socket, state, query):
	my_socket = the_socket
	my_state = state
	my_query = query
	me = my_state.who_am_i()

	my_state.set_current_query(my_query)
	my_state.handling_query()

	#I can handle the query
	if (int(me["ID"]) >= int(my_query["query"])):

		addr = (my_query["hostname"], int(my_query["port"]))

		my_query["hostname"] = me["hostname"]
		my_query["port"] = me["port"]
		my_query["ID"] = me["ID"]
		my_query["cmd"] = "owner"

		message = json.dumps(my_query)

		my_state.not_handling_query()

		my_socket.sendto(message, addr)

	#I cannot handle this query, gotta pass it up to my successor
	#If im currently rejoining the ring because of a stabilization I don't want to ask who my succ is again
	#so i just stored the message above
	elif not my_state.check_joining():

		#before i pass this query up to my successor i need to make sure my successor thinks im its pred
		addr = (my_state.successor_info("hostname"), int(my_state.successor_info("port")))

		message = {"cmd": "pred?", "port": me["port"], "ID": me["ID"], "hostname": me["hostname"]}
		message = json.dumps(message)

		my_state.need_timeout()
		my_socket.sendto(message, addr)



def handle_owner(message):
	msg = message

	owner = {"hostname": msg["hostname"], "port": msg["port"], "ID": msg["ID"]}

	print("It took {0} hops for our query to be answered. The owner was:".format(msg["hops"]))
	pprint.pprint(owner)

def handle_user(the_socket, state, message):
	msg = message.strip()
	my_socket = the_socket
	my_state = state
	me = my_state.who_am_i()

	if not msg:
		print("user ended process...\n")
		my_socket.close()
		sys.exit()

	elif msg.isdigit():
		query = int(msg)

		while not(query > my_state.id and query < 65536):
			query = gen_query()

		my_state.handling_user_query()

		new_query = {"cmd": "find", "hostname": me["hostname"], "port": me["port"], "ID": me["ID"], "hops": 0, "query": query}
		my_state.set_current_user_query(new_query)

		if not my_state.check_joining():
			addr = (my_state.successor_info("hostname"), int(my_state.successor_info("port")))

			message = {"cmd": "pred?", "port": me["port"], "ID": me["ID"], "hostname": me["hostname"]}
			message = json.dumps(message)

			my_state.need_timeout()
			my_socket.sendto(message, addr)



def handle_socket(the_socket, state, data):
	my_socket = the_socket
	my_state = state
	msg = data

	cmd = msg["cmd"].strip()

	if cmd == "pred?":

		handle_pred(the_socket, my_state, msg)

	elif cmd == "myPred":

		sender = msg["me"]
		pred = msg["thePred"]

		handle_myPred(my_socket, my_state, sender, pred)

	elif cmd == "setPred":
		
		if msg["ID"] < my_state.id:
			handle_setPred(my_socket, my_state, msg)
		else:
			print("Someone tried to set my pred with a higher id than me!")
			pprint.pprint(msg)

	elif cmd == "find":
		
		my_state.set_current_query(msg)
		msg["hops"] = int(msg["hops"]) + 1

		handle_find(my_socket, my_state, msg)

	elif cmd == "owner":

		handle_owner(msg)

	else:
		print("Got a whacky cmd message --> {0}".format(cmd))

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
		else:
			print("Sorry, the id must be inbetween or equal to 1 and 65534. Please run the program again!\n") 
			sys.exit()

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


	join_ring(my_socket, my_state)

	#file descriptor for my socket
	socketfd =  my_socket.fileno()

	#simultaneously block on our socket and stdin. 
	while not done:
		try:

			#check state to determine if we're going to need a timeout or not
			if my_state.check_timeout():
				(readers, writers, errors) = select.select([socketfd, sys.stdin], [], [], 2)
			else:
				(readers, writers, errors) = select.select([socketfd, sys.stdin], [], [])

			for msg in readers:
				if msg ==  sys.stdin:
					user_data = sys.stdin.readline()

					handle_user(my_socket, my_state, user_data)

				elif msg == socketfd:

					my_state.no_timeout()
					#whoever we sent a pred? message to didn't reply
					if not readers:

						#this is basically saying, im trying to join a ring and someone didn't reply with their pred.
						#In this case im just going to set myself as their pred.
						if my_state.check_joining():
							handle_myPred(my_socket, my_state, my_state.last_known_node, 0)

						elif my_state.have_query() or my_state.have_user_query():
							join_ring(my_socket, my_state)

					else:
						#receive json object from our socket.
						data = my_socket.recv(4096)

						#basically just using this to catch messages from prof
						temp_store = data

						data = json.loads(data)

						if isinstance(data, dict):
							pprint.pprint(data)
							print("")
							handle_socket(my_socket, my_state, data)
						else:
							print("Received message that wasn't a json string --> {0}".format(temp_store))

				else:
					#honestly have no idea how you're here
					#but something is definitely wrong.
					print("what is going on")

		#cleanup
		except socket.error as e:
			print(e)
			print("error --> quitting...\n")
			my_socket.close()
			done = True
		except Exception:
			print(traceback.format_exc())
			print("stopped --> quitting...\n")
			my_socket.close()
			done = True

		

	