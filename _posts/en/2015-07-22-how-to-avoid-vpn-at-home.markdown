---
layout: post
title: "How to avoid VPN at home"
categories: en
tags: [VPN, OpenVPN, SSH, HTTPS, SSL, VNC]
---

In October 2014 I wrote a [blog post]({{site.url}}/en/archive/2014/10/21/ubuntu-as-a-home-server-part-2-openvpn/) 
about how to setup Open VPN at home to have access to home server and all services from outside.
This setup worked fine for me for a last year, but there were few annoying things which I did not like:

- It was hard to make it work with VPN we use at my work. Conflicts in routing table.
  You forget to disconnect one of the VPNs when you put your laptop in sleep and
  after that you will start your day from cleaning routing table.
- It is impossible to keep it connected all the time. But I need to have connection
  all the time to some services at home, like my GitLab server (where I host my
  configurations and dotfiles) or my wiki server, where I host my cheatsheets.
- If you get new device - you need to set it up from the beginning to make it work
  with VPN.

I knew very simple solution: don't use VPN, just expose all services outside.
Obviously not the most secure solution. You don't want to connect to them over
HTTP. I'm not a paranoiac, but if it is possible to make it a little bit more secure
with small effort - why not do that. So I will be less worry about when I should
and when I should not connect to my home services when I'm connected to public
Wi-Fi hotspot.

I bought a [wildcard certificate](https://www.namecheap.com/security/ssl-certificates/comodo/positivessl-wildcard.aspx)
and using the same [docker deployment]({{site.url}}/en/archive/2015/03/18/docker-for-home-server/)
I used with VPN. I have set it up with the help of [nginx-proxy](https://github.com/jwilder/nginx-proxy).
Now with I can very simple to deploy any service I want on my domain. For
example if I want to deploy Jenkins I can just pull the image, run it in docker with
special environment variable `-e="VIRTUAL_HOST=jenkins.example.com"` and I will
have access to it from outside over HTTPS. Pertty cool. Wildcard certificates are
expensive, and it was possible to use cheaper solutions:

- Own signed certificate. But one of the annoying things will be to install root
  certificate to all your clients. Or just ignore warnings and certificate validation
  (which is not great).
- One domain. And expose all services by using various root paths, like `https://example.com/gitlab`
  or `https://example.com/wiki`. It will be hard to make all services to work in that way.
- Multi-domain certificate. You need to know all services ahead. Or you will need
  to regenerate it over and over.

So my setup consists now from next components:

- Ubuntu server with Docker. Where I host a lot of services. Also two important containers
  are ddclient (see [Dynamic DNS](https://www.outcoldman.com/en/archive/2014/10/14/ubuntu-as-a-home-server-part-1-dynamic-dns/))
  and [nginx-proxy](https://github.com/jwilder/nginx-proxy).
- My router forwards next ports:
    - `80` to nginx-proxy, which actually always redirects to `443`.
    - `443` to nginx-proxy for HTTPS connections.
    - `10022` to GitLab (actually to Ubuntu server, which has GitLab docker image, which
      exposes SSH over this port). This is `SSH` connection to make git work over SSH.
    - `22` to my Mac mini.
- On my Mac mini I disabled plain text passwords. So it is possible to connect to it
  only using SSH public keys installed in `~/.ssh/authorized_keys`, so nobody will be
  able to brute force my password. It is easy to do, just modify file `/etc/sshd_config`,
  change the line `ChallengeResponseAuthentication no` from `yes` to `no`.

And the great part about SSH - you can tunnel anything from the internal network
through SSH using next command

```
ssh user@example.com -L {LOCAL_PORT}:{REMOTE_SERVICE}:{REMOTE_PORT}
```

Where

- `user` - the username you use to connect to remote service
- `example.com` - remote machine name
- `{LOCAL_PORT}` - local port on your local machine which will be used to tunnel traffic
- `{REMOTE_SERVICE}` - remote service which can be accessible from remote machine
- `{REMOTE_PORT}` - port of remote service which you want to access

For example this is how you tunnel VNC

```
ssh user@example.com -L 15900:127.0.0.1:5900
```

Now you can connect to the `vnc://127.0.0.1:15900` and it will forward you to the
`example.com:5900` using `example.com:22`.

This is how you tunnel VNC for some other machine in your home network

```
ssh user@example.com -L 25900:ubuntubox:5900
```

So now if you will try to connect to `vnc://127.0.0.1:25900` you will be tunneled
to the `ubuntubox:5900` in your home network.

## Useful tips:

- If you will buy certificate from Comodo, read this [Certificate Installation: NGINX](https://support.comodo.com/index.php?/Default/Knowledgebase/Article/View/789/37/)
  about how to install certificates on nginx. Nothing hard, just don't forget
  to combine three certificates in one. In other case you will see that some
  clients will reject your certificates (linux and Firefox).
- If you will use ssh tunneling for VNC: most of the VNC clients support SSH
  tunneling as a configuration and they will automatically set up everything.
  I use [Jump Desktop](http://jumpdesktop.com), which has built-in configuration for SSH.
