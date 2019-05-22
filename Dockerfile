FROM linuxserver/transmission:latest

RUN \
	echo "**** install python ****" && \
	apk add --no-cache python3 && \
	python3 -m ensurepip && \
	rm -r /usr/lib/python*/ensurepip && \
	pip3 install --upgrade pip setuptools && \
	if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip ; fi && \
	if [[ ! -e /usr/bin/python ]]; then ln -sf /usr/bin/python3 /usr/bin/python; fi && \
	echo "**** install plugin: telegram ****" && \
	apk add --no-cache py3-cryptography && \
	pip install --upgrade python-telegram-bot && \
	echo "**** install plugin: misc ****" && \
	apk add --no-cache mediainfo && \
	pip install --upgrade \
		transmissionrpc && \
	echo "**** install flexget ****" && \
	pip install --upgrade --force-reinstall \
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
