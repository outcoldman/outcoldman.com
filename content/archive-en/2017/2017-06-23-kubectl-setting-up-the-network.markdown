---
categories: en
date: "2017-06-23T00:00:00Z"
tags:
- kubernetes
- k8s
- docker
- kubectl
- kubeadm
- letsencrypt
title: Kubernetes network 
slug: "kubectl-setting-up-the-network"
---

I [spoke too soon](/en/archive/2017/06/20/using-kubeadm-to-create-kubernetes-on-ubuntu-server/). 
Actually I had a lot of problems in previous setup.

To be honest - kubernetes certainly requires a lot of debugging to set it up
correctly, but when you finally do that - it pays off.

And you actually do not need pod network, when you have just one server, but
I am planning to expand it to minimum of two servers, so I choose the hard path.

## Issues

### Pods could not connect outside world.

To fix that I rolled back to docker version `1.11.2`. Just uninstall the latest one,
which is probably installed as `docker-ce`

```bash
sudo apt-get purge docker-ce
```

After that take a look on some files left by docker.

```bash
sudo find / -name '*docker*'
```

In my case it left some configurations under `systemd`, `/var/lib/docker` and
`/var/run/docker/` and because of that I could not install `docker-engine`, as
it fails to install because probably scripts in `systemd` setups `docker0` network
before the *just-installed-previous-version of* docker does. So just clean all of
that, reboot and install docker.

### Pods could not resolve DNS

Next problem was with DNS. Pods could not resolve DNS names. I saw that it can
connect over IP addresses, but all DNS calls were timing out.

My problem was similar (maybe actually exactly the same) to [Misadventures with kube dns](http://blog.sophaskins.net/blog/misadventures-with-kube-dns/).
So the problem was with `/etc/resolve.conf` which by default has a value of
`nameserver 127.0.0.1`, this value exists because of local DNS cache. Ubuntu probably
knows that when it cannot connect to local DNS cache it just goes after that to
the DNS nameservers defined on network interfaces. But `kubelet` is not so smart,
it just takes default `/etc/resolve.conf` and uses it as source of truth.

You will find out a line in this file, that you should not modify this file manually,
because it is auto-generated file by `resolvconf`. 

I have found a root case, why I had this record. It is because of NetworkManager,
solution was simple, see [nameserver 127.0.1.1 in resolv.conf won't go away!](https://askubuntu.com/questions/627899/nameserver-127-0-1-1-in-resolv-conf-wont-go-away/627900#627900).

I was told in k8s.slack, that it is a known issue, and at some point it will be fixed.

### Helm

I looked on helm as on set of rules to use to setup some of the important configurations,
including `kubernetes-dashboard`, `heapster` and `nginx-ingress-controller`.

Most of the formulas which I have tried do not support [RBAC yet](https://kubernetes.io/docs/admin/authorization/rbac/).
You can turn it off. But I like that I have an ability to disable access to most
of the kubernetes API endpoints for most of applications.

So I went different route and decided to maintain my own configurations. That requires
some time to learn configurations.

## Tips

### Join k8s.slack

Join [slack.k8s.io](http://slack.k8s.io), you can get help from some developers
of kubernetes or plugins for kubernetes or some other souls, who had similar issues.

### kubectl explain

Kubernetes has [decent documentation](https://kubernetes.io/docs/home/). But sometime
it is much easier to look on [API Reference](https://kubernetes.io/docs/api-reference/v1.6/).

And you can get quick access to it from command line, like

```bash
kubectl explain roles
```

### Use ingress

Install nginx-ingress-controller. Look on the [examples](https://github.com/kubernetes/ingress/tree/master/examples).
If you use kubernetes which is initialized by kubeadm you need to use combination
of [kubeadm](https://github.com/kubernetes/ingress/tree/master/examples/deployment/nginx/kubeadm) and
[rbac](https://github.com/kubernetes/ingress/tree/master/examples/rbac/nginx).

Read how it can be configured with [annotations](https://github.com/kubernetes/ingress/blob/master/docs/annotations.md).

### Basic auth for nginx

I could not find an example of how to configure basic auth for nginx ingress.
Just make sure you are aware of format for [ngx_http_auth_basic_module](http://nginx.org/en/docs/http/ngx_http_auth_basic_module.html).
Plain text can have a format of `user:{PLAIN}password`, after that just base64 it.

### Use kube-lego

[Kube-lego](https://github.com/jetstack/kube-lego) allows you to automatically
configure TLS and generate LetsEncrypt certificates. Just be aware, that by
default it is using Staging authority, which generates fake certificates, and
when you will switch to Production - you will probably have similar issue to
[Issue with switching from LE staging to LE prod: 403 urn:acme:error:unauthorized: No registration exists matching provided key"](https://github.com/jetstack/kube-lego/issues/160).
You can find solution to this issue in that thread. It is as simple as you need to
delete a secret `kube-lego-account`.

### Non kubernetes services can be ingressed as well with kubernetes

I have [mentioned before](/en/archive/2016/05/15/os-x-server-web-server-proxy/)
that I have a SecuritySpy server on one of my Mac Mini boxes. You can configure
Kubernetes, so it will redirect traffic to this service inside your home network,
and deal wit TSL, automatic generation of LetsEncrypt certificates.

To do that you need to configure Endpoint, Service and Ingress. Look on [Services without selector](https://kubernetes.io/docs/concepts/services-networking/service/).

