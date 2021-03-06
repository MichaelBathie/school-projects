def join_last_known_node(the_socket, state):
	my_socket = the_socket
	my_state = state

	my_state.set_successor(my_state.last_known_node)
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