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
	echo "**** install plugins: cfscraper ****" && \
	apk add --no-cache --virtual=build-deps g++ gcc python3-dev && \
	pip install --upgrade cloudscraper && \
	apk del --purge --no-cache build-deps && \
	echo "**** install plugins: convert_magnet ****" && \
	# https://github.com/emmercm/docker-libtorrent/blob/master/Dockerfile
	set -euo pipefail && \
	apk add --no-cache \
		boost-python3 \
		boost-system \
		libgcc \
		libstdc++ \
		openssl && \
	apk add --no-cache --virtual=build-deps \
		autoconf \
		automake \
		boost-dev \
		coreutils \
		curl \
		file \
		g++ \
		gcc \
		git \
		libtool \
		make \
		openssl-dev \
		python3-dev && \
	cd $(mktemp -d) && \
	git clone https://github.com/arvidn/libtorrent.git && \
	cd libtorrent && \
	git checkout $(curl --silent https://api.github.com/repos/arvidn/libtorrent/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/') && \
	./autotool.sh && \
	./configure \
		CFLAGS="-Wno-deprecated-declarations" \
	    CXXFLAGS="-Wno-deprecated-declarations" \
	    --prefix=/usr \
	    --disable-debug \
	    --enable-encryption \
	    --enable-python-binding \
	    --with-libiconv \
	    --with-boost-python="$(ls -1 /usr/lib/libboost_python3*-mt.so* | head -1 | sed 's/.*.\/lib\(.*\)\.so.*/\1/')" \
	    PYTHON=`which python3` && \
	make -j$(nproc) && \
	make install && \
	apk del --purge --no-cache build-deps && \
	# recover missing symlink for python3
	ln -sf /usr/bin/python3 /usr/bin/python && \
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
