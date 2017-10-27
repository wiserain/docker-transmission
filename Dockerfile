FROM lsiobase/alpine:3.6
MAINTAINER sparklyballs

# flexget version
ARG FG_VERSION="2.10.104"

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"

# install packages
RUN \
 apk add --no-cache \
	curl \
	jq \
	openssl \
	p7zip \
	rsync \
	tar \
	transmission-cli \
	transmission-daemon \
	unrar \
	unzip

# install transmission web control
ADD https://github.com/ronggang/transmission-web-control/raw/master/release/transmission-control-full.tar.gz /usr/share/transmission/
RUN cd /usr/share/transmission && \
	tar -zxf transmission-control-full.tar.gz && \
	rm transmission-control-full.tar.gz

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
