---
layout: post
title: "Learn Linux."
date: 2014-09-30 00:00:00 -00:08:00
categories: en
tags: [Linux, Bash, Ubuntu]
draft: true
---

In the last year I got a lot of questions around Linux, most of them were about how to start learning it. I think that one of the reasons I got these questions was that one year ago I was 100% Windows user with very basic knowledge of Linux, and now I'm a very comfortable with Linux. Just to be clear I played a lot with Linux in University, but mostly because I tried to be cool. Yeah in Russia in those days being a Linux user was cool, and Windows was installed everywhere. 

Year ago I had a reason to be a 100% Windows user. At least I thought that I had. I was on 100% satisfied with Windows. Now I know that I was wrong. Obviously it is better to know them both. I'm not talking about [personal preferences](http://outcoldman.com/en/archive/2013/10/20/windows-vs-ubuntu-vs-mac-os-x/), I made my choice and now I am a OS X user with Linux server at home and 3 Windows Virtual Machines. 

## So where to start?

I started from [ubuntu.com](http://www.ubuntu.com) and [VMware Player](https://www.vmware.com) (the one which is free, not the Plus one). You can easily use it in Full Screen mode even with more than one monitor (in my case I had two 24 inch monitors) and use it without actually knowing if this is a virtual environment or not. 

First of all you need to find out how to launch *Terminal*. It is easy, I believe that you can find how to do that. Learn first tool `apt-get`, this is Advanced Packaging Tool (one of the reasons why people love Linux). You need to know several most useful commands `update`, `distr-upgrade`, `install` and `purge`. If names of these commands do not tell you anything do `man apt-get`, if you think that you understand what these commands are doing - still read the manual. One thing, `man` opens documentation by default using `less` (to exit press `q`), read about `less` with `man less`.

Some commands require *root* access, like `apt-get install`. To run command these commands under *root* use `sudo` (don't forget to `man sudo`).

Using `apt-get` and *Ubuntu Software Center* you can install some of application which will cover most of your everyday needs. But not all of them can be found on default Ubuntu repository. Sometimes you need to add other repositories with `add-apt-repository` (don't forget about `man add-apt-repository`).

And when you cannot find native application for Linux - this is where [Wine](https://www.winehq.org) can help you. Personally I would recommend using [PlayOnLinux](https://www.playonlinux.com/en/) (it is not only about playing games) which will help you to manage applications in their own Wine containers, install it with `sudo apt-get install playonlinux`. Don't try to install latest versions of Windows application, better use Wine [AppDB](https://appdb.winehq.org) site to find best list of best matching of app version with Wine version. 

Ok, so this is what I had on my list:

* Skype - `sudo apt-get install skype`. If this command cannot find skype - you need to add Canonical Partners repository (you can do it in *Ubuntu Software Center* settings). Also use community docs: [Skype](https://help.ubuntu.com/community/Skype).
* Chrome (Native support) - [download](https://www.google.com/chrome/browser/?platform=linux). One important thing, Ubuntu is based on Debian. So everytime when you need to choose between different packages - try to find Ubuntu, and if you don't see it, use Debian. You can read about [Basics of the Debian package management system](https://www.debian.org/doc/manuals/debian-faq/ch-pkg_basics.en.html).
* DropBox - [download client for Linux](https://db.tt/pxFmAN6O)(Referral link). Best cloud storage and only one (good one) which has Linux client.
* Sublime Text (Native support) - [download](http://www.sublimetext.com/3). Best editor.
* Evernote - you can install it with PlayOnLinux, see [compatibility list](https://appdb.winehq.org/objectManager.php?sClass=application&iId=2566). Alternative is to use Chrome Apps. 
* git - `sudo apt-get install git`. Don't know what git is? [Git Pro book](http://git-scm.com/book).
* [oh my zsh](http://ohmyz.sh). Easy to install, easy to configure. Helps a lot to spend you life in Terminal.

I would recommend

## What to learn?

I would highly recommend to choose some new platform which you have not tried before and start learning it in this new environment. It can be anything: [nodejs](http://nodejs.org), [mongodb](http://www.mongodb.com), Python (Django), Java or Xamarin. This will help you to spend more time in Linux. 

At the same time start learning Terminal, Bash and all available tools. If you are crazy like me go and read [Linux in Nutshell](http://shop.oreilly.com/product/9780596154493.do), just go thought all commands just to understand what is available. Also these 3 articles helped me to ramp up

* [Switching From Windows to Nix or a Newbie to Linux - 20 Useful Commands for Linux Newbies](http://www.tecmint.com/useful-linux-commands-for-newbies/).
* [20 Advanced Commands for Middle Level Linux Users](http://www.tecmint.com/20-advanced-commands-for-middle-level-linux-users/).
* [20 Advanced Commands for Linux Experts](http://www.tecmint.com/20-advanced-commands-for-linux-experts/).

Learn `vim` (editor). It is hard to find an exit from `vim`. Just launch `vimtutor` to get into tutorial to learn some basics about `vim`. After that [Vim: revisited](http://mislav.uniqpath.com/2011/12/vim-revisited/). A lot of folks use `vim` as a main editor. I don't know it on this level, mostly I use it when I need to edit some configuration files.

Read [Filesystem Hierarchy Standard](http://www.samba.org/~cyeoh/pub/fhs-2.3.html). It is important to understand your Filesystem hierarchy to know where you can find what.

Use these three websites

* [Official Ubuntu Documentation](https://help.ubuntu.com).
* [AskUbuntu](http://askubuntu.com).
* [Ubuntu Forums](http://ubuntuforums.org).

## Multiple Linux Machines

Ok, so what if you decided that now you want to have multiple Linux machines? Maybe use some Linux servers in cloud, like [Digital Ocean](https://www.digitalocean.com/?refcode=2bf7395aa5fd) (referral link)?

If you want to get access to remote machine only in Terminal: learn about OpenSSH, ssh and scp. Simplify your life, forget about passwords, read about [Key-Based SSH logins](https://help.ubuntu.com/community/SSH/OpenSSH/Keys), GitHub has very simple instruction how to [generate SSH key](https://help.github.com/articles/generating-ssh-keys). Do `man ssh` and `man scp`. First tool allows you to get terminal access to remote machine, second tool allows you to do copy to/from remote machine.

Do you want to see Graphical interface, like Remote Desktop on Windows? Read about [Virtual Network Computing (VNC)](http://en.wikipedia.org/wiki/Virtual_Network_Computing). You can [install VNC](https://help.ubuntu.com/community/VNC/Servers) server on Ubuntu (*vino* is installed by default, you just need to enable it). One important thing, when you are connected to remote machine with VNC - remote machine shows everything what you are doing on its Monitor (if it is turned on and it has a monitor).