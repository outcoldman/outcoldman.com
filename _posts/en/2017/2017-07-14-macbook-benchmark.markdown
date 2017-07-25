---
title: "MacBook: benchmarks for developers"
tags: [macbook, benchmarks]
---

Few weeks ago I decided to get myself a MacBook. Wanted compact, lightweight MacBook, and good battery life.
I started to consider MacBook instead of MacBook Pro, but wanted to be sure that performance will not be a problem.
Few years ago I have heard that MacBooks were very slow, but this year Geekbench showed very promising
[results](https://www.reddit.com/r/apple/comments/6jdfcz/geekbench_average_cpu_scores_for_all_2017/).
So I got it, now I am trying to test it as much as I can to be sure that there are will be no surprises in performance.
Also I am comparing performance to other Apple devices I have.

For my tests I used

1. MacBook (Retina, 12-inch, 2017), 1.4GHz Intel Core i7, 16 GB 1867MHz LPDDR3, Intel Graphics 615 1536 MB, 256 GB SSD
2. MacBook Pro (13-inch, 2016, Four Thunderbolt 3 Ports), 3.3 GHz Intel Core i7, 16 GB 2133 MHz LPDDR3, Intel Graphics 550 1536 MB, 512 GB SSD.
3. Mac mini (Late 2014), 2.6GHz Intel Core i5, 8 GB 1600MHz DDR3, Intel Iris 1536MB, 256 GB SSD
4. iMac (Retina 5K, 27-inch, Late 2015), 4GHz Intel Core i7, 24 GB 1867 MHz DDR3, AMD Radeon R9 M395X 4096 MB, 513 GB SSD.

> To make it clear, MacBook Pro is not mine, so I am not looking for another laptop, I am actually considering the
> only one laptop for myself.

All of them have macOS Sierra 10.12.5 intalled. Both MacBooks have Firevault enabled.

## Geekbench

I don't really trust Geekbench. But my original decision to buy MacBook was based on the results from this website, so
I collected benchmarks myself.

No surprises here, you can see detailed results on my [profile](https://browser.geekbench.com/user/133014), and this is
a summary

![macbook geekbench]({{ site.url }}/library/2017/07/macbook/macbook-geekbench.png)

iMac has best performance, and Mac mini shows the lowest performance, it is 2.5 years old and had low end CPU.
MacBook Pro from the last year shows the same performance as this year MacBook.

Also GPU tests just for reference

![macbook geekbench GPU]({{ site.url }}/library/2017/07/macbook/macbook-geekbench-gpu.png)

## Blackmagic Disk Speed Test

Used [Blackmagic Disk Speed Test](https://itunes.apple.com/us/app/blackmagic-disk-speed-test/id425264550?mt=12) to test
disk speed

![macbook disk speed]({{ site.url }}/library/2017/07/macbook/macbook-disk-speed.png)

This is where I [found](https://twitter.com/outcoldman/status/886025090265108480) that I forgot to enable TRIM when I
installed SSD drive in Mac Mini 2,5 years ago. So, remember this when you will look on all other charts, it is possible
that in some tests Mac mini can show better performance with good SSD drive.

> SSD replacement is not very expensive, but process as I remember [requires](https://www.ifixit.com/Guide/Mac+Mini+Late+2014+Hard+Drive+Replacement/32815) to tear down everything.

## Compiling LLVM (Native)

My first test was the compilation of LLVM from sources. The simplest way to do that is to use `brew`.
Before running the test I verified that all dependencies are installed from the output of
`brew info llvm`. To run the test I used `time brew install llvm --HEAD`, I run it
two times, where second time brew used cached git repositories

![macbook llvm]({{ site.url }}/library/2017/07/macbook/macbook-llvm.png)

Second run

![macbook llvm (second run)]({{ site.url }}/library/2017/07/macbook/macbook-llvm-second.png)

> `HOMEBREW_MAKE_JOBS` is set to number of cores of this device (`4` for all, except iMac, which has `8`)

If you are not familiar with output of `time` utility, *real* time is how long it actually took to run the command,
*user* is for how long this utility was scheduled on CPU (sum of all cores), and system is the time of system overhead
(not really important for us).

Let's look first on difference between MacBook Pro and iMac. iMac has CPU speed of 4.0GHz (turbo boost up to 4.2GHz), MacBook Pro
has 3.3GHz (turbo boost up to 3.7GHz), their user CPU time is very close, but because iMac has two
times more cores it took 2 times less of real time.

MacBook has 1.4GHz speed with turbo boost up to 3.6GHz, but it cannot keep turbo boost for long time. This is
why it is 1.6x times slower than MacBook Pro. Geekbench tests are very short, so they reflect mostly turbo boost speed.
But long running CPU jobs aren't showing the same results as Geekbench.

And as you can see Mac Mini showed very good results. Also considering that it has issues with SSD drive.

## Compiling ElasticSearch (Java)

For the next test I used Elasticsearch code base from master. I used latest `Java 8`

```bash
$ java -version
java version "1.8.0_131"
Java(TM) SE Runtime Environment (build 1.8.0_131-b11)
Java HotSpot(TM) 64-Bit Server VM (build 25.131-b11, mixed mode)
```

Also built it two times, first run

```bash
time JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk1.8.0_131.jdk/Contents/Home/ gradle assemble
```

![macbook java]({{ site.url }}/library/2017/07/macbook/macbook-java.png)

and second time I rerun the tasks, that time using cached dependencies

```bash
time JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk1.8.0_131.jdk/Contents/Home/ gradle assemble --rerun-tasks
```

![macbook java second]({{ site.url }}/library/2017/07/macbook/macbook-java-second.png)

After that did another run in IntelliJ IDEA, just compiling the elasticsearch engine, showed me very similar pattern

![macbook java IDEA]({{ site.url }}/library/2017/07/macbook/macbook-java-idea.png)

## Compiling docker in docker (Virtualization)

Used latest Docker for Mac

```bash
Client:
 Version:      17.06.0-ce
 API version:  1.30
 Go version:   go1.8.3
 Git commit:   02c1d87
 Built:        Fri Jun 23 21:31:53 2017
 OS/Arch:      darwin/amd64

Server:
 Version:      17.06.0-ce
 API version:  1.30 (minimum version 1.12)
 Go version:   go1.8.3
 Git commit:   02c1d87
 Built:        Fri Jun 23 21:51:55 2017
 OS/Arch:      linux/amd64
 Experimental: true
```

All macs had the same configuration of 2 CPU and 4GB given to Docker for Mac.

At first I built docker development container with `time make BIND_DIR=. shell`. Results aren't so interesting, because
this command has many dependencies on external services. All macs showed very similar results between 7 and 11
minutes. MacBook was faster than MacBook Pro in this run, so I decided not to share this result, did not want to
confuse.

After that I run `time hack/make.sh binary` inside container

![macbook docker]({{ site.url }}/library/2017/07/macbook/macbook-docker-in-docker.png)

Very good results for MacBook.

## Battery test

To test the battery I charged both MacBooks to `100%`. Turned the screen brigtness to `100%`. Disabled *Slightly dim the
display while on batery power* and *Automatically adjust brightness*. And compiled llvm again

![macbook battery]({{ site.url }}/library/2017/07/macbook/macbook-battery.png)

MacBook run for 1 hour and 10 minutes and took 35% of battery. MacBook Pro run for 51 minutes and took 61% of battery.
With MacBook I could run another test with brigtness set to minimum, it run for 67 minutes and took another 32% of
battery. MacBook pro could not finish the second run.

To be honest they both showed pretty bad results. When I owned MacBook Pro 15-inch Late 2013 I could easily compile
several times similar in size project without any issues. The only problem I had with that MacBook - the discrete graphic.
Sometimes Chrome could turn it on and that could drain battery pretty quickly. That was a time when I started to dream about
13-inch MacBook Pro without discrete graphic card. But seems like battery life is getting worse these days, when you
run your laptop on full speed.

## Summary

- So far I like MacBook, it certainly slower than other MacBooks, but overall gives ok performance. Considering that my
main home workstation is iMac, MacBook feels good as a secondary Mac, and very mobile laptop. I have 2 weeks to decide
if I really want to keep it, or get MacBook Pro instead.
- Using IntelliJ IDEA on full speed certainly kills the battery. I used WebStorm to write this blog post, and it felt
like it used ~20-30% of battery in hour or a little more than that. This could be a reason, why I could return MacBook.
- MacBook quiality, comparing to MacBook Pro, feels like it is a successor of MacBook Air. Feels cheaper, display is not
so bright as MacBook Pro, Touch Pad is not as good as MacBook Pro. Maybe it is just because I used MacBook Pro for a
long time before.
- In process of installation, enabling FireVault, downloading emails, photos, music, etc - MacBook froze once.
Also in the moment of setting it up it felt very slow. After Spotlight and Photos have finished first indexation -
everything feels normal.

[Update](https:///www.outcoldman.com/en/archive/2017/07/24/macbook-returned/)
