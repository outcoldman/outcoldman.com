---
layout: post
title: "My experienec with golang."
date: 2015-06-08 00:00:00 -00:08:00
categories: en
tags: [golang, languages, go]
---

In last month I played a little with [golang](http://golang.org). Want to share my experience with you. I'm not an expert in golang.

## I did not like

### Platform is still on it's early stage

Issues with Garbage Collector. On very large projects you may see that your application hangs for 10-30 seconds. It is expected because of the `stop the world` phase in Garbage Collector. You can find a lot of articles, talks about this issue (to diagnose it use [Profiling Go Programs](https://blog.golang.org/profiling-go-programs)). It is a real bammer when on the production server you see that some requests to your web service can hang for 10 seconds. The fix [is coming in golang 1.5](http://llvm.cc/t/go-1-4-garbage-collection-plan-and-roadmap-golang-org/33). Personally, I have not seen this issue, because my project did not used a lot of memory on the heap. Btw, it is not so obvious [when variables are allocated on stack or heap](https://golang.org/doc/faq#stack_or_heap), so it is not so easy to fix this issue.

The same with the standard library, sometimes you can find that it just doesn't support some obvious things, like this one [net/http: allow graceful shutdown](https://github.com/golang/go/issues/4674). This issue says that if you want to handle signals on your own - there are no way to shutdown listener. You can use [workaround](http://www.hydrogen18.com/blog/stop-listening-http-server-go.html).

Golang was shown to public in 2009. First release was in 2012. And it does not seem like it is moving very fast.

### Language and standard library can surprise you

None of examples below are real stoppers from using golang. These are just things I dealt with in the first week very often.

At first take a look on this code. Does it look like it is doing what it suppose to do (hint: no compile issues)?

```
_, err = os.Stat(filename);

// Using function https://golang.org/pkg/os/#IsNotExist to check if file does not exist
if os.IsNotExist(err) {
    fmt.Printf("no such file or directory: %s", filename)
    return
}

// Using function https://golang.org/pkg/os/#IsExist to check if file exists
if os.IsExist(err) {
    fmt.Printf("file or directory exists: %s", filename)
    return
}
```

But of course it does not. Second if is wrong. [Stat](https://golang.org/pkg/os/#Stat) returns `nil` as an `error` if file exists, so you actually need to check `if err == nil`.

Other really annoying thing

```
type Foo struct {
    bar string
}

// ...

a := Foo{ "test" }
b := Foo{
            "test",
        }
```

In second initialization comma is required, you will get compiler issue if you will not specify it.

Sometimes compiler does not help when you dealing with pointers

```
package main

import "fmt"
import "encoding/json"

type Foo struct {
    Bar string
}

const jsonString string = "{ \"Bar\": \"changed\" }"

func main() {
    a := Foo{}
    b := &Foo{}
    c := Foo{}

    json.Unmarshal([]byte(jsonString), a) // bug on this line
    json.Unmarshal([]byte(jsonString), b)
    json.Unmarshal([]byte(jsonString), &c)

    fmt.Println(a.Bar) // empty
    fmt.Println(b.Bar) // changed
    fmt.Println(c.Bar) // changed
}
```

Obviously this is expected, just something easy to miss. Especially when you are using marshaling a lot.

Pointers can confuse golang beginners. Just read few articles, like [Pointers in Go](http://dave.cheney.net/2014/03/17/pointers-in-go) and [Pointers](https://www.golang-book.com/books/intro/8).

You can find more of these common surprises in [50 Shades of Go: Traps, Gotchas, and Common Mistakes for New Golang Devs](http://devs.cloudimmunity.com/gotchas-and-common-mistakes-in-go-golang/)

### $GOPATH

I hate when platform requires some additional setup, which affects my current workflow. [GOPATH](https://github.com/golang/go/wiki/GOPATH) is very confusing. How do I manage multiple projects? How do I integrate my go project with other platforms (C++, node.js, python)?

Also standard package management is awful, does not allow you to lock versions, so you just keep hope that none of the packages you use accept direct commits to master branch. Good, that folks already wrote their own [package management tools](https://github.com/golang/go/wiki/PackageManagementTools). Bad, that there are few dozen of them already. Which one to choose?

## I liked

### Development process is fast

Golang is one of the easiest languages. You can learn it in few hours with [A Tour of Go](http://tour.golang.org) (and of course you will hit all the issues described above after that in first few weeks). Compilation is quick, 3 seconds to build 10Mb binary is very impressive result. If compilation is slow for you, it is possible that one of your libraries have `c` code, like case with [sqlite](https://groups.google.com/forum/#!topic/golang-nuts/KexEyiy6PvA).

You will find plenty of existing tools for golang: test framework, coverage tools, linter, documentation generation. All of these you will get [out of the box](https://golang.org/cmd/). And a lot of [packages](https://godoc.org) written by community, or another list [awesome-go](https://github.com/avelino/awesome-go).

I used vim for development with [gotags](https://github.com/jstemmer/gotags) for generating ctag, [vim-go](https://github.com/fatih/vim-go) for syntax support and [syntastic](https://github.com/scrooloose/syntastic) for syntax checking. If syntax checking will be slow you can exclude some of [them](https://github.com/scrooloose/syntastic/tree/master/syntax_checkers/go).

### No dependencies on runtime

You can compile it. It is statically typed. Go compiles code in binaries and it does not require you to install runtime to execute them (see [Why is my trivial program such a large binary?](https://golang.org/doc/faq#Why_is_my_trivial_program_such_a_large_binary)). Compile it and it is ready to be copied anywhere (the same platform obviously).

### A lot of great tools

I told you already about libraries, but you can actually find that a lot of great tools are written in go, for example these are what I used/tried recently

* [Mongo tools](https://github.com/mongodb/mongo-tools)
* [Consul](https://www.consul.io), also [Serf](https://www.serfdom.io)
* [GitLab CI multi runner](https://www.serfdom.io)
* [Docker](https://www.docker.com)
* [Bolt](https://github.com/boltdb/bolt) - Key/Value database
* [kubernetes](https://github.com/GoogleCloudPlatform/kubernetes)
* [packer](https://github.com/mitchellh/packer)
* [etcd](https://github.com/coreos/etcd)

Which means that you will not be alone here.

## When to use

So should you use node.js/python/ruby or golang for the next project? This is my list

* Command line tool - yes.
* Small script - no.
* Micro (Small) Web services - yes.
* Cron-like or low-level services - yes.
* Large web sites - no.
* GUI - no.
* Rewriting existing projects - no.
* Any project which will depend on other platforms - no.

In general I'm really impressed by golang. Great platform, great language.

P.S. Please don't suggest me to try Rust.
