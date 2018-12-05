FROM linuxserver/transmission

RUN \
	echo "**** install transmission web control ****" && \
	wget -P /tmp https://github.com/ronggang/transmission-web-control/raw/master/release/install-tr-control.sh && \
	echo -ne "1\n" | bash /tmp/install-tr-control.sh && \
	echo "**** install utils ****" && \
	apk add --no-cache mediainfo findutils && \
	echo "**** install python ****" && \
	apk add --no-cache python3 && \
	python3 -m ensurepip && \
	rm -r /usr/lib/python*/ensurepip && \
	pip3 install --upgrade pip setuptools && \
	if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip ; fi && \
	if [[ ! -e /usr/bin/python ]]; then ln -sf /usr/bin/python3 /usr/bin/python; fi && \
	echo "**** install flexget and addons ****" && \
	apk add --no-cache py3-cryptography && \
	pip3 install --upgrade \
		transmissionrpc \
		python-telegram-bot \
		flexget && \
	echo "**** cleanup ****" && \
	rm -rf \
		/tmp/* \
		/root/.cache

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 9091 51413 3539
VOLUME /config /downloads /watch /flexget
