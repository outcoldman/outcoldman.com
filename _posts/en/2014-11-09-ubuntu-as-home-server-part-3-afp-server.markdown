---
layout: post
title: "Ubuntu as a home server. Part 3. AFP Server."
date: 2014-11-09 00:00:00 -00:08:00
categories: en
tags: [Ubuntu, AFP, TimeMachine, OS X, netatalk]
---

1. [Dynamic DNS]({{ site.url }}/en/archive/2014/10/14/ubuntu-as-a-home-server-part-1-dynamic-dns/).
1. [OpenVPN]({{ site.url }}/en/archive/2014/10/21/ubuntu-as-a-home-server-part-2-openvpn/).
1. [AFP Server (for OS X)]({{ site.url }}/en/archive/2014/11/09/ubuntu-as-home-server-part-3-afp-server/).
1. [SMB server (for Windows and Linux)]({{ site.url }}/en/archive/2014/11/20/ubuntu-as-home-server-part-4-smb-server/).
1. Reliability (Backups).
1. Other tricks.

In first two blogposts we made it possible to get remote access to our server from outside world. The next steps will be about making this home server usable. 

First of all we can configure server as a file share server. As far as I know there are three different types of network protocols:

* [NFS](http://en.wikipedia.org/wiki/Network_File_System) - Network File System - this one requires a lot of configurations to setup it right. It worth investment if you have [LDAP](http://en.wikipedia.org/wiki/Lightweight_Directory_Access_Protocol) in your network and you want to statically mount this share to your machines. Because I don't have LDAP in my home network - I did not consider to use it. 
* [AFP](http://en.wikipedia.org/wiki/Apple_Filing_Protocol) - Apple Filing Protocol - as you can guess from the name - good to have it for Apple devices. TimeMachine works over AFP protocol. 
* [SMB](http://en.wikipedia.org/wiki/Server_Message_Block) - Server Message Block - supported by Windows / OS X. I use it only to share folders with Windows machines.

## AFP Server

There are two benefits of having AFP server in network: a) have access from OS X machines to shared folders b) have a TimeMachine backup server.

You can setup `AFP` server on Linux using [Netatalk](http://netatalk.sourceforge.net). The last available version is `3.1.6`, but the last version available on Ubuntu's `apt-get` is `2.2.2`. There are a lot of differences between versions `2` and `3`, but the main one is that in version `3` you can store Apple metadata and resource forks in [extended attributes](http://en.wikipedia.org/wiki/Extended_file_attributes) of the filesystem (see [Upgrading from Netatalk 2](http://netatalk.sourceforge.net/3.0/htmldocs/upgrade.html)). This means if you will use version 2 you will find that every time you try to access network share from OS X you will see a lot of `.AppleDouble` [folders](http://en.wikipedia.org/wiki/AppleSingle_and_AppleDouble_formats). This was really annoying for me, especially because one of the folders which I share is a DropBox folder which is synchronizing all the `.AppleDouble` folders with cloud.

So I decided to find a way to install latest version `3.1.6`. It is possible by installing it from sources. 

At first I installed git

```bash
sudo apt-get install git 
```

Cloned latest `netatalk` sources to have easy access to updates in future (you can just [download](http://sourceforge.net/projects/netatalk/files/) it)

```bash
# go to the home, create new folder dev where will clone netatalk sources
$ cd ~
$ mkdir dev
$ cd dev
# clone netatalk sources from http://sourceforge.net/p/netatalk/code/
$ git clone git://git.code.sf.net/p/netatalk/code netatalk
# checkout version 3-1-6 (netatalk-3-1-6 is a tag in git repository)
$ cd netatalk
$ git checkout netatalk-3-1-6
```

After that follow one of [these How To topics](http://netatalk.sourceforge.net/wiki/index.php/Category:Howtos) (this one in my case [Install Netatalk 3.1.6 on Ubuntu 14.04 Trusty](http://netatalk.sourceforge.net/wiki/index.php/Install_Netatalk_3.1.6_on_Ubuntu_14.04_Trusty)) I did

```bash
$ sudo apt-get install autoconf \
  libtool \
  automake \
  build-essential \
  libssl-dev \
  libgcrypt11-dev \
  libkrb5-dev \
  libpam0g-dev \
  libwrap0-dev \
  libdb-dev \
  libmysqlclient-dev \
  libavahi-client-dev \
  libacl1-dev \
  libldap2-dev \
  libcrack2-dev \
  systemtap-sdt-dev \
  libdbus-1-dev \
  libdbus-glib-1-dev \
  libglib2.0-dev \
  tracker \
  libtracker-sparql-0.16-dev \
  libtracker-miner-0.16-dev
$ ./configure \
  --with-init-style=debian-sysv \
  --without-libevent \
  --without-tdb \
  --with-cracklib \
  --enable-krbV-uam \
  --with-pam-confdir=/etc/pam.d \
  --with-dbus-sysconf-dir=/etc/dbus-1/system.d \
  --with-tracker-pkgconfig-version=0.16
$ make
$ sudo make install
```

Verify that it works (also this command tells you where all the configuration files are located)

```
$ afpd -V
```

> Manual says also to verify that your system supports extended attributes. If you have ext4 and you are on Ubuntu 14.04 - you probably don't need to do anything, it is enabled by default, but if you want to be sure you can try to use `setfattr` and `getfattr` to verify that you can set and read user extended attributes.

To modify settings you can use 

```bash
$ sudo vim /usr/local/etc/afp.conf
```

In my case I have next settings (assuming that I have two users on my server `user1` and `user2`)

```bash
# Share user1 folder with writable permission for user1
# and give read-only permissions for user2
[user1]
    path = /home/user1
    rolist = user2

# The same for user2
[user2]
    path = /home/user2
    rolist = user1

# Share TimeMachine folder, limit it to ~1TB, and 
# give access only to user1 and user2
[TimeMachine]
    path = /mnt/BACKUP/TimeMachine
    time machine = yes
    vol size limit = 1000000
    valid users = user1 user2
```

You can use more general way of sharing home folders 

```bash
[Homes]
    basedir regex = /home
```

But I wanted a little bit more control on shares. First of all I wanted to give read-only accesses to user1 for user2 share and otherwise. Also I wanted to see folders for both users when go to this server. And also I have system accounts with their home folders, which I don't want to share, so it was easy for me to configure everything manually. Also I know that I'm not going to add new users in near future, so I did not need automation on this level.

Don't forget to verify that all users have access to the TimeMachine folder, In my case I specified `users` ownership for the TimeMachine folder, gave this group access to do anything in this folder, and added both users to this group

```
# Change ownership of TimeMachine folder to users group
$ sudo chown -R root:users /mnt/BACKUP/TimeMachine
# Add read-write access to the users group
$ sudo chmod -R g+rwx /mnt/BACKUP/TimeMachine
# Add user1 and user2 to users group
$ sudo usermod -a -G users user1
$ sudo usermod -a -G users user2
```

Restart `netatalk` to apply new configuration

```bash
$ sudo service avahi-daemon start
$ sudo service netatalk start
```

After that you should be able to see this server in Finder under `Shared` category. Also you should be able see this server as a TimeMachine server.

### Auto mount AFP share on OS X

If you want auto mount AFP share on boot - you can do it very easy for user. Just open `System Settings`, go to the `Users & Groups`, select user on left side, select `Login Items` tab on right side and just drag and drop AFP shared folder in this list.

### Links

* [Ubuntu Community Help Wiki - Setting Up NFS How To](https://help.ubuntu.com/community/SettingUpNFSHowTo).
* [Install Netatalk 3.1.6 on Ubuntu 14.04 Trusty](http://netatalk.sourceforge.net/wiki/index.php/Install_Netatalk_3.1.6_on_Ubuntu_14.04_Trusty).
