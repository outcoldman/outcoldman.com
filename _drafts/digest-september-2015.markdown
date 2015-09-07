---
layout: post
title: "Digest: September 2015"
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
