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

#echo "Searching $FILEDIR for $SEARCHSTR"

Y=$(grep -r $SEARCHSTR $FILEDIR/* | wc -l)
X=$(find $FILEDIR -type f | wc -l)

echo "The number of files are $X and the number of matching lines are $Y"
