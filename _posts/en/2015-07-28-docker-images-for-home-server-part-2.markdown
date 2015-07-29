---
layout: post
title: "Docker images for home server. Part 2."
categories: en
tags: [docker, services, home server, guacamole]
---

I already told you that [I use docker at home](/en/archive/2015/03/18/docker-for-home-server/)
to run GitLab and Netatalk. Every month my list of containers which I host on my home server is growing
for various reasons. Sometimes I just want to use something, sometimes I need it and
sometimes I just want to take a quick look on it.
So I decided to keep sharing some useful images and tips and tricks about them with you.

This blog post is numbered with `Part 2`, because I believe that I already showed you some containers in [Using docker at home](/en/archive/2015/03/18/docker-for-home-server/).

## Guacamole

From [http://guac-dev.org](http://guac-dev.org):

> Guacamole is a clientless remote desktop gateway. It supports standard protocols like VNC and RDP.

Guacamole is a free, open source, written in HTML5, console for your home network. It can connect
to VNC, RDP or SSH to computers at your home network (or any computer it has access to).

[Glyptodon LLC](http://glyptodon.org) has official images on [docker registry](https://registry.hub.docker.com/repos/glyptodon/)
and [official documentation](http://guac-dev.org/doc/gug/guacamole-docker.html).
One of the images is a server which knows how to initialize connection
and another one is a web server.
By default web server image requires linked database. It can be PostgreSQL or MySQL.
But Guacamole supports also static configuration with
[user-mapping.xml](http://guac-dev.org/doc/gug/configuring-guacamole.html#basic-auth)
if you don't want to use PostgreSQL or MySQL.

If you want to use `user-mapping.xml` instead of databases you can just override/modify
[docker image](https://github.com/glyptodon/guacamole-docker).
You need to remove check that one of the databases is configured and copy
`user-mapping.xml` in `/root/.guacamole/`.

For example you can keep three files to build your own docker image

- `Dockerfile` (it is based on official image)

```
FROM glyptodon/guacamole:latest

RUN mkdir -p /root/.guacamole/
COPY user-mapping.xml /root/.guacamole/
COPY startx.sh /opt/guacamole/bin/
RUN chmod +x /opt/guacamole/bin/startx.sh

CMD ["/opt/guacamole/bin/startx.sh"]
```

- `startx.sh` (this is just a stripped version of official [start.sh](https://github.com/glyptodon/guacamole-docker/blob/master/bin/start.sh) where I removed everything related to databases)

```
#!/bin/bash

GUACAMOLE_HOME="$HOME/.guacamole"
GUACAMOLE_EXT="$GUACAMOLE_HOME/extensions"
GUACAMOLE_LIB="$GUACAMOLE_HOME/lib"
GUACAMOLE_PROPERTIES="$GUACAMOLE_HOME/guacamole.properties"

set_property() {

    NAME="$1"
    VALUE="$2"

    # Ensure guacamole.properties exists
    if [ ! -e "$GUACAMOLE_PROPERTIES" ]; then
        mkdir -p "$GUACAMOLE_HOME"
        echo "# guacamole.properties - generated `date`" > "$GUACAMOLE_PROPERTIES"
    fi

    # Set property
    echo "$NAME: $VALUE" >> "$GUACAMOLE_PROPERTIES"

}

start_guacamole() {
    cd /usr/local/tomcat
    exec catalina.sh run
}

mkdir -p "$GUACAMOLE_EXT"
mkdir -p "$GUACAMOLE_LIB"

set_property "guacd-hostname" "$GUACD_PORT_4822_TCP_ADDR"
set_property "guacd-port"     "$GUACD_PORT_4822_TCP_PORT"

start_guacamole
```

- `user-mapping.xml` (follow [official documentation](http://guac-dev.org/doc/gug/configuring-guacamole.html#basic-auth) to create one for yourself)

After that you can create `docker-compose.yml` file like

```
guacd:
  image: glyptodon/guacd:latest
  mem_limit: 2g
  cpu_shares: 256
  restart: always

web:
  build: .
  links:
    - guacd
  environment:
    - VIRTUAL_HOST=guacamole.example.com
  mem_limit: 2g
  cpu_shares: 256
  restart: always
```

> `VIRTUAL_HOST` is set because I use [nginx-proxy](https://github.com/jwilder/nginx-proxy), see [Using docker at home](/en/archive/2015/03/18/docker-for-home-server/) for details.

And one last thing. To get access to the guacamole you will need to use path
`/guacamole`. The root path `/` will show you default web page of TomCat server.
It is possible to change it. I am not a TomCat expect, so I used the simplest
solution, in my `Dockerfile` I added three more lines

```
RUN rm -fR /usr/local/tomcat/webapps/ROOT/*

COPY robots.txt /usr/local/tomcat/webapps/ROOT/
COPY index.html /usr/local/tomcat/webapps/ROOT/
```

Where:

- `index.html` automatically redirects clients to the `/guacamole` path

```html
<META HTTP-EQUIV="Refresh" CONTENT="0; URL=/guacamole/"/>
```

- `robots.txt` disables robots

```
User-Agent: *
Disallow: /
```

I was really surprised how great is this tool. The one problem which I could not solve
is connection to the OS X VNC Server. But because I use [SSH tunneling](/en/archive/2015/07/22/how-to-avoid-vpn-at-home/)
to access my OS X server, that wasn't an issue for me.
