FROM linuxserver/transmission:latest

ENV TRANSMISSION_WEB_HOME="/transmission-web-control/"

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
	echo "**** install plugins: cfscraper ****" && \
	apk add --no-cache --virtual=build-deps g++ gcc python3-dev && \
	pip install --upgrade cloudscraper && \
	apk del --purge --no-cache build-deps && \
	echo "**** install plugins: convert_magnet ****" && \
	apk add --no-cache boost-python3 && \
	echo "**** install plugin: misc ****" && \
	apk add --no-cache mediainfo && \
	pip install --upgrade \
		transmissionrpc \
		deluge_client && \
	echo "**** install flexget ****" && \
	pip install --upgrade --force-reinstall \
		flexget && \
	echo "**** cleanup ****" && \
	rm -rf \
		/tmp/* \
		/root/.cache

# copy local files
COPY root/ /

# copy libtorrent libs
COPY --from=emmercm/libtorrent:1.2.2-alpine /usr/lib/libtorrent-rasterbar.so.10 /usr/lib/
COPY --from=emmercm/libtorrent:1.2.2-alpine /usr/lib/python3.7/site-packages/libtorrent*.so /usr/lib/python3.7/site-packages/
COPY --from=emmercm/libtorrent:1.2.2-alpine /usr/lib/python3.7/site-packages/python_libtorrent-*.egg-info /usr/lib/python3.7/site-packages/

# ports and volumes
EXPOSE 9091 51413 3539
VOLUME /config /downloads /watch /flexget
