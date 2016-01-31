---
layout: post
title: "HDHomeRunHD PRIME, Comcast and CableCARD"
categories: en
tags: [comcast, hd channels, tv tuner, silicondust, hdhomerun]
---

Or better topic "How to watch HD Channels with Comcsat with your own tuner".

I don't watch a lot of TV, but sometimes I do: sport or TV shows . You
know that it is almost impossible to watch sports online in USA, and even if
you will find a way - it will be unpleasant: quality will not be great.
The same about TV Shows, even if you have Comcast subscription to some channels
they still keep showing you a lot of advertisements. I see
a benefit of having Comcast TV (or any other TV provider you have in
your area) as it gives you ability to enjoy HD TV to watch Sport. Also with
Comcast you can use DVR (recording) to watch TV Shows later with skipping
advertisement.

But still my main problem with Comcast - it is not cheap. Especially for me, as
I said I do not watch a lot of TV and for few hours in a week - it does not
feel right to pay what Comcast asks.
First of all it is not cheap, because Comcast requires you to upgrade your TV Tunner to HD
version if you want HD quality. This costs additional *$10-15* per month (for each TV). And
even then you will not be able to watch shows and sports on your laptop or
desktop (not all of them).

I have never had HD TV Tunner from Comcast, only the one they give for "free",
which doesn't support HD and does not have a DVR.

