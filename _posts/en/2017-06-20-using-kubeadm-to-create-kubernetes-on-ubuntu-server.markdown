---
layout: post
title: "Using kubeadm to Create a Kubernetes on Ubuntu server"
categories: en
tags: [kubernetes, k8s, docker, kubectl]
---

Docker is great. Managing Docker can be a pain. Docker-compose could not answer
on all of the issues. So it always was wrapped with supporting shell scripts,
similar to what I have built for [docker-splunk](https://github.com/splunk/docker-splunk).
I have heard a lot about Kubernetes, saw it everywhere, have read a lot of articles,
but it always felt over complicated for my home infrastructure.

But the day has come. And I am so glad that I have finally looked on Kubernetes,
there are so many great things about it, so many features I have missed:

- jobs. No need to have special containers with embedded cron jobs anymore.
- init containers. Forget about building large entrypoint.sh shell scripts in
containers to support some special initialization scenarios, just use init containers.
- good dependency management between everything.
- configuration and secrets management out of the box. Forget about hundreds of
environment variables.
- ingress out of box. `nginx-proxy` is great, but it had some issues with latest
versions of docker and docker service.

If you want to play with Kubernetes - use [minikube](https://kubernetes.io/docs/getting-started-guides/minikube/).
That will allow you to setup simple single node Kubernetes deployment on VM.

> NOTE: docker currently has an issue with time to be out of sync on VM, minikube
> inherits this issue. See [known-issues](https://docs.docker.com/docker-for-mac/troubleshoot/#known-issues)
> for details and workaround.

If you are ready for next step - use kubeadm to setup Kubernetes cluster (or single
node) on own infrastructure (bare metal).

Just for reference, below are the versions I have used

```bash
$ kubeadm version
kubeadm version: version.Info{Major:"1", Minor:"6", GitVersion:"v1.6.5", GitCommit:"490c6f13df1cb6612e0993c4c14f2ff90f8cdbf3", GitTreeState:"clean", BuildDate:"2017-06-14T20:03:38Z", GoVersion:"go1.7.6", Compiler:"gc", Platform:"linux/amd64"}

$ kubectl version
Client Version: version.Info{Major:"1", Minor:"6", GitVersion:"v1.6.6", GitCommit:"7fa1c1756d8bc963f1a389f4a6937dc71f08ada2", GitTreeState:"clean", BuildDate:"2017-06-16T18:34:20Z", GoVersion:"go1.7.6", Compiler:"gc", Platform:"linux/amd64"}

$ sudo docker version
Client:
 Version:      17.03.1-ce
 API version:  1.27
 Go version:   go1.7.5
 Git commit:   c6d412e
 Built:        Mon Mar 27 17:14:09 2017
 OS/Arch:      linux/amd64

Server:
 Version:      17.03.1-ce
 API version:  1.27 (minimum version 1.12)
 Go version:   go1.7.5
 Git commit:   c6d412e
 Built:        Mon Mar 27 17:14:09 2017
 OS/Arch:      linux/amd64
 Experimental: false
$ uname -a
Linux outcoldbuntu 4.8.0-56-generic #61~16.04.1-Ubuntu SMP Wed Jun 14 11:58:22 UTC 2017 x86_64 x86_64 x86_64 GNU/Linux
$ lsb_release -a
Distributor ID: Ubuntu
Description:    Ubuntu 16.04.2 LTS
Release:    16.04
Codename:   xenial
```

## Install kubernetes on Ubuntu

Mostly just follow the manual from [Using kubeadm to Create a Cluster](https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/).
Few caveats I list below

### Docker

Kubernetes does not require latest Docker version. And actually `kubeadm` showed
a warning that version is higher than latest validated version, which is `1.12`
for current moment.

I have not seen any issues with latest version of Docker, and because I already
had it installed I kept the latest version.

To install latest Docker just follow the manual on how to [install
Docker on Ubuntu](https://docs.docker.com/engine/installation/linux/ubuntu/#install-using-the-repository).

### kubeadm

You probably want to use [flannel](https://github.com/coreos/flannel) as a pod
network add-on. This add-on works out of box. Manual above suggest you to use
`--pod-network-cidr=10.244.0.0/16` with `kubeadm init`, so don't forget it

```
sudo kubeadm init --pod-network-cidr=10.244.0.0/16
```

Because I am creating one node Kubernetes deployment I needed to use

```
kubectl taint nodes --all node-role.kubernetes.io/master-
```

Which allows me to schedule pods on this node.

Also perform the steps to give `kubectl` access to the kubernetes API

```
sudo cp /etc/kubernetes/admin.conf $HOME/
sudo chown $(id -u):$(id -g) $HOME/admin.conf
export KUBECONFIG=$HOME/admin.conf
```

You can also just copy `admin.conf` under `~/.kube/config`, as this is a default
place where `kubectl` is looking for config.

### Network

This is a place, when things start to be more complicated. Kubernetes is built
with extensibility in mind, this is why there are always a lot of options.

If you are not sure [which network addon](https://kubernetes.io/docs/concepts/cluster-administration/networking/)
to use, use [flannel](https://github.com/coreos/flannel). Reason is quoted

> Flannel is a very simple overlay network that satisfies the Kubernetes requirements.
> Many people have reported success with Flannel and Kubernetes.

To set it up use

```
$ kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel-rbac.yml
$ kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
```

After that you should see that current node has a ready status

```
$ kubectl get nodes
NAME           STATUS    AGE       VERSION
outcoldbuntu   Ready     1h        v1.6.5
```

## kubectl config

If you want to use multiple clusters from one environment you can manually merge
multiple configuration files into one. For example on my Mac I already used
configuration from `minikube`, which has been saved under `~/.kube/config`. But to
be able to connect to just created cluster on my Ubuntu box I copied `admin.conf`
file to my local box and merged all the values from `admin.conf` to `~/.kube/config`.
After that I see multiple contexts defined

```
$ kubectl config get-contexts
CURRENT   NAME                          CLUSTER      AUTHINFO           NAMESPACE
          kubernetes-admin@kubernetes   kubernetes   kubernetes-admin   
*         minikube                      minikube     minikube
```

And I can switch between them

```
$ kubectl config use-context kubernetes-admin@kubernetes
Switched to context "kubernetes-admin@kubernetes".
```

## Kubernetes Dashboard

To see metrics on Dashboard you need to install [Heapster](https://github.com/kubernetes/heapster).

The easiest way to start with Heapster and Dashboard is to use official [add-on configurations](https://github.com/kubernetes/kops/tree/master/addons)

First create standalone Heapster deployment

```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/kops/master/addons/monitoring-standalone/v1.6.0.yaml
```

After that create dashboard deployment

```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/kops/master/addons/kubernetes-dashboard/v1.6.0.yaml
```

You can get access to the dashboard now

```
$ kubectl proxy
```

And open http://localhost:8001/ui
