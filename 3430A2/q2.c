/*--------------------------------------------------------------------
  Student Name: <Michael Bathie>
  Student ID: <7835010>
  Section: <A02>
--------------------------------------------------------------------*/

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <signal.h>

void my_sig ()
{
	for ( int i = 5; i > 0; i-- )
	{
		write( STDOUT_FILENO, "processing...\n", 15);
		sleep( 1 );
	}
	write( STDOUT_FILENO, "done!\n", 7);
}

int main( void )
{

	signal ( SIGUSR1, my_sig );
	sleep(1);
	pid_t ppid = getpid();

	pid_t pid = fork();
	if ( pid == -1 )
	{
		printf( "Fork failed" );
		exit(1);
	}
	else if( pid == 0 )
	{
		sleep(1);
		write ( STDOUT_FILENO, "child signal sent\n", 19 );
		kill ( ppid, SIGUSR1);
	}
	else 
	{
		write ( STDOUT_FILENO, "parent signal sent\n", 20 );
		raise (SIGUSR1);
	}

}