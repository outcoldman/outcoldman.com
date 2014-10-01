---
layout: post
title: "How to learn Linux."
date: 2014-09-30 00:00:00 -00:08:00
categories: en
tags: [Linux, Bash, Ubuntu]
---

In the last year folks asked me several times about Linux, about how to learn it after Windows. I think one of the reasons why I got this question was that one year ago I was 100% Windows user with very basic knowledge of Linux, and at current moment I'm a very comfortable with Linux. Just to make it clear I *played* with Linux in University, did not do anything solid, like development on it, I think I used it only because I liked it how it looked differently. 

Year ago I had a reason to be a 100% Windows user. At least I thought that I had. I was on 100% satisfied with Windows. Now I know that I was wrong. Obviously it is better to know both system. I'm not talking about [personal preferences]({{ site.url }}/en/archive/2013/10/20/windows-vs-ubuntu-vs-mac-os-x/), I made my choice and now I am a OS X user with Linux server at home and 3 Windows Virtual Machines. 

## So where to start?

I started from [ubuntu.com](http://www.ubuntu.com) and [VMware Player](https://www.vmware.com). I mean install Ubuntu Desktop edition on Virtual Machine. You can use it in Full Screen mode even with more than one monitor (in my case I had two monitors) and use it in the way like it is main operation system. 

First of all you need to find out how to launch *Terminal*. It is easy, I believe that you can find how to do that. After learn `apt-get` tool, it is *Advanced Packaging Tool* (one of the reasons why people love Linux, because of package managers). Better to learn several most useful commands `update`, `distr-upgrade`, `install` and `purge`. If names of these commands do not tell you anything do `man apt-get`, if you think that you understand what these commands do - still read the manual. One thing, `man` opens documentation by default using `less` (to exit press `q`), read about `less` with `man less`.

Some commands require *root* access, like `apt-get install`. To run these commands under *root* use `sudo` (don't forget to `man sudo`).

With `apt-get` and *Ubuntu Software Center* (Desktop application) you can install some of application which will cover most of your everyday needs. But not all of them can be found on default Ubuntu repository. Sometimes you need to add other repositories with `add-apt-repository` (don't forget about `man add-apt-repository`), usually you can find these repositories when you Google for specific application.

And when you cannot find native application for Linux - this is where [Wine](https://www.winehq.org) can help you. Personally I would recommend using [PlayOnLinux](https://www.playonlinux.com/en/) (it helps not only to play games) which will help you to manage applications in their own Wine containers. Install PlayOnLinux with `sudo apt-get install playonlinux`. Don't try to install latest versions of Windows applications, better use Wine [AppDB](https://appdb.winehq.org) site to find which version has better compatibility with Wine. 

Ok, so this is what I had on my list:

* Skype - `sudo apt-get install skype`. If this command cannot find skype - you need to add *Canonical Partners* repository (you can do it in *Ubuntu Software Center* settings). Also use community docs: [Skype](https://help.ubuntu.com/community/Skype).
* Chrome - [download](https://www.google.com/chrome/browser/?platform=linux). One important thing, Ubuntu is based on Debian. So everytime when you need to choose between different packages - try to find Ubuntu, and if you don't see it, use Debian. You can read about [Basics of the Debian package management system](https://www.debian.org/doc/manuals/debian-faq/ch-pkg_basics.en.html).
* DropBox - [download client for Linux](https://db.tt/pxFmAN6O) (Referral link). Best cloud storage and only one (good one) which has Linux client.
* Sublime Text - [download](http://www.sublimetext.com/3). Best editor.
* Evernote - you can install it with PlayOnLinux, see [compatibility list](https://appdb.winehq.org/objectManager.php?sClass=application&iId=2566). Alternative way is to use Chrome Apps. 
* git - `sudo apt-get install git`. Don't know what *git* is? [Git Pro book](http://git-scm.com/book).
* [oh my zsh](http://ohmyz.sh). Easy to install, easy to configure. Helps a lot to spend your life in Terminal.

After that you will have minimal installation which will allow you to browse the Internet.

## What to learn next?

I would highly recommend to choose some new developer platform, which you have not tried before and start learning it on this new environment. It can be anything: [nodejs](http://nodejs.org), [mongodb](http://www.mongodb.com), Python (Django), Java or Xamarin. This will help you to spend more time in Linux. 

At the same time start learning Terminal, Bash and all available tools. If you are crazy like me: go and read [Linux in Nutshell](http://shop.oreilly.com/product/9780596154493.do), just go thought all commands to understand what is available for you. Also these 3 articles helped me to ramp up

* [Switching From Windows to Nix or a Newbie to Linux - 20 Useful Commands for Linux Newbies](http://www.tecmint.com/useful-linux-commands-for-newbies/).
* [20 Advanced Commands for Middle Level Linux Users](http://www.tecmint.com/20-advanced-commands-for-middle-level-linux-users/).
* [20 Advanced Commands for Linux Experts](http://www.tecmint.com/20-advanced-commands-for-linux-experts/).

Learn `vim` (editor). It is hard to find an exit from `vim`. Just launch `vimtutor` to get into tutorial to learn some basics about `vim`. After that [Vim: revisited](http://mislav.uniqpath.com/2011/12/vim-revisited/). A lot of folks use `vim` as a main editor. I am not advanced `vim` user, mostly I use it when I need to edit some configuration files.

Read [Filesystem Hierarchy Standard](http://www.samba.org/~cyeoh/pub/fhs-2.3.html). It is important to understand your Filesystem hierarchy to know where you can find what. Also read about permissions and how to set them up `man chmod`. It is unexpected for Windows users that file need to have special permission to be executable (`chmod +x executable_file`).

Use these three websites when you need help

* [Official Ubuntu Documentation](https://help.ubuntu.com).
* [AskUbuntu](http://askubuntu.com).
* [Ubuntu Forums](http://ubuntuforums.org).

## Multiple Linux Machines

Ok, so what if you decided that now you want to have multiple Linux machines? Maybe use some Linux servers in cloud, like [Digital Ocean](https://www.digitalocean.com/?refcode=2bf7395aa5fd) (referral link)?

If you want to get access to remote machine only in Terminal: learn about OpenSSH, ssh and scp. Simplify your life, forget about passwords, read about [Key-Based SSH logins](https://help.ubuntu.com/community/SSH/OpenSSH/Keys), GitHub has very simple instruction how to [generate SSH key](https://help.github.com/articles/generating-ssh-keys). Do `man ssh` and `man scp`. First tool allows you to get terminal access to remote machine, second tool allows you to do copy to/from remote machine.

Do you want to see Graphical interface, like Remote Desktop on Windows? Read about [Virtual Network Computing (VNC)](http://en.wikipedia.org/wiki/Virtual_Network_Computing). You can [install VNC](https://help.ubuntu.com/community/VNC/Servers) server on Ubuntu (*vino* is installed by default, you just need to enable it). One important thing, when you are connected to remote machine with VNC - remote machine shows everything what you are doing on its Monitor (if it is turned on and it has a monitor). This is why people learn `vim` and only use `ssh`.

Hope that this will help you to learn some basics about Linux.