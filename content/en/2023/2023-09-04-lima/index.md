---
date: "2023-09-04"
tags:
- docker
- kubernetes
- openshift
- vm
- lima
- linux
title: Lima - the best replacement for Docker Desktop on macOS
slug: lima
draft: true
---

I have heard about [Lima](https://github.com/lima-vm/lima) for a while now. But I wished I actually gave it a try earlier.
It does solve so many problems that I had with the Docker for Mac. 

This blog post is focused specifically on running lima on macOS 13+ (Ventura and Sonoma at that time) on Apple Silicon.
I don't know how well it would work on Intel-based Macs, but I assume it should work just fine.

## Why Lima? And not just keep using Docker for Mac?

I have been using Docker for at least 10 years now. My memory is vague, not sure if Docker for Mac existed since then,
or there were different ways to run it on Mac. Probably it used to be a `docker-machine`. It served me well for a long time. 
But Docker is not mainstream now, and it is not the only way to run containers. I have been using Kubernetes for a while now too.
More than that, I actually have my own company, where I develop for Kubernetes, OpenShift and Docker. A lot of times,
I run them all at the same time on my macOS. And there are issues.

Docker for Mac is built by developers for developers. So, if there is something wrong, it is not going to tell you about it.
You, as a developer, need to figure it out. And it is not always easy. One example is Kubernets on Docker for Mac. If the port
`6443` is taken, it will not tell you about it. It will just not start. And you will need to figure out what is wrong.
And when you install RedHat CodeReady Containers (crc), it will take that port. Even, if `crc` is not running, it will always
take that port. So my solution for a while was to just kill `crc` process, and then start Docker for Mac with Kubernetes.

I wish there was an easy way to just reassign the `6443` port to some other port. (Lima can solve that).

And because I develop my software for container environments, I need easy access to them, I need to ssh to the VM, and
being able to change things. Try various configurations. Docker hides it very well.

Docker for Mac is great, but in reality I don't need anything more than a `docker-machine` with a Linux VM. I have never
touched the UI of Docker for Mac. It is so much easier to just use `docker` CLI. Docker for Mac is basically uses 
the `Virtualization.framework` for my case, and just have a nice UI on top of it. 

## Lima installation

Installation is very simple. You can use brew to install it.

```bash
brew install lima
```

And then you can just start a new VM, similar to Docker for Mac

```bash
limactl start docker-rootful
```

That will run template defined with [docker-rootful.yaml](https://github.com/lima-vm/lima/blob/master/examples/docker-rootful.yaml).
But before you try it, let's configure it a little bit.

## Configuration

In my case, I want to run Kubernetes and Docker VMs separately. Sometimes I use only Docker, sometimes I use them both.
And I have multiple macOS computers that have different numbers of CPUs and memory. So, I want to be able to configure
each of them separately. macOS 13+ provides a very nice Virtualization framework that works great. I even tried to build
my own lima-clone on it, just because I was lazy to give `lima` a try.

Lima is built to promote `nerdctl` and `containerd` as a replacement for `docker` and `dockerd`. I am not ready to switch
to `nerdctl`, just because it is not something I need. As I mentioned, I don't just build containers, I actually develop
software for them. 

So, first thing, I have configured my own `default.yaml` for new VMs. Placed it in `~/.lima/_config/default.yaml`.
I have used [github.com/lima-vm/lima/examples/default.yaml](https://github.com/lima-vm/lima/blob/master/examples/default.yaml)
as a source. And have changed a few things:

- Use `Virtualization.framework` (`vz`) as `vmType`
- Configured `cpus` and `memory` to use 8 CPUs and 16GiB of memory for this specific macOS (on my MBP 16" M2 Max with 96GB of memory),
or MBA M2 with 24GB I have changed it to 4 CPUs and 8GiB of memory.
- Configured `disk` to use 500GiB of disk space. 
- Enabled `rosetta`, so I can run and build `x86_64` images.
- Kept default lima `tmp` mount, not sure if it is needed, but I have kept it.
- Configured the images from the default.yaml
- Disabled `containerd`, so I can enable them only in VMs where I need it.

```yaml
vmType: vz
cpus: 8
memory: 16GiB
disk: 500GiB

rosetta:
  enabled: true
  binfmt: true

mounts:
  - location: "/tmp/lima"
    writable: true

images:
# Try to use release-yyyyMMdd image if available. Note that release-yyyyMMdd will be removed after several months.
- location: "https://cloud-images.ubuntu.com/releases/23.04/release-20230810/ubuntu-23.04-server-cloudimg-amd64.img"
  arch: "x86_64"
  digest: "sha256:5ad255d32a30a2cda9f0df19f0a6ce8d6f3c81b63845086a4cb5c43cf97fcb92"
- location: "https://cloud-images.ubuntu.com/releases/23.04/release-20230810/ubuntu-23.04-server-cloudimg-arm64.img"
  arch: "aarch64"
  digest: "sha256:af62ca6ba307388f7e0a8ad1c46103e6aea0130a09122e818df8d711637bf998"
# Fallback to the latest release image.
# Hint: run `limactl prune` to invalidate the cache
- location: "https://cloud-images.ubuntu.com/releases/23.04/release/ubuntu-23.04-server-cloudimg-amd64.img"
  arch: "x86_64"
- location: "https://cloud-images.ubuntu.com/releases/23.04/release/ubuntu-23.04-server-cloudimg-arm64.img"
  arch: "aarch64"

containerd:
  system: false
  user: false
```

## Docker VM

Secondarily I have created a template of the Docker VM for myself. I used [docker-rootful.yaml](https://github.com/lima-vm/lima/blob/master/examples/docker-rootful.yaml)
as an example, with some modifications. 

- I keep my sources in `~/src`. Actually in `~/Sources`, but I have a symbolic link from `~/src` to `~/Sources`, and in 
CLI I use `~/src`. So I have mounted `/Users/outcoldman/Sources/` into the VM as `/Users/outcoldman/src/`. In a lot of cases
I build my containers with mounting the source folder, and not using `COPY` command. I also cache the `pkg` folder for go
runtime, that helps me to speed up the builds.
- 

```yaml
mounts:
  - location: "/Users/outcoldman/Sources/"
    mountPoint: "/Users/outcoldman/src/"
    writable: true
provision:
  - mode: system
    script: |
      #!/bin/sh
      sed -i 's/host.lima.internal.*/host.lima.internal host.docker.internal default-route-openshift-image-registry.apps-crc.testing/' /etc/hosts
  - mode: system
    script: |
      #!/bin/bash
      set -eux -o pipefail
      timedatectl set-ntp no
      apt update
      apt install -y ntp
      command -v docker >/dev/null 2>&1 && exit 0
      if [ ! -e /etc/systemd/system/docker.socket.d/override.conf ]; then
        mkdir -p /etc/systemd/system/docker.socket.d
        # Alternatively we could just add the user to the "docker" group, but that requires restarting the user session
        cat <<-EOF >/etc/systemd/system/docker.socket.d/override.conf
        [Socket]
        SocketUser=${LIMA_CIDATA_USER}
      EOF
      fi
      mkdir -p /etc/docker
      echo '{
        "builder": {"gc": {"defaultKeepStorage": "20GB", "enabled": true} },
        "experimental": true,
        "insecure-registries": [
          "default-route-openshift-image-registry.apps-crc.testing"
        ],
        "log-driver": "json-file",
        "log-opts": {
          "max-size": "100m",
          "max-file": "3"
        }
      }' >/etc/docker/daemon.json
      export DEBIAN_FRONTEND=noninteractive
      curl -fsSL https://get.docker.com | sh
probes:
  - script: |
      #!/bin/bash
      set -eux -o pipefail
      if ! timeout 30s bash -c "until command -v docker >/dev/null 2>&1; do sleep 3; done"; then
        echo >&2 "docker is not installed yet"
        exit 1
      fi
      if ! timeout 30s bash -c "until pgrep dockerd; do sleep 3; done"; then
        echo >&2 "dockerd is not running"
        exit 1
      fi
    hint: See "/var/log/cloud-init-output.log". in the guest
hostResolver:
  hosts:
    host.docker.internal: host.lima.internal
    default-route-openshift-image-registry.apps-crc.testing: host.lima.internal
portForwards:
  - guestSocket: "/var/run/docker.sock"
    hostSocket: "{{.Dir}}/sock/docker.sock"
message: |
  To run `docker` on the host (assumes docker-cli is installed), run the following commands:
  ------
  docker context create lima-{{.Name}} --docker "host=unix://{{.Dir}}/sock/docker.sock"
  docker context use lima-{{.Name}}
  docker run hello-world
  ------
```