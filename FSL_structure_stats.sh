#!/bin/sh

## Creates tables (.txt files) of different statistics of 15 subcortical structurs segmented using FIRST (in native space)
# your work directory is assumed to be 'FIRST' i.e. where the subjects files are and the segmentation was done 
# using run_first_all

# @author Gajendra Jung Katuwal

# everything will be done inside this directory
export WORKDIR=/blabla/FIRST
# It is assumed original subject images are also in this directory as per the standard structure required by "run_first_all"

export CMA_LABELS=/blabla/CMA_standard_labels
# You can find this here http://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FIRST/UserGuide#Labels

# vertical list of subjects name 
export SUBJECTSFILE=/blabla/subjectsfile

mkdir -p $WORKDIR/FIRST_segmentation_tables # where tables are stored
mkdir -p $WORKDIR/FIRST_segmentation_tables/historgram # where tables are stored


## CREATE TABLE: For each sub-cortical structure in the file structures_list (total 15 ) 
while read line1           
do  
	
	structure=`echo $line1 | cut -d ' ' -f2` # extract field 2 seperated by space
	label=`echo $line1 | cut -d ' ' -f1`	# field 1

	LTHRESH=`echo "scale=2;$label-1/2" | bc` # lower and upper thresholds 
	UTHRESH=`echo "scale=2;$label+1/2" | bc`
	
	
	echo  " PROCESSING $structure" 
	echo $LTHRESH 
	echo $UTHRESH
	
	# Create a txt file for table with the fslstats fields as columns
	printf "Subject \t volume_voxels \t volume_mm3 \t mean_intensity \t median_intensity \t robust_min_intensity \t robust_max_intensity \t mean_entropy \t std_intensity \t COGX_mm \t COGY_mm \t COGZ_mm \t COGX_voxels \t COGY_voxels \t COGZ_voxels \n" > $WORKDIR/FIRST_segmentation_tables/${structure}.txt
	 
	## For each subject in the file subjectsfile    
	while read subject           
		do    
		echo " PROCESSING $subject" 
		## Create Mask of the subcortical structure in native space
		fslmaths $WORKDIR/${subject}_all_fast_firstseg -thr $LTHRESH -uthr $UTHRESH $WORKDIR/${subject}_mask
		

		## Get stats of the structure using this mask
		fslstats $WORKDIR/${subject} -k $WORKDIR/${subject}_mask  -V -M -P 50 -r -E -S -c -C -a -n \
		| tr " " "\t" |sed "s|\(.*\)|$subject 	\1|">> $WORKDIR/FIRST_segmentation_tables/${structure}.txt

		## Delete mask
		rm $WORKDIR/${subject}_mask.nii.gz

	done< $SUBJECTSFILE

done < $CMA_LABELS

### fslstats
# -k <mask>    : use the specified image (filename) for masking - overrides lower and upper thresholds

# -V           : output <voxels> <volume> (for nonzero voxels)
# -M           : output mean (for nonzero voxels)
# -P <n>       : output nth percentile (for nonzero voxels)
# -r           : output <robust min intensity> <robust max intensity>
# -E           : output mean entropy (of nonzero voxels)
# -S           : output standard deviation (for nonzero voxels)
# -c           : output centre-of-gravity (cog) in mm coordinates
# -C           : output centre-of-gravity (cog) in voxel coordinates
# -a           : use absolute values of all image intensities
# -n           : treat NaN or Inf as zero for subsequent stats
