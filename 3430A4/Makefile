CC = gcc
CFLAGS = -Wall -Wpedantic -Wextra -Werror -g -std=c99

build:
	$(CC) $(CFLAGS) fat32.c -o fat32

info:
	./fat32 a4image info

list:
	./fat32 a4image list

get:
	./fat32 a4image get

clean:
	rm -f fat32
