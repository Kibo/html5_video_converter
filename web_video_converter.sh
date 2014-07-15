#!/bin/bash
# It converts input video file or files in directory to WebM/Vorbis, OGG/Vorbis, H.264/ACC formats.
# Example: ./web_video_converter.sh VIDEO_FILE_NAME
# Example: ./web_video_converter.sh DIR_TO_VIDEOS

OUTPUT_DIR="video_out/"
BIT_RATE="345k"

# If a directory does not exist, create it
if [[ ! -d $OUTPUT_DIR ]]; then
  mkdir -p $OUTPUT_DIR
fi

# There is not parameter or -h
if [ "$#" = "0" ] || [ "$1" = "-h" ]; then
	echo -e "\n\tIt converts input video file or files in directory to WebM/Vorbis, OGG/Vorbis, H.264/ACC formats.\n\tExample: ./web_video_converter.sh myVideo.avi\n\tExample: ./web_video_converter.sh dirWithVideos\n"
	exit 0
fi

# Checking for ffmpeg
echo -ne "Checking for ffmpeg…"
if [ $(which ffmpeg) ] ; then
  echo "ffmpeg is already installed."
else
  echo "Installing ffmpeg with brew, check it"
  brew list
  exit 0
fi

function convertFile {
	# Filename without extension
	filename=$(basename "$1")
	extension="${filename##*.}"
	filename="${filename%.*}"

	# WebM/ Vorbis
	ffmpeg -i $1 -acodec libvorbis -vcodec libvpx -b $BIT_RATE ${OUTPUT_DIR}${filename}.webm

	# OGG/ Vorbis
	ffmpeg -i $1 -acodec libvorbis -vcodec libtheora -b $BIT_RATE ${OUTPUT_DIR}${filename}.ogg

	# H.264/ACC
	# -acodec libfaac | libvo_aacenc
	# @see http://trac.ffmpeg.org/wiki/CompilationGuide
	ffmpeg -i $1 -acodec libvo_aacenc -vcodec libx264 -b $BIT_RATE ${OUTPUT_DIR}${filename}.mp4
}

# Is directory
if [[ -d $1 ]]; then
	# List files in directory	
	for file in $(find $1 -type f); 
	do
		convertFile $file	
	done  
# Is file  
elif [[ -f $1 ]]; then    
	convertFile $1
else
    echo -e "$1 does not file or directory."
    exit 1
fi

exit 0
