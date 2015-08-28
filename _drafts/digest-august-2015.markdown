---
layout: post
title: "Digest: August 2015"
categories: en
tags: [digest, llvm, dns]
---

For now, every month I will try to keep posting digest with the links to all
blog posts / books / interesting materials, which I have found very useful
or maybe just interesting for myself.

- [LLVM for Grad Students](http://adriansampson.net/blog/llvm.html). Great
    explanation about LLVM basics. Shows how you can implement your own LLVM
    passes to hack LLVM. When I was working in Microsoft one of the tools I was
    responsible for was Instrumentation profiler and Coverage tool. This tool
    can instrument functions/basic blocks in the specified libraries to insert
    probes, which are code blocks reporting entering/exiting to/from these blocks.
    When you execute your code with this probes you can collect this information
    to measure: code coverage and/or time execution off all blocks or functions.
    Obviously we have not used LLVM, we used Microsoft own solution for that.
    I just wish that it was so well designed as LLVM. So this basically gives
    you another idea what you can do with LLVM.
- [How DNS Works](https://howdns.works). You though you know how DNS works?
    Look on this comic. If you will find it useful and interesting - I suggest
    to read [High Performance Browser Networking](http://chimera.labs.oreilly.com/books/1230000000545),
    which can give you deep details about network you should know.
- [AWK GTF! How to Analyze a Transcriptome Like a Pro](http://reasoniamhere.com/2013/09/16/awk-gtf-how-to-analyze-a-transcriptome-like-a-pro-part-1/).
    If you are command line beginner, know basics of AWK, don't have a time to
    read `man awk` - these 3 articles are for you. Nice example, good explanation
    about how powerful is `awk`.
- [Symas Lightning Memory-Mapped Database (LMDB)](http://symas.com/mdb/).
    You probably know [SQLite](https://www.sqlite.org), so LMDB has a similar
    concept to be self-contained, serverless, zero-configurable database, but
    in addition it is ultra-fast, ultra-compact key-value embedded data store.
    If MongoDB already made you lazy and to not worry at all about schemas and
    you don't need/want to use DB server - LMDB is for you.
- [Unix Toolbox](http://cb.vu/unixtoolbox.xhtml). It is a little bit out of date
    (last update in 2012, relying on copyright), but still looks like very
    useful cheatsheet.
- [From Bash To Z Shell](http://www.bash2zsh.com). Great book. A little bit out
    of date, but has a lot of useful information about all different kind of shells.
