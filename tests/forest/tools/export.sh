#!/bin/bash

# there are some trick used do to inconsistency in inkscape input and output values
# the document must be resized to fit all objects

dir=`dirname $0`
log=$dir/`basename $0 .sh`.log

echo $0 executed at `date` > $log

#if [ ${#1} ] || [ ${#2} ]
if [ $# -ne 2 ]
then
	echo "Usage: $0 source.svg destination/folder/"
	exit
fi

#function extractTargetSet {
    
sourceFile="$1"
destinationFolder="$2"
    
if [ ! -f $sourceFile ]
then
	echo "Source file \"$sourceFile\" not found."
	exit
fi

if [ ! -d $destinationFolder ]
then
	echo "Destination folder \"$destinationFolder\" not found, creating it."
	mkdir -p $destinationFolder
fi


query=`inkscape --query-all $sourceFile`
#echo $query
min_x=10000
min_y=10000
for line in $query; do
	ld=(${line//,/ })
	
	x=${ld[1]}
	y=${ld[2]}
	w=${ld[3]}
	h=${ld[4]}
	# remove e notation
	if echo $y | grep e &> /dev/null; then
	    y=0
	fi
	if echo $x | grep e &> /dev/null; then
	    x=0
	fi
	
	#x=`echo $x+$w|bc`
	echo "$x < $min_x" | bc &> /dev/null
	if [ $? ]; then
		min_x=$x
	fi
	
	y=`echo $y-$h|bc`
	echo "$y < $min_y" | bc &> /dev/null
	if [ $? ]; then
		min_y=$y
	fi
done

#echo $min_x
#echo $min_y

full_h=`inkscape "-f$sourceFile" -C -H 2>> $log`

for line in $query; do #`inkscape --query-all $sourceFile | grep ^0`; do
	if echo $line | grep ^0 &> /dev/null; then
		ld=(${line//,/ })
		id=${ld[0]} #${line:0: $[`expr index "$line" ,` - 1] }
		name=${line:1: $[`expr index "$line" ,` - 2] }
			
	#for target in `cat $dir/targets/$targetSet`; do
		x=${ld[1]} #`inkscape "-f$sourceFile" -C "-I$id" -X 2>> $log`
		y=${ld[2]} #`inkscape "-f$sourceFile" -C "-I$id" -Y 2>> $log`
		w=${ld[3]} #`inkscape "-f$sourceFile" -C "-I$id" -W 2>> $log`
		h=${ld[4]} #`inkscape "-f$sourceFile" -C "-I$id" -H 2>> $log`

		# remove e notation
		if echo $y | grep e &> /dev/null; then
		    y=0
		fi
		if echo $x | grep e &> /dev/null; then
		    x=0
		fi

		# corrects value of y.
		y=`echo $full_h - $y | bc`

		#echo "x=$x y=$y w=$w h=$h $full_h" 
		echo "x=$x y=$y w=$w h=$h" &>> $log
		inkscape -z -C "-f$sourceFile" "-i$id" -j "-e$destinationFolder/$name.png" -b#000000 -y0.0 &>> $log
		# image only
		#inkscape -z -C "-f$sourceFile" "-i$id" -j "-a$x:`echo $y-$h|bc`:`echo $x+$w|bc`:$y" "-e$destinationFolder/$name.png" -b#000000 -y0.0 &>> $log
		#  -d76
	fi
done

