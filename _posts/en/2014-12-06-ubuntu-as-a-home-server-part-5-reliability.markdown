---
layout: post
title: "Ubuntu as a home server. Part 5. Reliability."
date: 2014-12-06 00:00:00 -00:08:00
categories: en
tags: [Ubuntu, RAID, CrashPlan, Dropbox, OneDrive]
---

1. [Dynamic DNS]({{ site.url }}/en/archive/2014/10/14/ubuntu-as-a-home-server-part-1-dynamic-dns/).
1. [OpenVPN]({{ site.url }}/en/archive/2014/10/21/ubuntu-as-a-home-server-part-2-openvpn/).
1. [AFP Server (for OS X)]({{ site.url }}/en/archive/2014/11/09/ubuntu-as-home-server-part-3-afp-server/).
1. [SMB server (for Windows and Linux)]({{ site.url }}/en/archive/2014/11/20/ubuntu-as-a-home-server-part-4-smb-server/).
1. [Reliability (Backups)]({{ site.url }}/en/archive/2014/12/06/ubuntu-as-a-home-server-part-5-reliability/).

## Reliability (Backups)

You probably know that it is important to backup data from your computers. This is how I backup my data

* On Ubuntu server I created 2Gb RAID-0 volume using 2 of my old Hard Drives. 
* As you know I used `netatalk` (see [AFP Server (for OS X)]({{ site.url }}/en/archive/2014/11/09/ubuntu-as-home-server-part-3-afp-server/)) and have TimeMachine server on Ubuntu which points on my RAID-0 volume.
* All my Mac computers create backups on my Ubuntu server using TimeMachine.
* My Ubuntu server also backup itself to this RAID-0 using Back In Time. It backups mostly everything excluding `/home` folder.
* On Ubuntu server I have CrashPlan installed, which backups small amount of server settings, `/home` folder and `TimeMachine` backups.

You [already know]({{ site.url }}/en/archive/2014/11/09/ubuntu-as-home-server-part-3-afp-server/) how to configure TimeServer on Ubuntu, so let's talk about RAID, Back in Time and CrashPlan.

### RAID

