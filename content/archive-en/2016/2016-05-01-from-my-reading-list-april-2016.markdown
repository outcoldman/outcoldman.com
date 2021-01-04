---
categories: en
date: "2016-05-01T00:00:00Z"
tags:
- facebook
- vscode
title: From my reading list - April 2016
slug: "from-my-reading-list-april-2016"
---

- [How I hacked facebook...](http://devco.re/blog/2016/04/21/how-I-hacked-facebook-and-found-someones-backdoor-script-eng-ver/)
- [Animagraffs](http://animagraffs.com). Nice animated graphic about some
  basic things.

## VSCode

This month I have spent a lot of time playing with [Visual Studio
Code](https://code.visualstudio.com). Not only using it as a main editor, but
also contributing to the code base.

Really good start. Liked the way they
integrated debugger inside editor without bringing whole IDE experience. Really
nice and clean code base. Mostly written in TypeScript.

There are few things I did not like about the project:

- The way they maintain the project. Master
  is almost always broken (3 out of 3 times I pulled it).
  Main contributors do not create pull requests, direct commits to the master.
  They call it [aggressive development
  process](https://github.com/Microsoft/vscode/issues/5507). Anyway,
  whatever works for them. 
- If you will compare VSCode to Sublime Text or Vim - you will feel how slow
  VSCode is. `Ctrl+P` (fuzzy search by file names) is really slow in VSCode,
  like 300ms slower. [It made me
  laugh](https://github.com/Microsoft/vscode/issues/5638). This issue was one
  of the reasons, why I could not continue to use Visual Studio Code. And I am
  on 90% sure that this is the reason why people say that Visual Studio Code is
  slow, just because they "give the user a chance to finish his typing". Anyway
  I hope they will fix it. I believe there are also a lot of other ways they
  slow down the experience with not the smart decisions, like I am on 90% sure
  that every time when you open new VSCode instance it creates new Electron
  process which connects to existing one and opens the window using existing
  one. My bet they can speed up experience without opening new Electron process
  for that.
- Slow PR acceptance process. I already have 3 PR, only one of them was
  approved, two other wait for some people come back from vacation.
- You feel the JavaScript. I guess if you are ok with IDEA or VS - you will be
  fine, but if you have been used editors like Vim or Sublime Text before - you
  will feel that VSCode is slow, and sometimes freezes just for few moments
  while you are typing.

Anyway I personally feel it will be one of the best editors soon. I will
definitely take a look on v2 when and if it will come out. Especially if they
will fix some of the performance issues.
