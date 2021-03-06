#!/usr/bin/python

import sys
import os
import socket
import subprocess

#as the server '' defaults to this machine --> more portable
address = ( '', 15083 )

#create socket
my_socket = socket.socket( socket.AF_INET, socket.SOCK_STREAM )

#in try block because we have to ask the OS if we can have this port (bind call)
#if something else if using that port we will fail.
try:
    #bind socket to our port
    my_socket.bind( address )
    #tell socket to listen for requests
    my_socket.listen( socket.SOMAXCONN )
    #start waiting for connections
    while ( 1 ) :
        ( request_socket, addr ) = my_socket.accept()

        #treat the socket as a file
        socket_file = request_socket.makefile()

        #read the initial line
        initial_line = socket_file.readline()

        #break apart the initial line
        method, script, http = initial_line.split()

        #path to the resource
        path = ''
        arguments = ''
        data = "HTTP/1.1 200 OK\r\n"
        msg_body = ''
        c_length = 0

        for line in socket_file :
            #if we hit the empty line then break out
            if ( len( line ) < 3 ) :
                break
            else :
                #keep reading headers
                x = line.split (' ')
                if ( x[0] == 'Content-Length:' ) :
                    c_length = int( x[1] )
                header_name, header_value = line.split( ': ' )
                if ( header_name == 'Cookie' ) :
                    os.environ[ 'HTTP_COOKIE' ] = header_value.replace( ' ', '' )

        if ( method == 'GET' ):
            if '?' in script :
                path, arguments = script.split( '?' )

                if ( arguments.split() ) :
                    os.environ[ 'QUERY_STRING' ] = arguments.replace( ' ', '' )

            else :
                path = script

            temp_path = path
            path = path[ 1: ]
            #if everything is good with the path then give them the data
            if os.path.isfile( path ) :

                #it's a get request so we don't need to send anything to stdin
                stdout = subprocess.check_output( path )

                data += stdout

                #we don't need the cookie variable set anymore
                os.environ[ 'HTTP_COOKIE' ] = ''

            #if the path was a directory then send them to index.html
            elif os.path.isdir( path ) :
                data += "Content-Type: text/html\r\n"
                data += "\r\n"

                try :
                    if ( 'Q1a' in path ) :
                        with open ( 'Q1a/index.html', 'r' ) as file :
                            data += file.read()
                    elif ( 'Q1b' in path ) :
                        with open ( 'Q1b/index.html', 'r' ) as file :
                            data += file.read()
                except :
                    print ( 'Something went wrong with index.html' )

            #couldn't find the file so send a 404
            else :
                data = "HTTP/1.1 404 NOT FOUND\n"
                data += "Content-Type: text/html\r\n"
                data += "\r\n"
                data += "<html><body><h1>404 NOT FOUND</h1>"
                data += "<p>The requested URL {} was not found on this server</p></body></html>".format( path )
                #write the data to the client


        elif ( method == 'POST' ) :
            path = script
            path = path[ 1: ]

            msg_body = socket_file.readline( c_length )
            msg_body = msg_body.replace( ' ', '' )

            if os.path.isfile( path ) :
                os.environ[ 'CONTENT_LENGTH' ] = str(len(msg_body.encode( 'utf-8' )))

                pro_object = subprocess.Popen( path, stdin = subprocess.PIPE, stdout = subprocess.PIPE )
                stdout, stderr = pro_object.communicate( input = msg_body.encode( 'utf-8' ) )

                data += stdout

                #we don't need the cookie variable set anymore
                os.environ[ 'HTTP_COOKIE' ] = ''

            else :
                data = "HTTP/1.1 404 NOT FOUND\n"
                data += "Content-Type: text/html\r\n"
                data += "\r\n"
                data += "<html><body><h1>404 NOT FOUND</h1>"
                data += "<p>The requested URL {} was not found on this server</p></body></html>".format( path )



        #we have a HEAD request
        else :
            path = script
            path = path[ 1: ]

            if os.path.isfile( path ) :

                #it's a get request so we don't need to send anything to stdin
                stdout = subprocess.check_output( path )

                #extracting all of the headers in the response message
                headers  = stdout.split( '\n' )
                for line in headers :
                    if (  len( line ) < 3 ) :
                        break
                    data += line
                    data += '\n'

            #couldn't find the file so send a 404
            else :
                data = "HTTP/1.1 404 NOT FOUND\n"
                data += "Content-Type: text/html\r\n"
                data += "\r\n"
                data += "<html><body><h1>404 NOT FOUND</h1>"
                data += "<p>The requested URL {} was not found on this server</p></body></html>".format( path )

        socket_file.write( data )

        #send EOF to end the interaction
        socket_file.close()
        request_socket.close()
except KeyboardInterrupt :
    print ( 'Server Stopped' )

except :
    print ( 'Server Error' )

finally :
    #close the socket
    my_socket.close()