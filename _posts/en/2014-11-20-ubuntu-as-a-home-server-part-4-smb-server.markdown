---
layout: post
title: "Ubuntu as a home server. Part 4. Samba server."
date: 2014-11-20 00:00:00 -00:08:00
categories: en
tags: [Ubuntu, Samba, Windows, Linux]
---

1. [Dynamic DNS]({{ site.url }}/en/archive/2014/10/14/ubuntu-as-a-home-server-part-1-dynamic-dns/).
1. [OpenVPN]({{ site.url }}/en/archive/2014/10/21/ubuntu-as-a-home-server-part-2-openvpn/).
1. [AFP Server (for OS X)]({{ site.url }}/en/archive/2014/11/09/ubuntu-as-home-server-part-3-afp-server/).
1. [SMB server (for Windows and Linux)]({{ site.url }}/en/archive/2014/11/20/ubuntu-as-a-home-server-part-4-smb-server/).
1. Reliability (Backups).
1. Other tricks.

In Part 3 we have set up AFP file share for Apple devices, in this part we will configure file share for Windows devices (also this share is compatible with Linux as well). To do that we will use [Samba server](http://en.wikipedia.org/wiki/Samba_(software).

## Samba server

You can configure samba server using UI or using samba configuration file. I found that using configuration file is much easier to do.

First of all you need to install samba if it is not installed yet

```bash
$ sudo apt-get update
$ sudo apt-get install samba
```

Now we are ready to configure it. 

```bash
$ sudo vim /etc/samba/smb.conf
```

I kept default settings under section `global` and commented all other sections (by default only `printers` and `print$` should be uncommented). I don't need to share any printers, so I did not need this section. If you want to share printer, you probably want to keep it.

This is configuration which I've added

```yaml
[user1]
    comment = user1
    path = /home/user1
    browsable = yes
    hide dot files = yes
    read only = no
    create mask = 0775
    directory mask = 0775
    valid users = user1 user2

[user2]
    comment = user2
    path = /home/user2
    browsable = yes
    hide dot files = yes
    read only = no
    create mask = 0775
    directory mask = 0775
    valid users = user1 user2
```

In my case I have only two users on my Ubuntu server and I want to allow each user to see other users home directories in read-only mode (the same way as I configured AFP server in previous part). Let's take a look on most interesting settings

* `browsable = yes` - we want to show this folder when user goes on `\\myserver`, so it will be listed. In other case you will need to know that this folder exists and you will need directly go to the `\\myserver\user1`.
* `hide dot files = yes` - show dot files as hidden files in Windows.
* `read only = no` - allow to write to this share. This actually means only that if user has permission to write to this folder on server - this user can write to this folder using this network share. This means that because `user1` has permissions to write to folder `/home/user1` - he can do that, but in my case `user2` has only read permissions to folder `/home/user1` which means that he can only read it. For example this is listing of `/home` on my server

```bash
$ ls -l /home
drwxrwxr-x  9 user1 user1 4096 Nov 17 20:52 user1/
drwxrwxr-x 40 user2 user2 4096 Nov 20 22:54 user2/
```

As you can see both folders `user1` and `user2` has permissions `r-x` for others. If you want to do the same and for some reason you have different permissions you can do

```bash
$ sudo chmod -R o+rx /home/
```

* `create mask = 0775` and `directory mask = 0775` - we want to be sure that when new directory or file will be created - other user will have read-only access to it.
* `valid users = user1 user2` - only these two users will have access to this folder.

### Auto mount Samba share in Linux machines

For one of my other Linux machines I wanted to configure auto mounting for shared folder from my server. For this will be better to use NFS shares, but as I said in previous part - it is much harder to configure NFS shares, so I keep using Samba for this.

For example if you have home folder `/home/user1` configured as in my example above and you want to auto mount only one folder `/home/user1/shared` into `/home/user1/shared_from_server` on other Linux machine (assuming that on this Linux server you also have user `user1`) at first you need to create this folder on client Linux machine

```bash
$ mkdir /home/user1/shared_from_server
```

After that you will need to keep credentials for this share somewhere in secret on client machine, I placed it under `/etc/samba`

```bash
$ sudo vim /etc/samba/user
```

You need to put `username` and `password` in this file

```yaml
username=user1
password=user1_p@ssword
```

Small protection, make this file read-only only for owner (which should be `root`, as we created this file with `sudo` command)

```bash
$ sudo chmod 0400 /etc/samba/user
```

After that modify `/etc/fstab`

```bash
$ sudo vim /etc/fstab
```

To include next line

```yaml
//myserver/user1/shared /home/user1/shared_from_server cifs credentials=/etc/samba/user,noexec 0 0
```

Now you can try to reboot to test that share will be auto mounted.

### Links

* [Ubuntu - SambaServerGuide](https://help.ubuntu.com/community/Samba/SambaServerGuide)