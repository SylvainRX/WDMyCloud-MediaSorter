# !/bin/bash

# sortmedias.sh catches files and directory uploaded and moved into
# PATH_REPOSITORY and send them individually to sortmediafile.sh, which must
# be located in the same directory.
# Execute 'incrontab -e' in your terminal then add one line in the opened
# file to put in the content of the following quotation and then save.
# '/path/to/your/repository IN_CREATE,IN_MOVED_TO,IN_ISDIR /path/to/this/script/sortmedias.sh $# $@ $% $&'
# The 4 following variable need to be set for the script to run properly.

PATH_TVSHOWS='/DataVolume/shares/YourShareName/TV_Shows'
PATH_MOVIES='/DataVolume/shares/YourShareName/Movies'
PATH_LOG='DataVolume/shares/YourShareName/Repository/.log'
PATH_TRASH='DataVolume/shares/YourShareName/Repository/.trash'

PATH_REPOSITORY="$2"
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TIMEOUT=60

if [[ $1 != .* ]] && [[ $1 != *.torrent ]] && [[ $1 != *.part ]] && [[ $1 != *__??????  ]] && [[ "$1" ]]; then
	echo "($$) $(date +%Y-%m-%d\ %H:%M:%S)  file: $1  repository: $2  event: $3($4)" >> "${PATH_LOG}/sort.log"
	#Handle directory
	if [[ $3 == *IN_ISDIR* ]]; then
		DIRNAME=$1
                #Wait if files are downloading
                while [[ $(inotifywait -c -t 2 -e modify "$PATH_REPOSITORY/$DIRNAME" ) == *MODIFY* ]]; do
			NOTIF=$(inotifywait -c -t $TIMEOUT -e close_write "${PATH_REPOSITORY}"/"${DIRNAME}")
			if [[ "$NOTIF" == *CLOSE_WRITE* ]]; then
				FILENAME=$(echo $NOTIF | sed -r 's/.*,\".*\",//g')
                	        "$DIR"/sortmediafile.sh "$DIRNAME/$FILENAME" "$PATH_REPOSITORY" "$PATH_TVSHOWS" "$PATH_MOVIES" "$PATH_LOG" "$$"
			fi
                done
		#Check for existing files in the directory
		if ls "$PATH_REPOSITORY/$DIRNAME/"* 1> /dev/null 2>&1; then
		for FILENAME in "$PATH_REPOSITORY/$DIRNAME/"*; do
                	FILENAME=$(echo $FILENAME | sed -e 's/.*\///g')
      	        	"$DIR"/sortmediafile.sh "$DIRNAME/$FILENAME" "$PATH_REPOSITORY" "$PATH_TVSHOWS" "$PATH_MOVIES" "$PATH_LOG" "$$"
		done
                fi
		#Trash the directory
		echo "($$) TRASHING : $PATH_REPOSITORY/$DIRNAME" >> "${PATH_LOG}/sort.log"
		mv "$PATH_REPOSITORY/$DIRNAME" "$PATH_TRASH"

	#Handle single file
	else
		FILENAME=$1
		#Wait if the file is downloading
		while [[ $(inotifywait -c -t 2 -e modify "$PATH_REPOSITORY/$FILENAME" ) == *MODIFY* ]]; do
			NOTIF=$(inotifywait -c -t $TIMEOUT -e close_write "$PATH_REPOSITORY/$FILENAME")
			if [[ "$NOTIF" == *CLOSE_WRITE* ]]; then break; fi
		done
		#when transfering a bunch of file at a time from the MacOS Finder to the mycloud
		#some are created then closed without any data written into them and then recreated
		#to be fully written. The following test prevent to sort those empty files.
		FILESIZE=$(wc -c <"$PATH_REPOSITORY/$FILENAME")
		if [[ $FILESIZE -eq 0 ]]; then
			echo "($$) ERROR : EMPTY FILE" >> "$PATH_LOG/sort.log"
			echo "($$) TRASHING : $PATH_REPOSITORY/$FILENAME" >> "${PATH_LOG}/sort.log"
			mv "$PATH_REPOSITORY/$FILENAME" "$PATH_TRASH"
			echo "($$) FAILED" >> "$PATH_LOG/sort.log"
			exit 1
		fi
		"$DIR"/sortmediafile.sh "$FILENAME" "$PATH_REPOSITORY" "$PATH_TVSHOWS" "$PATH_MOVIES" "$PATH_LOG" "$$"
	fi

	echo "($$) DONE" >> "$PATH_LOG/sort.log"
fi
