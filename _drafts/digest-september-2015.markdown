---
layout: post
title: "From my reading list: September 2015"
categories: en
tags: [digest]
---

In these digests I will also start to include some tools which I use.

- [miller](http://johnkerl.org/miller/doc/). Great open source tool to work with
    CSV files. "Miller is like sed, awk, cut, join, and sort for name-indexed data such as CSV."
- [jq](https://stedolan.github.io/jq/). The same purpose tool as `miller`, but for
    JSON. "jq is like sed for JSON data". Even if you will never use it for
    manipulating your JSON objects just start using it for JSON output highlighting
    and as JSON formatter with `pbcopy | jq . | pbpaste`.
- [icdiff](https://github.com/jeffkaufman/icdiff). Just a good addition for the
    diffing tools. Allows you to see changes side-by-side in your terminal. When
    you install it with `homebrew` it also install a script which allows you to
    run `git icdiff`.
- [OS-X-Yosemite-Security-and-Privacy-Guide](https://github.com/drduh/OS-X-Yosemite-Security-and-Privacy-Guide).
    Great list of things how to make OS X Yosemite more secure and protect
    your privacy. I have changes `0` things after I read this list, but I learned
    some. I also saw similar for Linux, mostly about [security only](https://github.com/lfit/itpol/blob/master/linux-workstation-security.md),
    but it wasn't really interesting for me.
- [How does a relational database work](http://coding-geek.com/how-databases-work/).
    I can not even imagine how much time it took Christophe to write this article.
    Well explained. I believe that experts and beginners can find something in
    this article. Also one more resource with good readins is [Readings in Databases](https://github.com/rxin/db-readings)
- [Go GC: Prioritizing low latency and simplicity](https://blog.golang.org/go15gc).
    Garbage collector in golang 1.5 has been improved, which means that golang
    now has only one issue, which still [bothers me]({{post_url /en/2015-07-07-my-experience-with-golang}}) -
    go dependencies (they are working on it, there are already some experimental
    implementations around vendoring).
- [docker-cheat-sheet](https://github.com/wsargent/docker-cheat-sheet). Nice
    list of how to get started about docker. And if you want to learn more
    this is an [awesome-docker](https://github.com/veggiemonk/awesome-docker)
    list.
- [selfspy](https://github.com/gurgeh/selfspy). I am not using it, but still
    think that it is interesting idea. Spy on yourself, so you will be able to
    restore files, which you forgot to save or see how much time you spent in
    IDE and how much time in the browser.
- [gdb-dashboard](https://github.com/cyrus-and/gdb-dashboard). Nice interface
	for gdb. It is built using only native Python API. Nice to have for linux.
- [A Visual Introduction to Machine Learning](http://www.r2d3.us/visual-intro-to-machine-learning-part-1/).
    Just hope that they are not going to stop on first article. Really good explanation,
    very nice animation, but very basics.
- [Raft Consensus Algorithm](http://thesecretlivesofdata.com/raft/). Previous
    animation reminded me about another animation I saw few months ago about
    Raft algorithm. Link if you have not seen it.
- [Fluent Python](http://shop.oreilly.com/product/0636920032519.do). Great book
    if you need to learn Python. It maybe not suitable for beginners, but very
    good for people who developers in other languages and maybe had some experience
    with Python before. A lot of links on external resources, so it is easy
    to learn more about some topics.
- [High Performance Python](http://shop.oreilly.com/product/0636920028963.do).
    Mixed filling about this book. It is well written, but not what I expected.
    Most of the perf tips I got from *Fluent Python*, so it felt like that reading
    this book after *Fluent Python* was a waste of time. So nothing wrong with
    this book, just does not seem like a good addition to *Fluent Python*.
