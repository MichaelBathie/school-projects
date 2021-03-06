/*--------------------------------------------------------------------
  Student Name: <Michael Bathie>
  Student ID: <7835010>
  Section: <A02>
--------------------------------------------------------------------*/

#include <stdio.h>
#include <pthread.h>
#include <stdlib.h>

//global lock
pthread_mutex_t lock;

//show different threads trying to get the lock 
void *test(void *arg)
{
	int *arguments = (int*)arg;

	printf("Thread %d trying to get lock.*****\n", *arguments);
	pthread_mutex_lock(&lock);
	printf("Thread %d got the lock.-----\n", *arguments);
	printf("Thread %d unlocking the lock.\n", *arguments);
	pthread_mutex_unlock(&lock);

	return 0;
}

#define worker_t pthread_t *

#define create_worker(work) make_thread(work);
#define stop_worker(worker) kill_thread(worker);

//create a new thread
static pthread_t *make_thread(int *var)
{
    pthread_t *thread = malloc(sizeof(pthread_t));
    pthread_create(thread, NULL, test, var);
    return thread;
}

//wait until thread finishes and free its memory
static void kill_thread(pthread_t *thread)
{
    pthread_join(*thread, NULL);
    free(thread);
}


int main(void)
{
	int num_threads = 10;

    //make sure our mutex actually worked
    if ( pthread_mutex_init( &lock, NULL) != 0 )
    {
        printf( "mutex init failed\n" );
    }

	printf("Program starts...\n\n");

	worker_t threads[num_threads];
	int nums[num_threads];

    //create all threads and number them
	for (int i = 0; i < num_threads; i++)
    {
        nums[i] = i;
        threads[i] = create_worker(&nums[i]);
    }

    //free all the threads memory
    for (int i = 0; i < num_threads; i++)
    {
        kill_thread(threads[i]);
    }

    printf("\nProgram finishes...\n\n");

    //free up the mutex
    pthread_mutex_destroy(&lock);

    return 0;
}
