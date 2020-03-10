FROM linuxserver/transmission:latest

ENV TRANSMISSION_WEB_HOME="/transmission-web-control/"

RUN \
	echo "**** install python ****" && \
	apk add --no-cache python3 && \
	if [[ ! -e /usr/bin/python ]]; then ln -sf /usr/bin/python3 /usr/bin/python; fi && \
	python3 -m ensurepip && \
	rm -r /usr/lib/python*/ensurepip && \
	pip3 install --no-cache --upgrade pip setuptools==45.3.0 wheel && \
	if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip; fi && \
	echo "**** install plugin: telegram ****" && \
	apk add --no-cache py3-cryptography && \
	pip install --upgrade PySocks && \
	pip install --upgrade python-telegram-bot && \
	echo "**** install plugins: cfscraper ****" && \
	apk add --no-cache --virtual=build-deps g++ gcc python3-dev libffi-dev openssl-dev && \
	pip install --upgrade cloudscraper && \
	apk del --purge --no-cache build-deps && \
	echo "**** install plugins: convert_magnet ****" && \
	apk add --no-cache boost-python3 libstdc++ && \
	echo "**** install plugin: misc ****" && \
	apk add --no-cache mediainfo && \
	pip install --upgrade \
		transmissionrpc \
		deluge_client \
		irc_bot && \
	echo "**** install plugins: rar ****" && \
	apk add --no-cache unrar && \
	pip install --upgrade \
		rarfile && \
	echo "**** install flexget ****" && \
	apk add --no-cache --virtual=build-deps gcc libxml2-dev libxslt-dev libc-dev python3-dev && \
	pip install --upgrade --force-reinstall \
		flexget && \
	apk del --purge --no-cache build-deps && \
	apk add --no-cache libxml2 libxslt && \
	echo "**** cleanup ****" && \
	rm -rf \
		/tmp/* \
		/root/.cache

# copy local files
COPY root/ /

# copy libtorrent libs
COPY --from=emmercm/libtorrent:1.2.5-alpine /usr/lib/libtorrent-rasterbar.a /usr/lib/
COPY --from=emmercm/libtorrent:1.2.5-alpine /usr/lib/libtorrent-rasterbar.la /usr/lib/
COPY --from=emmercm/libtorrent:1.2.5-alpine /usr/lib/libtorrent-rasterbar.so.10.0.0 /usr/lib/
COPY --from=emmercm/libtorrent:1.2.5-alpine /usr/lib/python3.8/site-packages/libtorrent.cpython-38-x86_64-linux-gnu.so /usr/lib/python3.8/site-packages/
COPY --from=emmercm/libtorrent:1.2.5-alpine /usr/lib/python3.8/site-packages/python_libtorrent-1.2.5-py3.8.egg-info /usr/lib/python3.8/site-packages/

# symlink libtorretn libs
RUN \
	cd /usr/lib && \
	ln -s libtorrent-rasterbar.so.10.0.0 libtorrent-rasterbar.so && \
	ln -s libtorrent-rasterbar.so.10.0.0 libtorrent-rasterbar.so.10

# ports and volumes
EXPOSE 9091 51413 3539
VOLUME /config /downloads /watch /flexget
