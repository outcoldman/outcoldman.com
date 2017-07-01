---
layout: post
title: "Best visual diff tool on OS X"
date: 2014-05-12 00:00:00 -00:08:00
categories: en
tags: [Kaleidoscope, git, diff, FileMerge, opendiff, p4merge, p4]
---

If you know one please tell me.

For the last couple of months I was trying various options for doing diffing and merging on Mac with `git` and `perforce`.

Perforce itself has pretty good merging tool `p4merge` and people [already know](http://pempek.net/articles/2014/04/18/git-p4merge/) how to setup it with `git`. It is good, but feels slow and does not allow to do dirs diffing (at least I don't know how to do that).

The other option which I was using for a while is `FileMerge` (`opendiff`). Also good tool. You can find some articles about how to set it up with git, like [Integrating Git with a Visual Merge Tool](http://gitguru.com/2009/02/22/integrating-git-with-a-visual-merge-tool/), this article also tells about other tools which you can use with git. 

Strange that I did not see it anywhere in articles (maybe it is one of the new features in git) that you can use `-d, --dir-diff` with difftool. This is the description of this option

>  Copy the modified files to a temporary location and perform a directory diff on them. This mode never prompts before launching the diff tool.

For example by using it with `opendiff`

```
git difftool -d -t opendiff
```

You can get the list of all modified files in FileMerge window

![FileMerge]({{ site.url }}/library/2014/05/git.difftool.opendiff.png)

After that just double click on files in the list to see the diff. 

In conclusion I would just say - these two tools are good, but both require some time from you for gluing them with tools you use. 

If you want easier way - buy [Kaleidoscope](http://www.kaleidoscopeapp.com). Yes, it is expensive for the diff/merge tool. But yes, it is worth it. Why? Because it requires only 3 minutes to set it up with almost anything, just check Kaleidoscope integration window

![Kaleidoscope integration]({{ site.url }}/library/2014/05/ksdiff.png)