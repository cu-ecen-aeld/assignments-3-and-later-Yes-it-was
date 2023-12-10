#include "threading.h"
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>

// Optional: use these functions to add debug or error prints to your application
#define DEBUG_LOG(msg,...)
//#define DEBUG_LOG(msg,...) printf("threading: " msg "\n" , ##__VA_ARGS__)
#define ERROR_LOG(msg,...) printf("threading ERROR: " msg "\n" , ##__VA_ARGS__)

void* threadfunc(void* thread_param)
{

    // TODO: wait, obtain mutex, wait, release mutex as described by thread_data structure
    // hint: use a cast like the one below to obtain thread arguments from your parameter
    //struct thread_data* thread_func_args = (struct thread_data *) thread_param;
    
	struct thread_data* args = (struct thread_data *)thread_param;
	usleep(args->wait_to_obtain_ms * 1000);
	DEBUG_LOG("Trying to obtain lock"); 
	while(pthread_mutex_trylock(args->mutex) != 0);
	DEBUG_LOG("Lock obtained"); 
	usleep(args->wait_to_release_ms * 1000);
	DEBUG_LOG("Trying to release lock"); 
	if(pthread_mutex_unlock(args->mutex) != 0){
		DEBUG_LOG("There was an error releasing lock"); 
		args->thread_complete_success = false;
	} else {
		DEBUG_LOG("lock released"); 
		args->thread_complete_success = true;
	}


	


    return thread_param;
}


bool start_thread_obtaining_mutex(pthread_t *thread, pthread_mutex_t *mutex,int wait_to_obtain_ms, int wait_to_release_ms)
{
    /**
     * TODO: allocate memory for thread_data, setup mutex and wait arguments, pass thread_data to created thread
     * using threadfunc() as entry point.
     *
     * return true if successful.
     *
     * See implementation details in threading.h file comment block
     */

	struct thread_data* handle = malloc(sizeof(struct thread_data));
	if(handle == NULL){
		DEBUG_LOG("No heap memory"); 
		return false;
	}
	handle->wait_to_obtain_ms = wait_to_obtain_ms; 
	handle->wait_to_release_ms = wait_to_release_ms;
	handle->mutex = mutex; 

	if(pthread_create(thread,NULL,threadfunc,handle)==0)
		return true; 

    return false;
}
