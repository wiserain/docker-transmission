ARG ALPINE_VER=3.12
ARG LIBTORRENT_VER=2.0.0

FROM wiserain/libtorrent:${LIBTORRENT_VER}-alpine${ALPINE_VER}-py3 AS libtorrent
FROM linuxserver/transmission:latest
LABEL maintainer "wiserain"

ENV TRANSMISSION_WEB_HOME="/transmission-web-control/"

RUN \
    echo "**** install frolvlad/alpine-python3 ****" && \
	apk add --no-cache python3 && \
	if [[ ! -e /usr/bin/python ]]; then ln -sf /usr/bin/python3 /usr/bin/python; fi && \
	python3 -m ensurepip && \
	rm -r /usr/lib/python*/ensurepip && \
	pip3 install --no-cache --upgrade pip setuptools wheel && \
	if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip; fi && \
	echo "**** install dependencies for plugin: telegram ****" && \
	apk add --no-cache --virtual=build-deps gcc python3-dev libffi-dev musl-dev openssl-dev && \
	pip install --upgrade python-telegram-bot==12.8 PySocks && \
	apk del --purge --no-cache build-deps && \
	echo "**** install dependencies for plugin: cfscraper ****" && \
	apk add --no-cache --virtual=build-deps g++ gcc python3-dev libffi-dev openssl-dev && \
	pip install --upgrade cloudscraper && \
	apk del --purge --no-cache build-deps && \
	echo "**** install dependencies for plugin: convert_magnet ****" && \
	apk add --no-cache boost-python3 libstdc++ && \
	echo "**** install dependencies for plugin: decompress ****" && \
	apk add --no-cache unrar && \
	pip install --upgrade \
		rarfile && \
	echo "**** install dependencies for plugin: misc ****" && \
	pip install --upgrade \
		transmissionrpc \
		deluge-client \
		irc_bot && \
	echo "**** install flexget ****" && \
	apk add --no-cache --virtual=build-deps gcc libxml2-dev libxslt-dev libc-dev python3-dev jpeg-dev && \
	pip install --upgrade --force-reinstall \
		flexget && \
	apk del --purge --no-cache build-deps && \
	apk add --no-cache libxml2 libxslt jpeg && \
	echo "**** system configurations ****" && \
	apk --no-cache add bash bash-completion tzdata && \
	echo "**** cleanup ****" && \
	rm -rf \
		/tmp/* \
		/root/.cache

# copy libtorrent libs
COPY --from=libtorrent /libtorrent-build/usr/lib/ /usr/lib/

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 9091 51413 5050
VOLUME /config /downloads /watch /flexget
