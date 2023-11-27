#include <stdio.h>
#include <stdlib.h>
#include <syslog.h>
#include <errno.h>
#include <string.h>

int main(int argc, char* argv[]){
	
	openlog(NULL,0,LOG_USER);
	
	if(argc < 2){
		syslog(LOG_ERR,"Not enough arguments \n");
		return 1; 
	}


	syslog(LOG_DEBUG,"Writing %s to %s",argv[2],argv[1]); 
	
	FILE* f = fopen(argv[1],"w");
	if(f == NULL){
		//int e_code = errno; 
		syslog(LOG_ERR,"Error opening %s: %s \n",argv[1],strerror(errno)); 
		return 1; 
	}

	fprintf(f,"%s",argv[2]);
	fclose(f); 


	return 0; 
}
