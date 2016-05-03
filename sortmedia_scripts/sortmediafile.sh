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

#TODO : favorize score for a tvshow folder if keywords are coming in the right order.

if [[ $FILENAME != .* ]] && [[ $FILENAME != */.* ]] && [[ $FILENAME != *.torrent ]] && [[ $FILENAME != *.txt ]] && [[ "$FILENAME" ]]; then
	#Extract keywords and episode position in the tvshow
	KEYWORDS=$FILENAME
	KEYWORDS=$(basename "$KEYWORDS")
	KEYWORDS="${KEYWORDS%.*}"
	KEYWORDS=$(echo "$KEYWORDS" | sed -r 's/[\._-]+/\ /g') 		#replace . _ - with spaces
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
		echo "($PID) CREATING : $PATH_MOVIES/$KEYWORDS" >> "${PATH_LOG}/sort.log"
		mkdir "$PATH_MOVIES/$KEYWORDS"
		PATH_DEST="$PATH_MOVIES/$KEYWORDS"
	        echo "($PID) MOVING :  $PATH_REPOSITORY/$FILENAME" >> "${PATH_LOG}/sort.log"
	        echo "($PID) TO :      $PATH_DEST/" >> "${PATH_LOG}/sort.log"
	        mv "$PATH_REPOSITORY/$FILENAME" "$PATH_DEST/" >> "$PATH_LOG/sort.log"
		exit 1
	fi

	#Match keywords with TVSHOWS #
	declare -A SCORES
	shopt -s nocaseglob
	for KEYWORD in $KEYWORDS; do
		if ls "${PATH_TVSHOWS}" | grep -E *${KEYWORD}* 1> /dev/null 2>&1; then
		for CURRENT_FILE in "${PATH_TVSHOWS}"/*${KEYWORD}*; do
			if [[ -z SCORES["$CURRENT_FILE"] ]]; then SCORES["$CURRENT_FILE"]=1;
			else SCORES["$CURRENT_FILE"]=$((SCORES["$CURRENT_FILE"]+1)); fi
		done
		fi
	done
	BESTSCORETVSHOW=""
	SECONDSCORE=0
	BESTSCORE=0
	for SCORE in "${!SCORES[@]}"; do
		if [[ ${SCORES[${SCORE[$i]}]} -ge $BESTSCORE ]]; then
			SECONDSCORE=$BESTSCORE
			BESTSCORE=${SCORES[${SCORE[$i]}]}
			BESTSCORETVSHOW="${SCORE[$i]}"
		fi
	done
	unset -v "SCORES"

	#Verify if destination directories exist or create them
	if [[ $BESTSCORE -eq $SECONDSCORE ]]; then
		echo "($PID) CREATING : $PATH_TVSHOWS/$KEYWORDS" >> "${PATH_LOG}/sort.log"
                mkdir "$PATH_TVSHOWS/$KEYWORDS"
		BESTSCORETVSHOW="$PATH_TVSHOWS/$KEYWORDS"
	fi
	PATH_DEST="$BESTSCORETVSHOW/Season $EPISODE_SEASON"
	if [[ ! -d "$BESTSCORETVSHOW/Season $EPISODE_SEASON" ]]; then
		if [[ ! -d "$BESTSCORETVSHOW/season $EPISODE_SEASON" ]]; then
			echo "($PID) CREATING : $BESTSCORETVSHOW/Season $EPISODE_SEASON" >> "${PATH_LOG}/sort.log"
			mkdir "$BESTSCORETVSHOW/Season $EPISODE_SEASON"
		else
			PATH_DEST="$BESTSCORETVSHOW/season $EPISODE_SEASON";
		fi
	fi
	echo "Destination: ${PATH_DEST}";

	#Fetch and move file to its destination
	echo "($PID) MOVING :  $PATH_REPOSITORY/$FILENAME" >> "${PATH_LOG}/sort.log"
	echo "($PID) TO :      $PATH_DEST/" >> "${PATH_LOG}/sort.log"
	mv "$PATH_REPOSITORY/$FILENAME" "$PATH_DEST/" >> "$PATH_LOG/sort.log"
fi
