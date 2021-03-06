#!/bin/bash

# user-define variables
TR_CMD="transmission-remote http://<USERNAME>:<PASSWORD>@localhost:9091/transmission/rpc"
FG_CMD="flexget -c /flexget/config.yml"

TG_TOKEN='<TELEGRAM_BOT_TOKEN>'
TG_ID="<TELEGRAM_CHAT_ID>"

# manipulating variables
[[ "${TR_TORRENT_DIR}" != */ ]] && TR_TORRENT_DIR="${TR_TORRENT_DIR}/" # add trailing slash if needed

TG_URL='https://api.telegram.org/bot'$TG_TOKEN
TG_URL=$TG_URL'/sendMessage?chat_id='$TG_ID

read -r -d '' TG_MSG <<EOT
*[NEXT] Download Reverted*
_${TR_TORRENT_NAME}_
EOT
send_message() {
   res=$(curl --data-binary "text=${TG_MSG}" $TG_URL"&parse_mode=MarkDown")
}

# parse $SERIES_NAME and $EP_NUM for "flexget series remove"
SERIES_NAME="$(basename "$TR_TORRENT_DIR")"		# assuming (TR_TORRENT_DIR == SERIES_NAME)
EP_NUM=$(echo $TR_TORRENT_NAME | grep -oE '\.E[0-9]{1,5}')
EP_NUM=${EP_NUM#".E"}

FNAMES=`${TR_CMD} --torrent $TR_TORRENT_ID --files | grep 100% | awk '{for(i=7;i<=NF;i++){printf "%s ", $i}; printf "\n"}'`
# echo "${FNAMES}"

while read -r FNAME; do
	FNAME="${TR_TORRENT_DIR}${FNAME}"
	if [[ $FNAME == *"NEXT"* ]] && [[ $FNAME == *"mp4"* ]]; then
		ENCODER=$(mediainfo "${FNAME}" --Inform="General;%Encoded_Application%")
		if [[ "$ENCODER" != "MH ENCODER" ]]; then
			# rename before remove
			FNAME_NOEXT=${FNAME%.*}
			EXTENSION=${FNAME##*.}
			mv "$FNAME" "${FNAME_NOEXT}-FAKE.${EXTENSION}"

			# remove torrent
			TR_REMOVE_STATUS=`${TR_CMD} --torrent $TR_TORRENT_ID --remove-and-delete`
			# echo "${TR_REMOVE_STATUS}"

			# flexget series remove
			FG_REMOVE_STATUS=`$FG_CMD series remove "${SERIES_NAME}" "${EP_NUM}"`
			# echo ${FG_REMOVE_STATUS}

			# notification
			send_message &> /dev/null
		fi
	fi
done <<< "${FNAMES}"

# folder strip
while read -r FNAME; do
	DIR_FULL=$(dirname "$FNAME")
	# echo "${DIR_FULL}"
	DIR_ONLY=$(basename "$DIR_FULL")
	# echo "${DIR_ONLY}"

	FONLY=$(basename "$FNAME")
	# echo $FONLY
	FNAME_NOEXT=${FONLY%.*}
	# echo $FNAME_NOEXT

	if [[ "${DIR_ONLY}" == "${FNAME_NOEXT}" ]]; then
		DIR_SIZE=$(du -hsb "${DIR_FULL}" | cut -f 1)
		FSIZE=$(du -b "${FNAME}" | cut -f 1)

		NFILES_TOTAL=$(ls -1q "${DIR_FULL}" | wc -l)
		NFILES_INVAL=$(ls -1q "${DIR_FULL}"/*.{txt,nfo} 2>/dev/null | wc -l)
		if ((${NFILES_TOTAL}-${NFILES_INVAL} <= 1)); then
			# echo "${FNAME}"
			mv "${FNAME}" "${DIR_FULL}/.."
			rm -rf "${DIR_FULL}"

			# remove torrent
			# TR_REMOVE_STATUS=`${TR_CMD} --torrent $TR_TORRENT_ID --remove-and-delete`
			# echo "${TR_REMOVE_STATUS}"
		fi
	fi
done <<< "$(find "${TR_TORRENT_DIR}" -type f \( -name '*.mp4' -or -name '*.mkv' \))"
