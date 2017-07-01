---
layout: post
title: "Using docker at home"
date: 2015-03-18 00:00:00 -00:08:00
categories: en
tags: [docker, ubuntu, home server, gitlab, netatalk]
---

Yeah, I know. Docker is everywhere. I have read so many articles about it in last few years, but have not used it for anything, have not even tried to run any docker hosts or containers. Why? Just did not have a reason for that. I thought that I did not have any reasons. Until I found these two docker images [docker-netatalk](https://github.com/cptactionhank/docker-netatalk) and [docker-gitlab](https://github.com/sameersbn/docker-gitlab). This is when I realized, why people like Docker. Because of the community. Because of the number of awesome images available on GitHub and supported by community.

I'm not going to write one more introduction into Docker type of article. I will just give you some links and show you how I use it at home.

## Where to start?

At first you need to get familiar with Docker. Just go and read some basics [About Docker](https://docs.docker.com).

At second you need to install docker. In my case I have docker installed on my Ubuntu `14.04.2 LTS` (with kernel `3.13`). To install it on Ubuntu just follow the docker manual [Docker-maintained Package Installation](https://docs.docker.com/installation/ubuntulinux/#docker-maintained-package-installation) (I would recommend to install Docker-maintained packages instead of Ubuntu-maintained).

At third read about [Docker Compose](https://docs.docker.com/compose/) which allows you to persist settings about running docker containers. You can look on more information about Docker Compose on [GitHub](https://github.com/docker/compose).

And after that let's take a look on what you can do with Docker.

## Docker-GitLab

Do you want to have you own Git server? Try [GitLab](https://gitlab.com). To install it use [Docker-Gitlab](https://github.com/sameersbn/docker-gitlab).

[Docker-GitLab](https://github.com/sameersbn/docker-gitlab) has very good `README.md` file, and it is very configurable. This image has few dependencies, but you should not be worried by that, with Docker it is very easy to set everything up.

I can just show you what I have in my `docker-compose.yaml` file

```yaml
gitlabpostgresql:
    image: sameersbn/postgresql:latest
    volumes:
        - /mnt/DATA/gitlab-postgresql:/var/lib/postgresql
    environment:
        - DB_NAME=gitlabhq_production
        - DB_USER=gitlab
        - DB_PASS=<StrongDBPassword>
    mem_limit: 4g
    cpu_shares: 256
    restart: always

gitlabredis:
    image: sameersbn/redis:latest
    volumes:
        - /mnt/DATA/gitlab-redis:/var/lib/redis
    mem_limit: 4g
    cpu_shares: 256
    restart: always

gitlab:
    hostname: gitlab
    image: sameersbn/gitlab:7.8.4
    links:
        - gitlabpostgresql:postgresql
        - gitlabredis:redisio
    volumes:
        - /mnt/DATA/gitlab-data:/home/git/data
        - /mnt/BACKUP/gitlab-backups:/home/git/backups
    environment:
        - VIRTUAL_HOST=gitlab
        - GITLAB_EMAIL=gitlab@example.com
        - SMTP_USER=outcoldman
        - SMTP_PASS=<MySmtpPassword>
        - SMTP_HOST=smtp.sendgrid.net
        - GITLAB_PORT=80
        - GITLAB_SSH_PORT=10022
        - GITLAB_HOST=gitlab
        - GITLAB_BACKUP_DIR=/home/git/backups
        - GITLAB_BACKUPS=daily
        - GITLAB_BACKUP_EXPIRY=1209600
        - OAUTH_GITHUB_API_KEY=<ReadAboutThisInREADME.md>
        - OAUTH_GITHUB_APP_SECRET=<ReadAboutThisInREADME.md>
    ports:
        - "10022:22"
    mem_limit: 2g
    cpu_shares: 256
    restart: always
```

Let's take a look on this configuration in details:

* I have three containers defined here. One for running `postgresql`, second for `redis` and last one is the `gitlab` container.
* As you can see `gitlab` has links to first two containers. As you see I don't even set Database password to the `gitlab` container, as it can get it from `gitlabpostgresql` container on its own using variables defined in linked container.
* For each container I specified `mem_limit` based on recommendations and my feeling about how I will use them.
* For each container I specified `cpu_shares` where `1024` means `100%`, see [Runtime constraints on CPU and memory](https://docs.docker.com/reference/run/#runtime-constraints-on-cpu-and-memory).
* For each container I specified restart `always` as I want to have this container booted even after I reboot my host.
* For each container I specified `volumes`, which I want to mount to them from my host server. I want to store real data on my host server, because if I will rebuild docker container I can keep my data. You can also see that one of the volumes contains backups from GitLab.
* I use [SendGrid](https://sendgrid.com) for SMTP.
* As you can see in my environment I access GitLab by url `http://gitlab`, this is why this hostname is specified in `GITLAB_HOST` and `VIRTUAL_HOST` (this one is not a variable required by GitLab, I will tell you below why I have it) and this is why I have `GITLAB_PORT=80`.
* As you can see I expose to server only one port `10022` as a `SSH` port of GitLab server.I don't want to expose it as port `22` because I still want to use `22` for host.
* Read about `OAUTH_GITHUB_*` keys here [GitHub](https://github.com/sameersbn/docker-gitlab#github).

I knew that I will need port 80 on my home server for more than just GitLab. This is why I decided also to setup reverse proxy with [nginx](http://nginx.com). It is very easy to do with [nginx-proxy](https://github.com/jwilder/nginx-proxy) docker image. This is another Docker container I have defined (still in `docker-compose.yml`)

```yaml
nginxproxy:
    image: jwilder/nginx-proxy
    ports:
        - 80:80
    volumes:
        - /var/run/docker.sock:/tmp/docker.sock
    mem_limit: 512m
    cpu_shares: 128
    restart: always
```

`VIRTUAL_HOST` from `gitlab` container helps this container to auto configure reverse proxy.

But to make it work you need to have a DNS record on your client machine about gitlab hostname. I did that very easy by specifying this record in my [DD-WRT router]({{ site.url }}/en/archive/2015/02/11/give-your-router-second-chance/). If you don't have ability to do that with router you have two options: specify this as a static record on all of your machines in `/etc/hosts` (`%WIN_DIR%\system32\drivers\etc\hosts`) or you can configure your own DNS server with [dnsmasq](https://registry.hub.docker.com/u/sroegner/dnsmasq/) docker image.

Now you can install other images (redmine, owncloud) and host all of them on the same server. Name the product, my bet you can find docker image for it.

To start all of defined containers, just run in the same folder where you saved your `docker-compose.yml` (I store it under `/etc` with `rw` permissions for root only)

```bash
docker-compose up -d
```

## Netatalk

One of the ways to install Netatalk is to use one of the manuals available on the web, I also wrote one [AFP Server (for OS X)]({{ site.url }}/en/archive/2014/11/09/ubuntu-as-home-server-part-3-afp-server/). But the problem with all of them - always hard to keep them up do date. Is there are better way? Of course, just use a docker image [docker-netatalk](https://github.com/cptactionhank/docker-netatalk). This image is not so configurable as `GitLab` image, so to make it work as you want you probably need to do a little bit more steps. I found that the easiest way to configure it with my needs is to build my own image based on this image. Just a note I use Netatalk only as a TimeMachine server. For file sharing I use Samba ...without Docker.

I have two files, my own `afp.conf`, which is based on the `afp.conf` file from [original](https://github.com/cptactionhank/docker-netatalk/blob/master/root/usr/src/netatalk/patches/afp.conf.tmpl.patch) image

```yaml
; Netatalk 3.x configuration file
;

[Global]
; Global server settings

; enable spotlight and correct the dbus daemon path
dbus daemon = /usr/bin/dbus-daemon
spotlight = yes

; provide AFP runtime statistics (connected users, open volumes) via dbus.
afpstats = yes

; no need in guest access, only user accounts
uam list = uams_dhx2.so uams_dhx.so

; output log entries to stdout instead of syslog
log file = /dev/stdout
log level = default:note

hostname = timemachine
zeroconf = yes

[TimeMachine]
    path = /TimeMachine
    time machine = yes
    vol size limit = 1000000
    valid users = outcoldman
```

As you can see I only define my own hostname (`timemachine`, which I also expose with my DNS server) and define my time machine share `TimeMachine`.

The second file is the `Dockerfile` (the file which is used to build my custom image)

```bash
FROM cptactionhank/netatalk:latest
MAINTAINER Denis Gladkikh "https://github.com/outcoldman"

RUN groupadd -g1000 outcoldman
RUN useradd --no-create-home -u1000 -g1000 -G users outcoldman
RUN echo "outcoldman:MySpecialPassword" | chpasswd 

COPY ./afp.conf /etc/netatalk/afp.conf
```

Here I just create user `outcoldman` with the same `uid` as I have on my host server, so if I will need to access these files from my host server I will have the same permissions as user in Docker container.

After that just run command

```bash
docker build -t my/netatalk .
```

This command will build your own image.

Now you can update your `docker-compose.yml` file to include `timemachine` container

```yaml
timemachine:
    image: my/netatalk
    volumes:
        - /mnt/BACKUP/TimeMachine:/TimeMachine
    mem_limit: 512m
    cpu_shares: 128
    net: host
    hostname: timemachine
    restart: always
```

And just run 

```bash
docker-compose up -d timemachine
```
