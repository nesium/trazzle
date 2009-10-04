#!/bin/sh
for filter in ~/Library/Application\ Support/Trazzle/Filters/*.trazzleFilter 
do 
	filter_name=`basename "$filter"`
	echo "$filter_name\n--------------------"
	cat "$filter"
	echo
done