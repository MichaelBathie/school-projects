/*--------------------------------------------------------------------
  Student Name: <Michael Bathie>
  Student ID: <7835010>
  Section: <A02>
--------------------------------------------------------------------*/
#include <stdio.h>
#include <pthread.h>
#include <sys/wait.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>
#include <gmp.h>
#include <math.h>
#include <sys/mman.h>

//how many threads should be created in total
#define WORKERS 128
//how many threads should be able to run concurrently
#define MAX_WORKERS 16

//where should each thread start in the loop
int strt = 0;
//how many loops run should each thread perform
int iteration = (4096*4)/WORKERS;
//store the result of pi in here
mpf_t result;

//lock the global result 
pthread_mutex_t lock;

//compute the factorial of mpf_t numbers
void factorial( mpf_t num, int times ) {
    int count = times;

    if(times == 0 || times == 1) {
        mpf_init_set_d(num, 1);
    } else {
        while( count > 1 ) {
            mpf_mul_ui(num, num, count-1);
            count--;
        }
    }
}

//do the pi calculation
void compute(int start) {
    strt += iteration;
    mpf_t pi;
    mpf_t val1;
    mpf_t val2;
    mpf_t A;
    mpf_t B;
    mpf_t C;
    mpf_t D;
    mpf_t E;
    mpf_t F;
    mpf_t F2;
    mpf_init2(pi, 100);
    mpf_init2(val1, 100);
    mpf_init2(val2, 100);
    mpf_init2(A, 100);
    mpf_init2(B, 100);
    mpf_init2(C, 100);
    mpf_init2(D, 100);
    mpf_init2(E, 100);
    mpf_init2(F, 100);
    mpf_init2(F2, 100);
    for (int k = start; k < start+iteration; k++) {
        //compute A
        mpf_init_set_d(A, -1);
        mpf_pow_ui(A, A, k);

        //compute B
        long int bTemp = 6.0 * k;
        mpf_init_set_d(B, bTemp);
        factorial(B, bTemp);

        //compute C
        mpf_init_set_d(C, 545140134);
        mpf_mul_ui(C, C, k);
        mpf_add_ui(C, C, 13591409);

        //compute D
        long double dTemp = 3.0 * k;
        mpf_init_set_d(D, dTemp);
        factorial(D, dTemp);

        //compute E
        mpf_init_set_d(E, k);
        factorial(E, k);
        mpf_pow_ui(E, E, 3);
        

        //compute F
        long double fTemp = (3*k) + 1;
        mpf_init_set_d(F, 640320);
        mpf_init_set_d(F2, 640320);
        mpf_sqrt(F2, F2);
        mpf_pow_ui(F, F, fTemp);
        mpf_mul(F, F, F2);
        

        //calculate numerator
        mpf_mul(val1,A,B);
        mpf_mul(val1,val1,C);

        //calculate denominator
        mpf_mul(val2,D,E);
        mpf_mul(val2,val2,F);


        mpf_div (val1, val1, val2);
        mpf_add(pi, pi, val1);
    }
    //lock
    pthread_mutex_lock(&lock);
    mpf_add(result, result, pi);
    pthread_mutex_unlock(&lock);
    mpf_clear(pi);
    mpf_clear(val1);
    mpf_clear(val2);
    mpf_clear(A);
    mpf_clear(B);
    mpf_clear(C);
    mpf_clear(D);
    mpf_clear(E);
    mpf_clear(F);
    mpf_clear(F2);
}

static void *hard_work(void *work)
{
    int *amount = (int*) work;
    struct timespec t = { .tv_sec = 0, .tv_nsec = *amount * 100000 };
    nanosleep( &t, NULL ); // **Really** hard work.
    compute(strt);
    return amount;
}

struct timespec diff(struct timespec start, struct timespec end)
{
	struct timespec temp;

	if ( (end.tv_nsec-start.tv_nsec) < 0)
	{
		temp.tv_sec = end.tv_sec-start.tv_sec - 1;
		temp.tv_nsec = 1000000000 + end.tv_nsec - start.tv_nsec;
	}
	else
	{
		temp.tv_sec = end.tv_sec - start.tv_sec;
		temp.tv_nsec = end.tv_nsec - start.tv_nsec;
	}

	return temp;
}

#define worker_t pthread_t *

#define create_worker(work) make_thread(work);
#define stop_worker(worker) kill_thread(worker);

static pthread_t *make_thread(int *work)
{
    pthread_t *thread = malloc(sizeof(pthread_t));
    pthread_create(thread, NULL, hard_work, work);
    return thread;
}

static void kill_thread(pthread_t *thread)
{
    pthread_join(*thread, NULL);
    free(thread);
}

int main(void)
{
    //initialize result
    mpf_init_set_d(result, 0);

    int work = 1;
    unsigned int current_workers = 0;
    worker_t workers[MAX_WORKERS];
	struct timespec start, end, total;

	clock_gettime(CLOCK_REALTIME, &start);
    for (int i = 0; i < WORKERS; i++)
    {
        workers[current_workers] = create_worker(&work);
        current_workers++;

        if (current_workers == MAX_WORKERS)
        {
            for (int j = 0; j < MAX_WORKERS; j++)
            {
                stop_worker(workers[j]);
            }
            current_workers = 0;
        }
    }

    //finish the pi calculation
    mpf_mul_ui(result, result, 12);
    mpf_ui_div (result, 1, result);

	clock_gettime(CLOCK_REALTIME, &end);
    total = diff(start, end);

    mpf_clear(result);

    printf("Finished experiment with timing %lds, %ldns\n", total.tv_sec, total.tv_nsec);
    printf("Created %d total workers in that time.\n", WORKERS / MAX_WORKERS);

    return EXIT_SUCCESS;
}
