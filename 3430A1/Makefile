CC = gcc
CFLAGS = -Wall -Wpedantic -Wextra -Werror -g
LDFLAGS = -pthread

processes: processes.c
	$(CC) $(CFLAGS) $(LDFLAGS) processes.c -o processes -lgmp -lm 

threads: threads.c
	$(CC) $(CFLAGS) $(LDFLAGS) threads.c -o threads -lgmp -lm 
  
clean:
	rm -f processes threads

