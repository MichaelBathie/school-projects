#!/usr/bin/python

#--------------------------------------------------------------------
#  Student Name: <Michael Bathie>
#  Student ID: <7835010>
#  Section: <A02>
#--------------------------------------------------------------------

import sys
import random

timeslice = 5

prio_count = {"0": 0, "1": 0, "2": 0}
prio_time = {"0total": 0, "1total": 0, "2total": 0}
type_count = {"0": 0, "1": 0, "2": 0, "3": 0}
type_time = {"0total": 0, "1total": 0, "2total": 0, "3total": 0}

class Process:
	def __init__(self, thread_name, thread_type, thread_prio, thread_time, io_odds):
		self.thread_name = thread_name
		self.thread_type = int(thread_type)
		self.thread_prio = int(thread_prio)
		self.thread_time = int(thread_time)
		self.io_odds = int(io_odds)

	#for testing
	def tostring(self):
		return "name is {}, type is {}, prio is {}, time left is {}, io odds is {}.\n".format(self.thread_name, self.thread_type, self.thread_prio, self.thread_time, self.io_odds)

	#take time off remaining time when the process "runs"
	def subtime(self, time):
		self.thread_time -= time

def getrand():
	return (random.randint(0, timeslice))

def checkio(chance):
	return (random.randint(1, 100) <= chance)

def settimes(process, time):
	prio_count[str(process.thread_prio)] += 1
	type_count[str(process.thread_type)] += 1

	prio_time[str(process.thread_prio)+"total"] += time
	type_time[str(process.thread_type)+"total"] += time  

def result():
	message = "Below shows the average time it took for each process to run starting from the beginning of the program to when that process finished\n"
	message += "Ex. If process 3 started at time 100 and ended at time 120 the result for that process would be 120.\n\n"

	message += "Per priority:\n\n"
	message += "Priority 0 average time until end of process: {}\n\n".format(int(prio_time['0total']/prio_count['0']))
	message += "Priority 1 average time until end of process: {}\n\n".format(int(prio_time['1total']/prio_count['1']))
	message += "Priority 2 average time until end of process: {}\n\n".format(int(prio_time['2total']/prio_count['2']))

	message += "Per Type:\n\n"
	message += "Type 0 average time until end of process: {}\n\n".format(int(type_time['0total']/type_count['0']))
	message += "Type 1 average time until end of process: {}\n\n".format(int(type_time['1total']/type_count['1']))
	message += "Type 2 average time until end of process: {}\n\n".format(int(type_time['2total']/type_count['2']))
	message += "Type 3 average time until end of process: {}\n\n".format(int(type_time['3total']/type_count['3'])) 

	return message

#	round robin: simulates round robin scheduler
#	
#	prcoess_list: list that acts as the queue for the scheduler
#	overall_time: keeps track of the total time
#
def roundrobin(queue):
	process_list = queue
	overall_time = 0

	while 1:
		if not process_list:
			break

		this_slice = timeslice

		if checkio(process_list[0].io_odds):
			this_slice = this_slice - getrand()

		#if our processes is done running just pop it off the list
		if (process_list[0].thread_time - this_slice) < 1:
			overall_time += this_slice
			settimes(process_list[0], overall_time)
			process_list.pop(0)

		#if it's not take off timeslice time from it's time left
		else:
			overall_time += this_slice
			process_list[0].subtime(this_slice)
			process_list.append(process_list.pop(0))

	return "Round Robin: \n\n\n" + result()

#	shortestjf: simulates shortest time to completion first/shortest job first 
#	
#	prcoess_list: list that acts as the queue for the scheduler
#	overall_time: keeps track of the total time
#
def shortestjf(queue):
	process_list = queue
	overall_time = 0

	while 1:
		if not process_list:
			break

		this_slice = timeslice

		check = checkio(process_list[0].io_odds)
		if check:
			this_slice = this_slice - getrand()

		if (process_list[0].thread_time - this_slice) < 1:
			overall_time += this_slice
			settimes(process_list[0], overall_time)
			process_list.pop(0)
		else:
			overall_time += this_slice
			process_list[0].subtime(this_slice)

			#Does a check to see if there was an io operation and if the queue len is still greater than 1. If so, then technically the shortest process
			#(or the one we're executing) would be in a waiting state. So, move that process back 1 spot in the queue and run the next shortest process.
			if check and len(process_list) != 1:
				process_list.insert(1, (process_list.pop(0)))

	return "Shortest Job First: \n\n\n" + result()

#	proundrobin: simulates a multi-level priority round robin
#	
#	prcoess_list: list that acts as the queue for the scheduler (holds prio 0 processes initially)
#	overall_time: keeps track of the total time
#	tempqueue2: Temporary queue to hold the priority 1 processes
#	tempqueue3: Temporary queue to hold the priority 2 processes
#
def proundrobin(queue):
	process_list = []
	temp_queue2 = []
	temp_queue3 = []

	overall_time = 0

	#fill the queues with processes
	for process in queue:
		if process.thread_prio == 0:
			process_list.append(process)
		elif process.thread_prio == 1:
			temp_queue2.append(process)
		else: 
			temp_queue3.append(process)

	while 1:
		if not process_list:
			break

		this_slice = timeslice

		if checkio(process_list[0].io_odds):
			this_slice = this_slice - getrand()

		if (process_list[0].thread_time - this_slice) < 1:
			overall_time += this_slice
			settimes(process_list[0], overall_time)
			process_list.pop(0)
		else:
			overall_time += this_slice
			process_list[0].subtime(this_slice)
			process_list.append(process_list.pop(0))

		#if the queue we're working on it empty, point to the next one in line
		if not process_list:
			if temp_queue2:
				process_list = temp_queue2
			elif temp_queue3:
				process_list = temp_queue3
			else:
				break		

	return "Priority Round Robin: \n\n\n" + result()


if __name__ == "__main__":
	
	#only keep going if an argument for the scheduling method was passed
	if len(sys.argv) == 1:
		print('Expected to get a scheduling method name but nothing was passed!\n 1 --> RR, 2 --> STCF, 3 --> Priority RR.\n')
		sys.exit()

	method = int(sys.argv[1])

	print("Please enter a file name!\n")
	file_name = sys.stdin.readline().strip().replace(' ', '')
	print("\n")

	processes = []
	try:
		with open("./"+file_name, 'r') as file:
			for line in file:
				new_process = line
				t_name, t_type, t_prio, t_time, io = new_process.strip().split(' ')
				processes.append(Process(t_name, t_type, t_prio, t_time, io))
	except:
		print("It's likely that the file name was typed incorrectly or the file is not in the same directory as the py file.\n Please run the program again.\n")
		sys.exit()

	message = ''

	if method == 1:
		message = roundrobin(processes)
	elif method == 2:
		processes.sort(key = lambda item: item.thread_time)
		message = shortestjf(processes)
	else:
		processes.sort(key = lambda item: item.thread_prio)
		message = proundrobin(processes)

	print(message)

