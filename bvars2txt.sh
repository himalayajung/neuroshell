#!/bin/sh

# converts .bvars files outputted by FIRST to .txt files

FOLDER=/Volumes/HD1/hpcdarwin/ABIDE_newdata/FIRST

mkdir -p $FOLDER/mode_par

PWD=`pwd`
cd $FOLDER
for file in `ls *.bvars`; do
	echo $file
	txt_file=`echo $file | sed 's/.bvars/.txt/'`
	echo $txt_file
	first_utils -i $file --readBvars -o grot >> mode_par/$txt_file
done
cd $PWD
