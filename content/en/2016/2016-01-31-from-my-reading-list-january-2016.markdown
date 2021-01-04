---
categories: en
date: "2016-01-31T00:00:00Z"
draft: true
tags:
- appletv
- c
- datasets
- arduino
- raspberry pi
title: From my reading list January 2016. Arduino / RaspberryPi Special.
slug: "from-my-reading-list-january-2016"
---

- [The Open Guide to Equity
    Compensation](https://github.com/jlevy/og-equity-compensation). Right in
    time before filing taxes for 2015.
- [How to C in 2016](https://matt.sh/howto-c). Good refreshing article.
- [Aerial Apple TV screen saver for Windows](https://github.com/cDima/Aerial/).
    Apple TV gen 4 has nice looking screen savers. With this tool you can
    install them on your Mac. You can find also link to Windows version.
- [Awesome Public
    Datasets](https://github.com/caesar0301/awesome-public-datasets).  Most of
    the data sets listed are free, however, some are not.

## How to get start with Raspberry Pi / Arduino

This month I spent a lot of time playing with Arduino and Raspberry Pi. So
there are some links and answered answered.

### Raspberry Pi

I purchased my Raspberry Pi 2 Model B from Amazon, a lot of additional stuff
from GearBest and Adafruit.

- Do you need to buy a screen with Raspberry Pi? Not really. If you don't need
    it. To get started you can use
    [SSH](https://www.raspberrypi.org/documentation/remote-access/ssh/README.md) and [VNC](https://www.raspberrypi.org/documentation/remote-access/vnc/README.md).
    SSH Server is enabled by default in Raspbian (default operation system for Raspberry Pi). Using SSH
    you can install VNC server. Default username / password are `pi` and
    `raspberry`.
- Don't be lazy, read
    [documentation](https://www.raspberrypi.org/documentation/). Especially
    remember that you need to run `sudo raspi-config` to get it configured and
    use whole SD card.
- You probably don't want to use slow SD cards, check [SD card performance
    table](http://elinux.org/RPi_SD_cards#SD_card_performance).
- You will see a lot of manuals where PiStore is mentioned. It is not available
    anymore.
- There are a lot of platforms available on Raspberry Pi, like node, python,
    python3, java, ruby. Also you can find how to install Docker and Mono.
- To get some ideas read MagPi magazine, you can download all issues from
    official site, like (change `42` to the latest issue)

```bash
curl https://www.raspberrypi.org/magpi-issues/MagPi\[01-42\].pdf -O --retry 999
--retry-max-time 0 -C -
```

- Read [Project Book](https://www.raspberrypi.org/magpi/issues/projects-1/).
    Download it using `curl`

```bash
curl -L  -O https://raspberrypi.org/magpi-issues/Projects_Book_v1.pdf --retry
999 --retry-max-time 0 -C -
```

- [Pi Weekly](http://piweekly.net).
- [Awesome Raspberry Pi](https://github.com/blackout314/awesome-raspberry-pi).
    Interesting projects, including building own Thermostat.
- [Opening a garage door from the
    Internet](http://dhowdy.blogspot.co.uk/2015/10/opening-garage-door-from-internet.html).

### Arduino

Because Arduino has open-sources their hardware - you can purchase exactly the
same hardware but cheaper. For example I purchased SunFounder set.

- [Official site](https://www.arduino.cc).
- [Fritzing](http://fritzing.org/home/). Software for document your prototypes.
- [Programming Arduino Book](http://arduinobook.com/programming-arduino-ed1/).
    Nothing special in this book, just came to my attention, got it from
    somewhere on discount. Just good introduction. If you know C and can read
    official Arduino documentation - you do not need this book.

### Additional

- [EnerGenie Programmable power strip with LAN
    interface](http://energenie.com/item.aspx?id=7557&lang=en). Have not tried
    it, but can be used with whole home automation.
- [HomeKit support for the impatient](https://github.com/nfarina/homebridge). I
    guess you can combine it with Raspberry Pi to build something for your iOS
    devices.
- [Gearbest](http://www.gearbest.com). Can find a lot of sensors, Arduino and
    other interesting stuff.
- [DealExtreme](http://www.dx.com). The same.
- [Banggood](http://www.banggood.com). The same.
- [Adafruit](https://www.adafruit.com). Nice shop when you cannot find
    something on Amazon or in one of the online shops above. This shop also has
    a lot of interesting instructions and articles.
