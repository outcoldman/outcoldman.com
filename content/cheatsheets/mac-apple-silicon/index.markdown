---
layout: markdown_page
title: "Cheatsheet: macOS Setup (Apple Silicon edition)"
draft: true
---

## Homebrew and CLI tools

### Homebrew

Run it under Rosetta 2 for now (see ). Add to your `.zshrc` alias

```bash
alias brew="arch -x86_64 brew"
```

> For now some of the most important I install manually (go, hugo, etc)

## Applications

Check compatibility on (Is Apple Silicon ready?)[https://isapplesiliconready.com]

### Docker

Download from [Apple M1 Tech Preview](https://docs.docker.com/docker-for-mac/apple-m1/)

### Parallels

Download from [Parallels Desktop for Mac with Apple M1 chip](https://www.parallels.com/blogs/parallels-desktop-apple-silicon-mac/)

### Ubuntu in VMs

https://github.com/gyf304/vmcli

### Little Snitch

https://pgl.yoyo.org/adservers/serverlist.php?hostformat=littlesnitch-rule-group-subscriptions&mimetype=plaintext
https://github.com/naveednajam/Little-Snitch---Rule-Groups