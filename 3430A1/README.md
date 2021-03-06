## Running the Program

The problem I attempted to implement was computing pi to absurd lengths. Processes is partially implemented and
doesn't work properly. The Threads portion is fully implemented.

use --> "make threads" to compile the thread version or "make processes" to compile the processes portion
then ./threads to run threads or ./processes to run processes

As processes isn't finished it doesn't really accomplish anything. I would also suggest to not run it as even
with a small amount of processes running concurrently it takes forever and hogs the cpu. I think the problem has 
something do to with the shared memory but I'm not completely sure.

To get rid of any object files just run "make clean"

## The Actual Code

If you want to change the amount of threads in the code (the amount of ones running concurrently or the total amount
created) they are at the top of the file: #define workers and max_workers. Because of the way this was coded those both
must remain as powers of 2, and max_workers must always be less than workers as you can't have more threads doing work
concurrently than you have threads in total. Also keep in mind that the iteration variable is used to jump into different
spots in the computation loop for each thread, so the WORKERS variable must also NOT exceed the value of iteration, which
by default is 4096*4.

I'm sorry in advance if anything is hard to read, I tried to comment everything added to the template as best I could.

## Results

There is a png file included showing a table with timing values tested using different total threads and total amounts of threads that 
can run concurrently. The total thread counts tested were 32, 64, 128, and 256. For how many concurrent threads could run I tested 2, 4, 8,
16, 32, 64, 128, 256, where applicable.

These tests were ran on the following hardware:
CPU: 3.7 ghz base clock speed, but it was likely running somewhere inbetween 4 and 4.5
Memory: DDR4 dual channel, 1330mhz per stick
OS: ran from a linux subsystem
shell: Ubuntu shell

In the chart all timing values were averaged over 10 runs (for each thread and concurrent thread combination).

## Report
At what point are the returns on the number of threads or processes diminishing?
I didn't take down all the data that would be required to answer this 100% exactly as it would take hours to run that 
many tests. Though, I know that the returns greatly slow down once you're creating around 128 threads, and begin to get worse once you 
exceed 512 threads (this refers to having that many total threads). But this is only referring to when there are only 16 threads running
concurrently. Once the total amount of threads used surpasses 1024, it seems to have diminishing returns no matter what.

Which is faster: threads or processes? 
(I can't answer this 100% accurately as I couldn't get processes done)
I would assume that the threads would run faster, especially for larger amounts of threads/processes. Threads
can be created much quicker than processes (because the entire memory doesn't have to be duplicated) and the OS can switch between
threads much faster than it can context switch between threads/processes.

Michael Bathie, 7835010