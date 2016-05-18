#!/bin/bash

# sortmediafile.sh sorts any TV show related file given in parameter into
# its right directory under PATH_TVSHOW/tvshow title/Season x/ .
# The 3 following variable need to be set for the script to run properly.

FILENAME="$1"
PATH_REPOSITORY="$2"
PATH_TVSHOWS="$3"
PATH_MOVIES="$4"
PATH_LOG="$5"
PID="$6"

#TODO : favorize score for a tvshow folder if keywords are coming in its name the right order.
#TODO : if no season indicator on the file, check for its parent directory.
#TODO : if no keywords, check for parent directory
#TODO : try the last destination directory as a first candidate to sort the current file into.

shopt -s nocaseglob

[[ $FILENAME == .* ]] && exit 0
[[ $FILENAME == */.* ]] && exit 0
[[ $FILENAME == *.torrent ]] && exit 0
[[ $FILENAME == *.txt ]] && exit 0
[[ $FILENAME == *.nfo ]] && exit 0
[[ $FILENAME =~ .*[S|s]ample.* ]] && exit 0

#Extract keywords and episode position in the tvshow
KEYWORDS=$FILENAME
KEYWORDS=$(basename "$KEYWORDS")
KEYWORDS="${KEYWORDS%.*}"
KEYWORDS=$(echo "$KEYWORDS" | sed -r 's/[\._-]+/\ /g') 		#replace . _ - with spaces
KEYWORDS=$(echo "$KEYWORDS" | sed -r "s/[']+//g") 		#remove '
KEYWORDS=$(echo "$KEYWORDS" | sed -e 's/\[[^][]*\]//g')		#remove brackets with their content
EPISODE_ID=$([[ "$KEYWORDS" =~ [S|s][0-9]+[E|e][0-9]+|[S|s]eason\ *[0-9]+|[0-9]+x[0-9]+ ]] && echo $BASH_REMATCH)
KEYWORDS=$(echo "$KEYWORDS" | sed -e 's/[S|s]eason\ *[0-9]*.*//g')
KEYWORDS=$(echo "$KEYWORDS" | sed -e 's/[S|s][0-9]*[E|e][0-9]*.*//g')
KEYWORDS=$(echo "$KEYWORDS" | sed -e 's/[0-9]x[0-9]*.*//g')
EPISODE_SEASON=$([[ $EPISODE_ID =~ [0-9]+ ]] && echo $BASH_REMATCH)
EPISODE_SEASON=${EPISODE_SEASON#0}
KEYWORDS=$(echo "${KEYWORDS,,}")
KEYWORDS=$(echo "${KEYWORDS~}")
KEYWORDS="$(echo -e "${KEYWORDS}" | sed -e 's/[[:space:]]*$//')"

#Sort as a movie if there is no episode id in the file name
if [[ -z $EPISODE_SEASON ]]; then
#	echo "($PID) CREATING : $PATH_MOVIES/$KEYWORDS" >> "${PATH_LOG}/sort.log"
#	mkdir "$PATH_MOVIES/$KEYWORDS"
#	PATH_DEST="$PATH_MOVIES/$KEYWORDS"
#	echo "($PID) MOVING :   ./$FILENAME" >> "${PATH_LOG}/sort.log"
#	echo "($PID) TO :       $PATH_DEST" >> "${PATH_LOG}/sort.log"
#	mv "$PATH_REPOSITORY/$FILENAME" "$PATH_DEST/" >> "$PATH_LOG/sort.log"
#	chmod 777 -R "$PATH_DEST"
	exit 1
fi

#Match keywords with TVSHOWS
declare -A SCORES
BESTSCORETVSHOW=""
SECONDSCORE=0
BESTSCORE=0
for KEYWORD in $KEYWORDS; do
	for CURRENT_FILE in "${PATH_TVSHOWS}"/*; do
		if [[ $(echo "$CURRENT_FILE" | sed -r "s/[\'\"]+//g") ==  *${KEYWORD}* ]]; then
			if [[ -z SCORES["$CURRENT_FILE"] ]]; then SCORES["$CURRENT_FILE"]=1;
			else SCORES["$CURRENT_FILE"]=$((SCORES["$CURRENT_FILE"]+1)); fi
			if [[ ${SCORES["$CURRENT_FILE"]} -ge $BESTSCORE ]]; then
				SECONDSCORE=$BESTSCORE
				BESTSCORE=$((SCORES["$CURRENT_FILE"]))
				BESTSCORETVSHOW="$CURRENT_FILE"
			fi
		fi
	done
done
unset -v "SCORES"

#Verify if destination directories exist or create them
if [[ $BESTSCORE -eq $SECONDSCORE ]]; then
	echo "($PID) CREATING : $PATH_TVSHOWS/$KEYWORDS" >> "${PATH_LOG}/sort.log"
	mkdir "$PATH_TVSHOWS/$KEYWORDS"
	chmod 777 "$PATH_TVSHOWS/$KEYWORDS"
	BESTSCORETVSHOW="$PATH_TVSHOWS/$KEYWORDS"
fi
PATH_DEST="$BESTSCORETVSHOW/Season $EPISODE_SEASON"
if [[ ! -d "$BESTSCORETVSHOW/Season $EPISODE_SEASON" ]]; then
	if [[ ! -d "$BESTSCORETVSHOW/season $EPISODE_SEASON" ]]; then
		echo "($PID) CREATING : $BESTSCORETVSHOW/Season $EPISODE_SEASON" >> "${PATH_LOG}/sort.log"
		mkdir "$BESTSCORETVSHOW/Season $EPISODE_SEASON"
		chmod 777 "$BESTSCORETVSHOW/Season $EPISODE_SEASON"
	else
		PATH_DEST="$BESTSCORETVSHOW/season $EPISODE_SEASON";
	fi
fi

#Fetch and move file to its destination
echo "($PID) MOVING :   ./$FILENAME" >> "${PATH_LOG}/sort.log"
echo "($PID) TO :       $PATH_DEST" >> "${PATH_LOG}/sort.log"
mv "$PATH_REPOSITORY/$FILENAME" "$PATH_DEST/"
chmod 777 "$PATH_DEST/$FILENAME"
exit 0
