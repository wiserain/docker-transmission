# docker-transmission

This container is with

- [linuxserver/transmission](https://hub.docker.com/r/linuxserver/transmission/)
- Transmission web coltrol by [ronggang](https://github.com/ronggang/transmission-web-control)

## Usage

```
docker run -d \
    -v <path to config>:/config \
    -v <path to downloads>:/downloads \
    -v <path to watch folder>:/watch \
    -e PGID=<gid> -e PUID=<uid> \
    -e TZ=<timezone> \
    -p 9091:9091 -p 51413:51413 -p 51413:51413/udp \
    wiserain/transmission:only
```
