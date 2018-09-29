FROM linuxserver/transmission

# install transmission web control
ADD https://github.com/ronggang/transmission-web-control/raw/master/release/install-tr-control.sh /tmp
RUN cd /tmp && \
	echo -ne "1\n" | bash install-tr-control.sh && \
	rm install-tr-control.sh

# install frolvlad/alpine-python3
RUN apk add --no-cache python3 && \
	python3 -m ensurepip && \
	rm -r /usr/lib/python*/ensurepip && \
	pip3 install --upgrade pip setuptools && \
	if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip ; fi && \
	if [[ ! -e /usr/bin/python ]]; then ln -sf /usr/bin/python3 /usr/bin/python; fi && \
	rm -r /root/.cache && \
	# install flexget and addons
	apk add --no-cache ca-certificates tzdata mediainfo py3-cryptography && \
	pip3 install --upgrade \
		transmissionrpc \
		python-telegram-bot \
		flexget && \
	rm -r /root/.cache

# copy local files
COPY root/ /

# ports and volumes
# EXPOSE 9091 51413 3539
VOLUME /config /downloads /watch /flexget
