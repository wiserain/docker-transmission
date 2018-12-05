FROM linuxserver/transmission

RUN \
	echo "**** install transmission web control ****" && \
	wget -P /tmp https://github.com/ronggang/transmission-web-control/raw/master/release/install-tr-control.sh && \
	echo -ne "1\n" | bash /tmp/install-tr-control.sh && \
	echo "**** install utils ****" && \
	apk add --no-cache mediainfo findutils && \
	echo "**** cleanup ****" && \
	rm -rf \
		/tmp/* \
		/root/.cache

# ports and volumes
EXPOSE 9091 51413
VOLUME /config /downloads /watch
