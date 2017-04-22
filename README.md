# docker-transmission

This container is

- based on [linuxserver/transmission](https://hub.docker.com/r/linuxserver/transmission/)
- transmission web coltrol by [ronggang](https://github.com/ronggang/transmission-web-control)
- [flexget](http://flexget.com/)
 
## Usage

```
docker run -d \
    -v <path to config>:/config \
    -v <path to downloads>:/downloads \
    -v <path to watch folder>:/watch \
    -v <path to flexget folder>:/flexget \
    -e PGID=<gid> -e PUID=<uid> \
    -e TZ=<timezone> \
    -e FG_WEBUI_PASSWD=<your password> \
    -p 9091:9091 -p 51413:51413 -p 3539:3539 \
    -p 51413:51413/udp \
    wiserain/transmission
```
