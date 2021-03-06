---
categories: en
date: "2015-02-11T00:00:00Z"
tags:
- DD-WRT
- linksys e4200
- router
- Dynamic DNS
title: Give your router second chance.
slug: "give-your-router-second-chance"
---

Few days ago I decided that I want to have my local DNS server, becase I want to have more than one DNS name for the same server (hosting multiple websites / services on the same server and have meaningful DNS names). At first I tried to setup it with [DNSMasq](http://en.wikipedia.org/wiki/Dnsmasq) on the same Ubuntu server as I use for everything else. After that you will need to specify this DNS server in router options, so all devices on local network will use it to resolve names. That was not hard to setup, but problem I had with this solution: any reboot of server will prevent all other devices from accessing Internet till it will not start to answer on DNS requests. You can also specify second DNS server as backup as Google DNS `8.8.8.8` and `8.8.4.4`. But this also has a problem: on first error router will switch to second DNS server (Google DNS in our example) and will not use first one for some time, which means that all local resources can be unavailable for some time.

Better ideas? Sure. You can buy super expensive and advanced router, which may have this feature. I bought [Netgear Nighthawk X6 Tri-Band R8000](http://www.netgear.com/home/products/networking/wifi-routers/R8000.aspx). Honestly I don't even remember if this router has support for custom DNS records or not, because after I started to experience the same Wi-Fi issues as most of Apple users on Yosemite, I decided that I want to return it and find something else. I don't think that this was Netgear issue, but because my old Linksys E4200 worked without any issues, I decided to keep using it till I will not find something else.

So after I returned *R8000* I started to explore what else I can do or buy. What is the router for advanced users? After googling I found, that I already an owner of one of the most advanced routers [Linksys e4200 v1](http://support.linksys.com/en-us/support/routers/E4200), I just don't have right firmware installed on it. I have heard about [DD-WRT](http://www.dd-wrt.com/site/index), [OpenWrt](https://openwrt.org) and [Tomato](http://www.polarcloud.com/tomato) before, but for some reasons never thoughts that it worse my time. Oh boy, I was wrong...

First of all big thank to [Steve Jenkins' Blog](http://www.stevejenkins.com/blog/) and especially [
My Cisco Linksys E4200 DD-WRT Settings for Max Speed](http://www.stevejenkins.com/blog/2013/01/my-cisco-linksys-e4200-dd-wrt-settings-for-max-speed/). I never wanted to get Max Speed from my router, I was satisfied with what I had, but this post gave me a good start to understand what benefits I can get from DD-WRT and how to install it. I would recommend before setting all of the settings which Steve suggests, read first what it means. The same settings which works for Steve, maybe will not work for you. For example Steve recommends to use *Frame burst*, but help says

> ... this is only recommended for approx 1-3 wireless clients, Anymore clients and there can be a negative result and throughput will be affected.

I have more than 1-3 devices, so I did not use this one. Be careful. Also I use old build which Steve marked as *Outdated Builds I No Longer Recommend* recently, mostly because couple weeks ago it was recommended by him. Other than that I just followed his blog post to understand all parts of this firmware and configure it in most cases in the same way as he did. After that I verified that everything works as expected, backed up configuration and started to explore what else I can get from it.

* I don't need to run `ddclient` on my [Ubuntu server](/en/archive/2014/10/14/ubuntu-as-a-home-server-part-1-dynamic-dns/) anymore, because DD-WRT router supports it out of box (almost our of box), see Namecheap manual [How to configure a DD-WRT router](https://www.namecheap.com/support/knowledgebase/article.aspx/9356/11/how-to-configure-a-ddwrt-router).
* I have better Guesti Wi-Fi network than I had before. All my Wi-Fi guests always had issues with sign in page on Linksys E4200, but now I can setup virtual endpoint with separate `WPA2 Personal` password and separate subnetwork, see [DD-WRT Guest Wireless](http://www.alexlaird.com/2013/03/dd-wrt-guest-wireless/).
* I can setup my local DNS records with DD-WRT and have multiple DNS names for the same IP address. Also OpenVPN works much better with local DNS, so all home addresses now can be resolved without any issues to OpenVPN clients. I used this manual to do find out how to setup local records [Setup Local/Internal DNS with a DD-WRT Router](http://cybernetnews.com/local-internal-dns-ddwrt/). Btw, I still [run my own OpenVPN server on Ubuntu](/en/archive/2014/10/21/ubuntu-as-a-home-server-part-2-openvpn/), as I needed more than one configuration.
* I can change *TX Power* setting for Wi-Fi radio. Two reasons for that. Maybe you live in big house and want stronger signal, so you want to increase this value. Or you live in apartment and you don't need to have so strong signal, and you can lower it.
* You can also simply turn off WiFi radio for hours when you don't need or want to use it. Various reasons for that.
* This is Linux, and you can get access with SSH, cron is available. My guess that there are still a lot what you can do with this router.
