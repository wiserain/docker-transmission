# docker-transmission

This container is with

- [linuxserver/transmission](https://hub.docker.com/r/linuxserver/transmission/)
- Transmission web coltrol by [ronggang](https://github.com/ronggang/transmission-web-control)
- [Flexget](http://flexget.com/)

~~Note that a default password for webui is set to ```f1exgetp@ss```.~~

No default password anymore, secure webui using ```FG_WEBUI_PASSWD``` below.

As of Flexget 2.13.22, Python 3 is used for better handling of unicode encoding.

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
    -p 9091:9091 -p 51413:51413 -p 51413:51413/udp \
    -p 3539:3539 \
    wiserain/transmission:flexget
```