I wanted to have HD, but before upgrading to HD TV Tuner from Comcast
I decided to spend some time to find if there
are any other options to get HD TV and DVR. And I actually found nice and easy
solution. You can order CableCARD from Comcast, see [CableCARD: Know Your Rights](https://www.fcc.gov/guides/cablecard-know-your-rights)
and [About CableCARDs](http://customer.xfinity.com/help-and-support/cable-tv/about-cablecards/).
Just return your current Tuner to Comcast office and ask for the CableCARD
instead. Don't order CableCARD without returning your TV Tuner as they will
charge you for two devices.

Before you will do that let me actually at first summarize why you may want to
do that (or not).

### Advantages of having CableCARD

- You can buy any Tuner you want. It can be something "cheap" for *~$130* or
    expensive TiVO box. It will be your own Tuner, not need to pay for rental.
    I purchased [HDHomeRun PRIME](http://www.silicondust.com/products/hdhomerun/prime/)
    so all next good parts will be about this Tuner.
- You can watch up to 3 channels at the same time on supported devices. With
    Comcast Tuner you will need to rent additional tunner for each device.
- You can watch TV on any device which supports DLNA. It can be simple VLC
    Player on your Mac OSX or Channels App on Apple TV.

### Disadvantages of having CableCARD

- You need to purchase a Tuner.
- There are not so many applications for viewing TV, most of them are not free.
    After buying a Tuner you will find out that you need to pay *$14* for iOS,
    *$14* for Apple TV and so on.
- It requires manual setup.
- You will not be able to watch *Xfinity On demand* with your Tuner (only in
    web browser from Mac or PC).
- There are not a lot of good applications with DVR support and a lot of them
    are not free, like *$50-80*.
- Comcast support may not know about that at all. You can easily get to some
    guy who has 0 knowledge about what is *CableCARD* and how to help you to
    get the right channels.

Anyway - it is your decision. If you will decide to get *CableCARD* - feel free
to continue reading to learn about my experience.

## HDHomeRun PRIME Installation on Mac OSX

I bought [HDHomeRun PRIME](http://www.silicondust.com/products/hdhomerun/prime/).
Below are instructions how to set it up.

- Connect everything. I have connected coaxial cable, Ethernet cable, installed
    CableCARD and turned it on.
- Give it few seconds to boot. Open this page [HDHomeRun Hardware](http://my.hdhomerun.com).
    It should auto discover tuner in your network. At my case it showed that my
    tuner had some unknown firmware.
- Download [HDHomeRun Software](http://www.silicondust.com/support/downloads/)
    and install it. I used it with Mac OSX. It asks if you want to install
    viewer and recorder. You should install recorder only if you want to
    purchase [HDHomeRun DVR](https://www.silicondust.com/shop/) from SiliconDust
    (additional *$60* for the time of writing). It also will upgrade Firmware
    to latest using Terminal.
- I went to the page [Comcast Activate](http://comcast.com/activate), followed
    few steps, this page told me that everything is activated.
- After that I opened [HDHomeRun Hardware](http://my.hdhomerun.com) and went to
    the page of my Tuner (it is a link of *HDHomeRun PRIME* on top).
- TV Tuner serves website on standard port 80, where you can do some
    configuration and diagnostics (HDHomeRun page from previous step should
    bring you there). First link allows you to detect channels, do it. In my
    case I saw most of channels in my subscription (basic subscription).
- On the main page of my tuner I saw *Card Validation none*.
    To validate the card you need to call Comcast. You
    can find phone number on your CableCARD (I used *877-405-2298*). Open page
    *CableCARD Menu* → *CableCARD(tm) Pairing*, this page has all information
    which you will be asked to provide, no need to get the CableCARD out of
    tuner.
- Run *Channel Lineup* → *Detect Channels* again to see that you get all the
    channels you payed for.

At this point you should be able to Watch HD TV from OS X or PC using
*HDHomeRun Viewer*.

## How to watch TV

I tried several things

- Official HDHomeRun View player. Works great.
- [VLC Player](https://www.videolan.org/vlc/). Open it, right click on
    *Universal Plug'n'Play* to *Enable* it
    and after that you should see list of Tuners, one of them will be
    *HDHomeRun* with list of channels. Just a note, if you have any other
    application working, like *JRiver MediaCenter* which is using Plug'n'Play
    discovery - for some reason VLC will not be able to enable Plug'n'Play. VLC
    Player allows to record any channels right while you are watching. I guess
    you can also schedule recording with cron.
- [Channels for AppleTV 4th gen](http://getchannels.com) - works great. Not
    free.

## How to record (DVR)

I tried few applications, obviously not all on the market.

- [mythTV](https://www.mythtv.org) - I am too lazy to set it up.
- [EyeTV](https://www.elgato.com/en/eyetv) - it does not work with PRIME, see
    [EyeTV 3 software does not support the HDHomeRun PRIME, EXTEND or
    EXPAND](https://help.elgato.com/customer/en/portal/articles/1360661-eyetv-3-software-does-not-support-the-hdhomerun-prime-extend-or-expand?b_id=360).
    I have read that some people used old version of *EyeTV* and it worked, but
    I did not want to pay for something, which I know will not be supported in
    the future.
- [JRiver MediaCenter](http://jriver.com) - isn't intuitive. I could not set it
    up, and because it had the same price as everything else I just gave up on
    it.
- [HDHomeRun DVR](https://www.silicondust.com/shop/) - still *Early Access*, a
    lot of issues, but I just hope that they will continue to work on it and
    get it done soon.

I ended up with HDHomeRun DVR, with just a hope that they are going to finish
it soon.

## HDHomeRun DVR Setup

This software does not have a lot of documentation, so it is hard to understand
how it actually works.

### Installation

- Purchase the license and follow the instructions.
- Download latest [available build from
    forums](https://www.silicondust.com/forum/viewforum.php?f=96). At this time
    install it and choose "DVR Recording" on device where you want to record
    TV. It can be not the same device where you want to watch these recordings.
    For example in my case I have it installed on Mac Mini with huge RAID and I
    watch recordings from other devices and never from this Mac Mini.
- On devices where you want to watch TV and Recordings you need to install
    [Kodi](http://kodi.tv). As I understood this is temporary solution to make
    a prototype, the final product will be standalone.
- Open Kodi and install *HDHomeRun add-on* in Videos (see [Kodi
    Client](https://www.silicondust.com/forum/viewtopic.php?f=96&t=20538)).

### DVR Configuration on OSX

If you have installed DVR on OSX there are few things I have learned about it:

- It creates user *_HDHomeRun:_HDHomeRun_* and executes this service under this
    user.
- Default location of DVR application and recordings is in `/Users/HDHomeRun/`.
- You can find daemon configuration in
    `/Library/LaunchDaemons/com.silicondust.dvr.plist`.
- It does not have a lot of configurations, but has one important, if you will
    open `/Users/HDHomeRun/hdhomerun.conf` you will find that you can change
    `RecordPath`. It will use this location to write
    logs and recordings. Make sure that user `_HDHomeRun:_HDHomeRun` has access
    to this new folder, best way to do that is to make `_HDHomeRun` an owner of
    this directory. To restart the service you can use `launchctl`, like

```
sudo launchctl stop com.silicondust.dvr
sudo launchctl start com.silicondust.dvr
```

- It writes everything in mpeg2 format. Quicktime could not read it. [VLC
    Player](https://www.videolan.org/vlc/) can. You can convert to the iOS/OSX
    compatible format using for example
    [Adapter](https://www.macroplant.com/adapter/)