In my case I have two [RAID](http://en.wikipedia.org/wiki/RAID) volumes, both of them RAID-0

* first is a home directory. It is cheaper to buy 2x3TB hard drives than one 6Tb drive and I wanted to get just one partition, so RAID-0 is a way to go. 
* second is a backup partition. I have few old 1Tb drives which I wanted to use for Backups. Again I wanted to have one partition, so I built RAID-0 from them.

RAID-0 does not give you better [redundancy](http://en.wikipedia.org/wiki/Redundancy_(engineering)). It just simplifies your life by combining multiple disks in one. When one of them fails - you loose entire RAID-0 volume. This is not a problem for me, because I backup most important data using CrashPlan to the cloud. But if you will decide to go only with local backups you can configure RAID-1 (or some other RAID levels) volume, which mirrors data between two drives. This means that if one of them dies - you can restore data from another one. If both of them die - you loose everything. 

Local backups are better than not having backups at all, but having external backups (physically external) is better. In case of flood or fire you can loose all your data if you keep everything in your house.

To configure RAID on Ubuntu at first you need to install `mdadm` (tool for managing RAID volumes)

```bash
$ sudo apt-get install mdadm
```

After that take a look on all drives you have 

```bash
$ sudo lsblk -o NAME,FSTYPE,SIZE,MOUNTPOINT,LABEL
```

Find drives which you want to use in RAID and invoke next command

```bash
$ sudo mdadm --create /dev/md0 --level=0 --raid-devices=2 /dev/sdf /dev/sdd
```

This command will create RAID-0 with two drives `/dev/sdf` and `/dev/sdd`. If you want to build RAID-1 (or any other RAID) just change `--level`, if you have more disks just change `--raid-devices` and add more of them in the list.

After that verify that they are created

```bash
$ cat /proc/mdstat
```

If you are trying to configure RAID-0 it will be available almost right after you created it. If this is another level - it will take some time to synchronize blocks between drives, you can watch for the progress

```bash
$ watch cat /proc/mdstat
``` 

After that you need to modify `/etc/mdadm/mdadm.conf` to include information about this RAID volume to make it available on startup

```
# Tell that RAID depends on these two disks
DEVICE /dev/sdf /dev/sdd
# RAID configuration
ARRAY /dev/md0 devices=/dev/sdd,/dev/sdf level=1 num-devices=2 auto=yes
```

After that using standard tool you can create new partition on this volume and mount it.

### Back In Time

As I said above I use [Back In Time](https://apps.ubuntu.com/cat/applications/backintime-gnome/) on Ubuntu instead of standard backup tool, as I like it more. To install it do

```bash
$ sudo apt-get install backintime-common backintime-gnome gksu
```

`gksu` is required to launch Back In Time in root mode (if you want to backup not only user folders). Without this tool you can still launch *Back In Time (root)* but standard `sudo` command will not set right home directory which `Back in Time` expects, so you will find out that Scheduler will use different configurations than you will expect. So just install this tool and launch *Back In Time (root)* from Applications menu.

After that open *Back In Time (root)* and change some settings

* In *General* specify where you want to save snapshots.
* In *Include* specify what you want to backup. I have `/`.
* In *Exclude* specify what you want to exclude, this is my list

```bash
.gvfs
.cache*
[Cc]ache*
.thumbnails*
[Tt]rash*
*.backup*
*~
.dropbox*
/proc/*
/sys/*
/dev/*
/run/*
/mnt
/media
lost+found
/var
/proc
/run
/home
/export
```

As you see I exclude `/home` because I backup it with CrashPlan and I exclude `/mnt` because I have mounted here only two partitions: one is the SSD drive with Virtual Machines, and another one is a partition where I store backups.

Using GUI you cannot specify more than one Scheduler for Back In Time, I used crontab editor to do that

```bash
$ sudo -s
$ crontab -e
```

Where I included two lines

```bash
0 2 * * 1-6 /usr/bin/nice -n 19 /usr/bin/ionice -c2 -n7 /usr/bin/backintime --backup-job >/dev/null 2>&1
0 2 * * 0 /usr/bin/nice -n 19 /usr/bin/ionice -c2 -n7 /usr/bin/backintime --checksum --backup-job >/dev/null 2>&1
```

As you see I scheduled two backups

* first is simple backup which just does `rsync` which compare what is new and what is backup up by using modification dates, I launch it every day at night (2 am) on Mon-Sat.
* another one, which I scheduled for Sun 2am is a full backup which verifies checksum for whole backup. It takes much longer than first one, but allows me to verify that backups are no corrupted.

### CrashPlan

I love CrashPlan. I pay for [Individual](https://www.code42.com/store/) account as I backup only one Computer which is my Ubuntu server.

Actually my first experience with it was terrible 

<blockquote class="twitter-tweet" lang="en"><p>No sure that I understand what is the point to use <a href="https://twitter.com/hashtag/CrashPlan?src=hash">#CrashPlan</a>? to backup 10 Gigs/month? Better to use <a href="https://twitter.com/hashtag/DropBox?src=hash">#DropBox</a> <a href="http://t.co/LGRA7EVVBx">pic.twitter.com/LGRA7EVVBx</a></p>&mdash; Denis Gladkikh (@outcoldman) <a href="https://twitter.com/outcoldman/status/521845027190751232">October 14, 2014</a></blockquote> <script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

After googling I found that a lot of users were complaining about the same issue. CrashPlan was way to slow for them. That it can take around 1 year to backup 1Tb of data. I thought that it is expected, so I gave up and started to look for alternatives. 

But to my luck CrashPlan answered on my complain which gave me some hope that I could do something to fix this issue

<blockquote class="twitter-tweet" lang="en"><p><a href="https://twitter.com/outcoldman">@outcoldman</a> That&#39;s way too slow, yes! Did our Customer Champions investigate?</p>&mdash; CrashPlan (@crashplan) <a href="https://twitter.com/crashplan/status/522428449579737089">October 15, 2014</a></blockquote> <script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

After googling one more time I found manual on CrashPlan support website [Speeding Up Your Backup](http://support.code42.com/CrashPlan/Latest/Troubleshooting/Speeding_Up_Your_Backup) (why people don't read manuals?) and so

<blockquote class="twitter-tweet" lang="en"><p>Using this manual <a href="http://t.co/CFUGQ80nXw">http://t.co/CFUGQ80nXw</a> I could speed up <a href="https://twitter.com/hashtag/CrashPlan?src=hash">#CrashPlan</a> backup process. Nice, like it! /cc <a href="https://twitter.com/crashplan">@crashplan</a> <a href="http://t.co/DMWnci8zSa">pic.twitter.com/DMWnci8zSa</a></p>&mdash; Denis Gladkikh (@outcoldman) <a href="https://twitter.com/outcoldman/status/522747030566088705">October 16, 2014</a></blockquote> <script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

I had few other issues with CrashPlan after that, but I could easily fix them by using support pages on CrashPlan website or by contacting CrashPlan support.

I uploaded 0.7Tb in just one week. At current moment I have over 1.1Tb data in CrashPlan, my backup is encrypted using [Custom Key](http://support.code42.com/CrashPlan/Latest/Configuring/Archive_Encryption_Key_Security) (which means that CrashPlan don't have access to my data). This is what I upload

* `/home` - all the important data I have on file shares
* `/etc` and `/usr/local/etc` - Ubuntu configuration files
* `/mnt/BACKUP/TimeMachine` - Time Machine backups

You can sign up for the 30 days trial to see how CrashPlan works. 

### Cloud alternatives

Because my first experience with CrashPlan was terrible I also tried some other alternatives, I could not find any alternative services to CrashPlan with native Linux client. So I tried to use cloud storage providers instead

* [Dropbox](https://db.tt/KRX4GZCQ), it has native Linux client, one note that you can also use [official Dropbox command line interface](http://www.dropboxwiki.com/tips-and-tricks/using-the-official-dropbox-command-line-interface-cli)
* [OneDrive](https://onedrive.live.com/?invref=ce278891f3e6b8cb&invsrc=90), you can use [Microsoft OneDrive daemon on Ubuntu](https://github.com/xybu/onedrive-d).

With them I just tried to backup most important data from my home folder directly without trying to backup anything else. This works too.

### Links

* [CrashPlan: Archive Encryption Key Security](http://support.code42.com/CrashPlan/Latest/Configuring/Archive_Encryption_Key_Security)
* [CrashPlan: CrashPlan runs out of memory and crashes](http://support.code42.com/CrashPlan/Latest/Troubleshooting/CrashPlan_Runs_Out_Of_Memory_And_Crashes)
* [CrashPlan: Speeding up your backup](http://support.code42.com/CrashPlan/Latest/Troubleshooting/Speeding_Up_Your_Backup)
* [CrashPlan: Stopping & staring the CrashPlan service](http://support.code42.com/CrashPlan/Latest/Troubleshooting/Stopping_and_Starting_The_CrashPlan_Service)
* [CrashPlan: Missing files from the restore tab](http://support.code42.com/CrashPlan/Latest/Troubleshooting/Missing_Files_From_The_Restore_Tab)
* [How can I encrypt data in Ubuntu One or Dropbox?](http://askubuntu.com/questions/75377/how-can-i-encrypt-data-in-ubuntu-one-or-dropbox)
* [Install Dropbox In An Entirely Text-Based Linux Environment](http://www.dropboxwiki.com/tips-and-tricks/install-dropbox-in-an-entirely-text-based-linux-environment)
