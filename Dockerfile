FROM linuxserver/transmission

# flexget version
ARG FG_VERSION

# install transmission web control
ADD https://github.com/ronggang/transmission-web-control/raw/master/release/src.tar.gz /usr/share/transmission/web
RUN cd /usr/share/transmission/web && \
	tar -zxf src.tar.gz && \
	rm src.tar.gz

# install python, flexget, and other dependencies
RUN apk add --no-cache python && \
	python -m ensurepip && \
	rm -r /usr/lib/python*/ensurepip && \
	pip install --upgrade pip setuptools && \

	apk add --no-cache ca-certificates && \
	pip install --upgrade --force-reinstall --ignore-installed \
		transmissionrpc python-telegram-bot "flexget==${FG_VERSION}" && \
	rm -r /root/.cache

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 9091 51413 3539
VOLUME /config /downloads /watch /flexget
