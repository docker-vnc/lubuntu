Lubuntu Desktop in Docker

## take a look

```bash
docker run -d --hostname lubuntu --name lubuntu --restart always -p 5901:5901 -e TZ=Asia/Jakarta vncserver/lubuntu
```

### default vnc

```bash
host: 127.0.0.1:5901
username: developer
password: vncpasswd
```
