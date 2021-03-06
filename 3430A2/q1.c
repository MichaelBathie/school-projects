/*--------------------------------------------------------------------
  Student Name: <Michael Bathie>
  Student ID: <7835010>
  Section: <A02>
--------------------------------------------------------------------*/

#define _POSIX_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <signal.h>
#include <string.h>

int option = 0;
int send = 0;

void dog_to_cat ()
{
	option = 0;
	send = 1;
	char *message = "Received signal USR1, changing dog --> cat\n\n";
	write ( STDOUT_FILENO, message, strlen( message ) );
	signal ( SIGUSR1, dog_to_cat );
}

void cat_to_dog ()
{
	option = 1;
	send = 1;
	char *message = "Received signal USR2, changing cat --> dog\n\n";
	write ( STDOUT_FILENO, message, strlen( message ) );
	signal ( SIGUSR2, cat_to_dog );
}

void reset () 
{
	option = 2;
	send = 1;
	char *message = "Received signal ALRM, not modifying words\n\n";
	write ( STDOUT_FILENO, message, strlen( message ) );
	signal ( SIGALRM, reset );
}

int main ( int argc, char *argv[] )
{

	pid_t parent = getpid();
	printf ( "Parent process pid for signaling: %d\n\n", (int)parent );

	int my_pipe[2];
    pipe ( my_pipe );

    char *args [2];
    args[0] = argv[1];
    args[1] = NULL;

    pid_t pid = fork();

    if ( pid == -1 )
    {
        perror ( "Failed to fork" );
        exit ( EXIT_FAILURE );
    }
    //child process
    else if ( pid == 0 )
    {
    	//point write end of child to stdout
        dup2 ( my_pipe[1], STDOUT_FILENO );
        //close child reading end
        close ( my_pipe[0] );

        if ( argc > 1 && execvp ( argv[1], args ) == -1 ) //assumes that a program (cat) was passed
        {
            perror ( "Exec failed" );
        }
    }
    else
    {
    	//close write end of the parent pipe
    	close ( my_pipe[1] );

		char buf[1];
		char word[4];
		int word_count = 0;

		char *new_word = "New Word: ";

		while ( read( my_pipe[0], buf, 1 ) )
		{
			//dont read in newlines or terminating characters
			if ( ( buf[0] != '\n' ) && ( buf[0] != '\0' ) )
			{
				//build the word
				word[word_count] = buf[0];
				word_count++;
			}
			else if ( send == 0 ) 
			{
				printf ( "Initial Word: %s\n", word );

				//if we're under the right option and our word is dog
				if ( option == 0 && strcmp( word, "dog" ) == 0 )
				{
					//copy cat over the our words memory location
					memcpy( word, "cat", 3 );
				}
				//if we're under the right option and our word is cat
				else if ( option == 1 && strcmp( word, "cat" ) == 0)
				{
					//copy dog over the our words memory location
					memcpy( word, "dog", 3 );
				}
				write ( STDOUT_FILENO, new_word, strlen( new_word ) );
				write ( STDOUT_FILENO, word, strlen( word ) );
				printf ( "\n\n" );
				//reset the word
				word_count = 0;
			}
			send = 0;
			signal ( SIGUSR1, dog_to_cat );
			signal ( SIGUSR2, cat_to_dog );
			signal ( SIGALRM, reset );
		}	
	}
	//program is ending so kill cat
    kill ( pid, 9 );
}
