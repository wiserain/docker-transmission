FROM linuxserver/transmission

# install transmission web control
ADD https://github.com/ronggang/transmission-web-control/raw/master/release/install-tr-control.sh /tmp
RUN cd /tmp && \
	echo -ne "1\n" | bash install-tr-control.sh && \
	rm install-tr-control.sh

# install frolvlad/alpine-python2
RUN apk add --no-cache python && \
    python -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip install --upgrade pip setuptools && \
	# install flexget and addons
	apk add --no-cache ca-certificates tzdata mediainfo py2-cryptography && \
	apk add --no-cache --repository http://nl.alpinelinux.org/alpine/edge/main \
		libcrypto1.1 libssl1.1 boost-python boost-system && \
	apk add --no-cache --repository http://nl.alpinelinux.org/alpine/edge/testing \
		libtorrent-rasterbar && \
	pip install --upgrade \
		transmissionrpc \
		python-telegram-bot \
		flexget && \
	rm -r /root/.cache

# copy local files
COPY root/ /

# ports and volumes
# EXPOSE 9091 51413 3539
VOLUME /config /downloads /watch /flexget
