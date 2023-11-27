#include <stdio.h>
#include <stdlib.h>
#include <syslog.h>
#include <errno.h>
#include <string.h>

int main(int argc, char* argv[]){
	

	if(argc < 2){
		printf("Not enough arguments \n");
		return 1; 
	}
	
	FILE* f = fopen(argv[1],"w");
	if(f == NULL){
		int e_code = errno; 
		printf("Error opening %s: %s \n",argv[1],strerror(e_code)); 
		return 1; 
	}

	fprintf(f,"%s",argv[2]);
	fclose(f); 


	return 0; 
}
