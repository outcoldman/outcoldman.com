---
categories: en
date: "2014-05-28T00:00:00Z"
tags:
- Xcode
- Xcode 5
- OS X
- perforce
- p4
- git
- git p4
title: Xcode 5 and perforce
slug: "xcode_and_perforce"
---

In time when git is a king of all source control systems we all still need to use other source control systems for various reasons. In my case this system is [perforce](http://perforce.com). First of all I would just say that it is not so bad as you would expect. If you used [Team Foundation Version Control (TFVC)](http://msdn.microsoft.com/en-us/library/ms181237.aspx) before and you remember all the thousands features you could not find in it or other thousands limitations with what you can do with it. Perforce is exactly the same or at least very familiar to TFVC/VSS source control system, but where all of these features and limitations are implemented, plus they all are implement in the way that you can perform the same task in 5 different ways. 

Xcode 5 officially does not support perforce. So the only one official way of working with default perforce workspace is to go back and forward from/to terminal and do `p4 open`, `p4 add` and `p4 move` commands. I've found three ways how you can simplify this a little bit.

## 1. Extend Xcode with Scripts

You can keep using standard perforce workspace and use special scripts, which will help you to auto checking out files on edit. Also you can add couple of AppleScript which will allow you to do some common scenarios from Xcode, like file rename and add file to default changeset.

There are several things you need to do

* Follow this instruction [Automatically Checking Out Files for Edit in Xcode](http://answers.perforce.com/articles/KB_Article/Automatically-Checking-Out-Files-for-Edit-in-Xcode/).
* Download *Perforce and Xcode 5* set of scripts from [Jaime Rios's blog](http://www.jaimerios.com/?p=1389) (huge thanks to Jaime!) (or from [perforce workshop](https://swarm.workshop.perforce.com/files/guest/jaime_rios/xcode_p4_applescripts)). Follow instructions from comment *Jaime Said On 11-01-2014*

> If you are not using AppleScript at all, chances are, you don’t see the AppleScript drop down menu.

> So, to use the AppleScripts, you have to make sure the menu is available. This option can be turned on within the AppleScript editor app, located at "/Applications/Utilities/AppleScript Editor.app".

> After you open the AppleScript Editor.app, open the preferences and make sure the “Show script menu in menu bar” option is selected. After you turn on that option, you should see an AppleScript icon in your menu bar.

> Next, open Xcode and from the AppleScript drop down menu, select "Open Scripts Folder->Open Xcode Scripts Folder", which should open a folder for you in the Finder; usually, the path is "~/Library/Scripts/Applications/Xcode".

> Copy the AppleScripts I made for Perforce into that folder and when you go back into Xcode, you should see each of the AppleScripts there for your use.

> Any one of the AppleScripts can be opened in the AppleScript Editor so you can see how they work, which I would suspect you would do if you are having problems with the scripts working.

> Usually, when people ask me about scripts that aren’t working, it’s because they haven’t set up the p4 command line app or, and usually more often the case, they didn’t set up the P4HOST or P4CLIENT settings in the ~/.bash_login file.

> Let me know if you have any other issues and I’ll try to assist.

> Happy Coding!

I was using this options for a while, and it worked well for me. But I was looking for some other options if they are exist.

## 2. Use perforce Allwrite option (SVN-like way of editing sources)

You can try to make perforce work in the way as SVN works, when all files are checked out by default (no readonly files). To commit files you need to invoke `p4 reconcile` command to find changes and submit them after that. I'd recommend you to start exploring this option from this article [Say Goodbye to p4 Edit](http://www.perforce.com/blog/131112/say-goodbye-p4-edit).

You also want to explore `P4IGNORE` option ([New in 2012.1: P4IGNORE](http://www.perforce.com/blog/120214/new-20121-p4ignore)) to hide some files form `p4 reconcile` command.

I did not like this option, because our code base is really big and `p4 reconcile` was too slow for me.

## 3. Clone perforce workspace in git repository

There are two ways of doing it. At first you can use [Git Fusion](http://www.perforce.com/product/components/git-fusion) from perforce. I have not use it, so nothing to suggest you. 

Second option is to simple use `git p4` command (this command is included as the top level git command). I would recommend you to read [git-p4(1) Manual Page](http://git-scm.com/docs/git-p4). I did not have a lot of experience with it. Just started to use it, so again nothing to recommend you here. Just try it. Later I will probably post some thoughts and recommendation with more details about this approach if I will like it.

Also I would recommend you to read [Perforce for Git users?](http://stackoverflow.com/a/17331274/421143) answer on StackOverflow if you know git and just want to understand how perforce works. 