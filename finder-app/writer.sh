#!/bin/bash

#check if the correct number of inputs were given
if [ $# -lt 2 ] ; then
	echo "Path and content requried"
fi


WRITEFILE="$1"
WRITE_PATH=$(dirname $WRITEFILE)

WRITESTR="$2" 

mkdir -p $WRITE_PATH

if [ ! -d "$WRITE_PATH" ] ; then
	echo "Path does not exist and could not be created" 
	exit 1
fi

echo $WRITESTR > $WRITEFILE
