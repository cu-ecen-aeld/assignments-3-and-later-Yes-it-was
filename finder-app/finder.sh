#!/bin/bash

FILEDIR="$1"
SEARCHSTR="$2"

#validate inputs
if [ ! -d "$FILEDIR" ] ; then
	echo "The first argument needs to be directory to be searched" 
	exit 1
fi

if [ $# -lt 2 ] ; then
	echo "Need to input a string to search for" 
	exit 1
fi

echo "Searching $FILEDIR for $SEARCHSTR"

