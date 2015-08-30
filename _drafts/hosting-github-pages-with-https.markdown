---
layout: post
title: "Hosting GitHub Pages with HTTPS"
categories: en
tags: [jekyll, github pages, https, nginx, docker, jenkins]
---

Sad but true: GitHub Pages still does not support HTTPS for custom domains (see
[Add HTTPS support to Github Pages](https://github.com/isaacs/github/issues/156) -
this is not an official bug tracking for GitHub Pages). You basically have just
two options:

- Host it on `*.github.io` using this trick
    [GitHub Pages Now (Sorta) Supports HTTPS, So Use It](https://konklone.com/post/github-pages-now-sorta-supports-https-so-use-it)
- Host it on your own

I chose second option for three reasons:

- I want to have SSL
- I want to have `draft` version of my website
- I want to track logs to nginx

At the end I got the same (and even better) workflow as I had with GitHub pages,
where:

- I host my jekyll sources on my own GitLab server at home.
- I host my own jenkins on my own server at home.
- I host my website on [DigitalOcean](https://www.digitalocean.com/?refcode=2bf7395aa5fd)
    (here and later referal links, which gives you $10 on account) with
    `512mb` droplet.
- I host Splunk Forwarder on DigitalOcean for forwarding logs from Nginx.
- I host draft version of my website at home.
- Each commit/push triggers auto deploy to the `production` and `staging` versions.

Now let's go in details how you can do that.

## Preparing sources

As I said I host my own GitLab server at home using Docker (see [Using docker at home](https://outcoldman.com/en/archive/2015/03/18/docker-for-home-server/)),
so at first I moved my repository from GitHub to my own GitLab (this is not a
requirement, I just did it because it was easier for me to do).

I use [rbenv](https://github.com/sstephenson/rbenv) to not mess with the system installed `ruby` (on OSX),
so in my case I have a `.ruby-version` file

```text
2.0.0-p645
```

Also I created a Makefile which contains most important steps for me

```make
# Install tools, requiered for building
installtools:
	@npm install bower
	@rbenv install -s
	@rbenv exec gem install bundle

# Don't need to run it often, just few client side dependencies,
# allows me to update dependency css and font-awesome.
updateclientdeps:
	@bower install
	@cp bower_components/pygments/css/monokai.css css/syntax.css
	@cp bower_components/normalize-css/normalize.css css/normalize.css
	@cp bower_components/font-awesome/css/font-awesome.min.css css/font-awesome.min.css
	@cp bower_components/font-awesome/fonts/* fonts/

# Install ruby/jekyll/github-pages dependencies
deps:
	@rbenv exec bundle install
	@rbenv rehash

# To build a local version of website (including drafts and right links)
build-local:
	@rbenv exec bundle exec jekyll build --draft --config=_config.yml,_local_config.yml

# To build staging version of website (including drafts and right links)
build-staging:
	@rbenv exec bundle exec jekyll build --draft --config=_config.yml,_staging_config.yml

# To build production version (without drafts)
build-production:
	@rbenv exec bundle exec jekyll build --config _config.yml

# Just to server local version
server-local:
	@rbenv exec bundle exec jekyll server --watch --draft --config=_config.yml,_local_config.yml

# Fix permissions before deploying to nginx servers
predeploy-fix-permissions:
	@find ./_site/ -type f -exec chmod 644 {} +
	@find ./_site/ -type d -exec chmod 755 {} +

# Deploy staging version
deploy-staging: predeploy-fix-permissions
	@rsync -r --rsh="ssh -p9022" --checksum --delete-after --delete-excluded --numeric-ids ./_site/ root@myhomeserver:

# Deploy production version
deploy-production: predeploy-fix-permissions
	@rsync -r --rsh="ssh -p9022" --checksum --delete-after --delete-excluded --numeric-ids ./_site/ root@outcoldman.com:
```

I tried to explain everything in my Makefile with comments, but still few words
about my workflow

- `make installtools` - Install dependencies, including right version of ruby (
    `rbenv` should be installed already), bower and bundle for ruby.
- `make updateclientdeps` - I don't need to do that often, but still want to be
    sure that I have somewhere list of client depenceny libraries. Where I got
    them and how to upgrade them.
- `make deps` - Just a ruby dependencies. It actually installs `jekyll` and
    `github-pages` or whatever you have in your `Gemfile`, in my case it (just
    a note that I do not need to use `github-pages` anymore, I can just switch
    to `jekyll`, this is on my list)

```
source 'https://rubygems.org'
gem 'github-pages'%
```

- `make build-*` - Three versions of website `local`, `production` and `staging`.
    Allows me to override URLs and remove Disqus with Google Analytics when
    I don't need them.
- `make serve-local` - Just for testing to see website locally.
- `make predeploy-fix-permissions` - Because this files will be copied with `root`
    as owner, I want to be sure that `nginx` user will have read-only access to
    these files.
- `make deploy-*` - Allows me to `rsync` using `ssh` to remote servers. See
    below about what is needs to be done on remote servers to allow these
    deployments.

As you can see I have three version of configuration for jekyll, the base one
`_config.yml`

```yaml
author: Denis Gladkikh
description: Blog about software development
url: https://outcoldman.com
title: Blog about software development
deployment: production

markdown: redcarpet
permalink: /:categories/archive/:year/:month/:day/:title/
safe: false

disqus_short_name: outcoldman
disqus_show_comment_count: false
disqus_registered_url: https://outcoldman.com

google_analytics_tracking_id: UA-7023371-5

gems:
  - jekyll-sitemap

exclude:
  - .gitignore
  - .ruby-version
  - Gemfile
  - Gemfile.lock
  - Makefile
  - _config.yml
  - _local_config.yml
  - _staging_config.yml
  - bower.json
  - bower_components
  - docker-compose.yml
  - node_modules
```

And two overrides: `_local_config.yaml`

```yaml
url: http://localhost:4000
deployment: local
```

and `_staging_config.yaml`

```
url: https://outcoldman-staging.myhomeserver.com
deployment: staging
```

Few things are important in these configurations:

- Don't forget to specify all files you want to exclude! Especially if you have
    sensitive information in them.
- My overrides allow me to change a root URL in the links. I use this URL
    when I generate `sitemap.xml` or rss feed.
- Also my overrides allow me to specify type of deployment. I use it to exclude
    Google Analytics or Disqus from local and staging deployments, like

```text
{% if site.deployment == "production" %}
    <!-- Include disqus or Google Analytics -->
{% endif %}
```

## Setting up nginx servers

As I mentioned in [Using docker at home](https://outcoldman.com/en/archive/2015/03/18/docker-for-home-server/)
I use [nginx-proxy](https://github.com/jwilder/nginx-proxy), which allows me to
easily host multiple websites on the same server in separate docker containers.
My own nginx servers serve HTTP requests on `80` port, `nginx-proxy` handles
`HTTPS` requests and forwards them to my `nginx` containers.

So on current moment I have two of `nginx-proxy` containers, one on DigitalOcean,
which serves production version, and one on my local home server to serve
staging version. Each is configured appropriately with certificates.

The other step is to configure nginx servers with SSH server installed, this is
a `Dockerfile` created for my production version

```
FROM nginx

# Install OpenSSH Server, supervisor and rsync
RUN apt-get update \
    && apt-get install -y openssh-server supervisor rsync \
    && mkdir -p /var/run/sshd

# Disable password authentication for SSH
RUN sed -i 's/#\s*PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

# Use rrsync on client
RUN mkdir -p /root/bin \
    && gunzip /usr/share/doc/rsync/scripts/rrsync.gz -c > /root/bin/rrsync \
    && chmod +x /root/bin/rrsync

# Jenkins public key (don't forget to replace JENKINS_SSH_PUBLIC_KEY with your
# SSH public key
RUN mkdir -p /root/.ssh \
    && echo 'command="/root/bin/rrsync /usr/share/nginx/html/",no-agent-forwarding,no-port-forwarding,no-pty,no-user-rc,no-X11-forwarding ssh-rsa JENKINS_SSH_PUBLIC_KEY' > /root/.ssh/authorized_keys

# Custom nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

CMD ["/usr/bin/supervisord"]
```

Also `nginx.conf`

```
user  nginx;
worker_processes  1;

error_log  /var/log/nginx/error.log warn;
pid        /var/run/nginx.pid;

events {
    worker_connections  1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile        on;
    #tcp_nopush     on;

    keepalive_timeout  65;

    gzip  on;

    server {
        listen          80;
        location / {
            root /usr/share/nginx/html;
            index index.html;
        }
        error_page 404 /404.html;
        expires 1d;
    }
}
```

And `supervisor.conf`

```
[supervisord]
nodaemon=true

[program:sshd]
command=/usr/sbin/sshd -D

[program:nginx]
command=nginx -g "daemon off;"
```

Important things from this file

- I use `supervisor` to host two processes in the same container, this is a manual
    of how to use `supervisor` [Using Supervisor with Docker](https://docs.docker.com/articles/using_supervisord/)
- I used `jekyll` documentation about [Deployment methods](http://jekyllrb.com/docs/deployment-methods/)
    to set up deployment using [rsync](http://jekyllrb.com/docs/deployment-methods/#rsync),
    this is why `~/.ssh/authorized_keys` has rsync declaration in it. It allows
    to restrict what is allowed to do using this key. Don't forget to replace
    `JENKINS_SSH_PUBLIC_KEY` with your public key from Jenkins (or any other you want).

The last step is to configure `docker-compose.yaml` file

```
nginx:
  build: .
  ports:
    - '9022:22'
  environment:
    - VIRTUAL_HOST=outcoldman.com
    - VIRTUAL_PORT=80
  mem_limit: 128m
  cpu_shares: 256
  restart: always
  log_opt:
    max-size: 10m
```

For this container I map port `9022` for `SSH` to deploy website. Port `80` will be used
by `nginx-proxy`. I'm using standard logger from this image, because I collect
everything I need from `nginx-proxy`.

For staging server I also included basic auth just to make sure that one day bots
will not start to parse it. To do that I included two more lines in `Dockerfile`

```
COPY htpasswd /etc/nginx/.htpasswd
RUN chmod 0644 /etc/nginx/.htpasswd
```

And added few more lines in `nginx.conf` (see `auth_basic*`)

```text
    # ...
    server {
        listen          80;
        location / {
            root /usr/share/nginx/html;
            index index.html;
            auth_basic  "Restricted";
            auth_basic_user_file /etc/nginx/.htpasswd;
        }
        error_page 404 /404.html;
        expires 1d;
    }
    # ...
```

To generate `htpasswd` file you can use [htpasswd](https://developer.apple.com/library/mac/documentation/Darwin/Reference/ManPages/man1/htpasswd.1.html)

```
htpasswd -c htpasswd yourusernamehere
```

At this point we have servers with nginx and SSH servers, you can actually try
to deploy them from your local environment (don't forget to include the right
public key in the nginx containers, you can include multiple if you want).

If everything works on this step - we can go to next step to automate deployment
using Jenkins.

## Setting up Jenkins

I use official jenkins [image](https://hub.docker.com/_/jenkins/). The only one
problem I saw with it - that you need to be careful with file permissions
as `jenkins` is using not root user, so every time you modify something - you
need to make sure that you fixed permissions after that.

For example when you mount `/var/jenkins_home/` you need to setup right
permissions, this is example of my `Dockerfile` which installs some dependencies
for `rbenv` and `rsync`

```
FROM jenkins

USER root

RUN apt-get update \
    && apt-get install -y \
        autoconf bison build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm3 libgdbm-dev \
        rsync \
    && rm -rf /var/lib/apt/lists/*

USER jenkins
```

As you can see I switch to `root` to do update steps and after that switch back
to `jenkins` user, the same with data volume container, I need to be sure
that volume which I share has right permissions

```yaml
vdata:
  image: busybox
  volumes:
    - /var/jenkins_home
  command: chown -R 1000:1000 /var/jenkins_home

jenkins:
  build: .
  volumes_from:
    - vdata
  environment:
    - VIRTUAL_HOST=jenkins.myhomeserver.com
    - VIRTUAL_PORT=8080
  mem_limit: 4g
  cpu_shares: 256
  restart: always
  log_opt:
    max-size: 10m
```

I'm not going to describe all `jenkins` configurations which you should do,
just mention important (to learn more about jenkins you can always find some
books, like [Jenkins. The definition guide](http://www.wakaleo.com/books/jenkins-the-definitive-guide)).

- If this is the first time you start it - setup security. Add users. Setup
    access matrix.
- Setup SMTP settings if you want to get notifications about broken builds.
- Install plugin updates.
- Install few plugins we need, which are `rbenv` and `Gitlab Hook Plugin`. I also
    tried to integrate `nodejs` with `bower` but `rbenv` does not work with `nodejs`
    plugin together in the same build, see [Using both NodeJS and Rbenv build environment plugins, rbenv is unable to create .rbenv.lock directory](https://issues.jenkins-ci.org/browse/JENKINS-24425).
- After that you need to generate SSH keys on Jenkins, just open `bash` in `jenkins`
    container and generate SSH keys following for example GitHub documentation
    (do not specify passphrase, as it will be hard to use this key in deployment
    scripts, if you want to make it more secure you can use separate scripts for
    GitLab and deployment)

```
docker exec -it jenkins_jenkins_1 bash
container$ cd /var/jenkins_home
container$ mkdir .ssh
container$ ssh-keygen -t rsa -b 4096 -C "someemail@myhomeserver.com"
```

- The other step I did, I removed `StrictHostKeyChecking` on Jenkins for my
    servers, as I recreate them very often and I don't want to upgrade fingerprint
    so often

```
container$ echo 'Host myhomeserver
>     StrictHostKeyChecking
> Host productionwebsite.com
>     StrictHostKeyChecking no' > ~/.ssh/config
```

- After that you need to go to the Jenkins configuration and add this key to
    Jenkins Credentials.
- Setup Jenkins with `GitLab` by following this [README.md](https://github.com/jenkinsci/gitlab-hook-plugin/blob/master/README.md)
    and [GitLab documentation](http://doc.gitlab.com/ee/integration/jenkins.html)
    (the last one is little out of date).
    - You will need to add `id_rsa.pub` content as deploy key to GitLab.
    - Also specify `https://jenkins.myhomeserver.com/gitlab/build_now` in WebHooks for
        project in GitLab (don't forget to fix your domain).
    - NOTE: the same `id_rsa.pub` we use for the nginx container above, which
        will allow us to deploy.
- At this point we are ready to create new project in Jenkins, where you need to
    specify
    - Name and type will be `Freestyle project`.
    - Select Source Code Management `Git`, set location, choose Credentials.
    - Select Repository Browser `GitLab`.
    - Select `rbenv build wrapper`. Set Ruby version.
    - Add build steps `Execute shell`
```
make deps
make build-staging
make deploy-staging
make build-production
make deploy-production
```
    - Add post-build action `E-mail notification`.

You are ready to build it. First build will take a lot of time, because
Jenkins will download ruby for the first time and build it, after that it will need
to download all gems.
