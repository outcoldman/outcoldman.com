---
layout: post
title: "Configuring Web Site on OS X Server with certificate from Let's encrypt"
categories: en
tags: [os x, os x server, let's encrypt, certificate, apache]
---

One of my home servers is a Mac mini where I host
[OS X Server](http://www.apple.com/osx/server/),
[SecuritySpy](http://www.bensoftware.com/securityspy/)
(highly recommend if you want to setup you own security system) and
[Plex](https://plex.tv). Few days ago I decided to do a very simple thing, setup
to web proxy from OS X Server to SecuritySpy web server.
I thought it will be a simple Apache configuration modification,
but actually a little bit more complicated.

My home router routes all web traffic to the OS X Server
(including http and https). OS X Server responses on my home domain *myexample.com*,
which provides access to standard OS X Server services (honestly don't use them), just
don't care about them. Using OS X Server I wanted also to setup *spy.myexample.com*,
which will proxy to the SecuritySpy web server. And of course to server requests
only with SSL.

## Setting up Let's encrypt certificates on OS X Server

You can install `letsencrypt` using [Homebrew](http://brew.sh)

```bash
brew install letsencrypt
```

Let's encrypt supports Apache out of box to automatically generate certificates,
but it did not work with apache server on my OS X, my guess because of the
complicated configurations of OS X Server.

Instead I used *manual* mode. But...

If you have OS X Server installed on your Mac - there is no way you can turn off
binding to the ports 80 and 443. But you need them to use letsecnrypt utility.
Actually you need to serve web requests on port 80 from outside.

You can workaround this. Just change port forwarding settings on your home router
to forwarder all calls on port 80 from outside to your OS X Server on port 1080.

Start terminal and use

```bash
sudo letsencrypt certonly --manual -d myexample.com -d www.myexample.com -d spy.myexample.com
```

As you can see I generate certificate for 3 domains.

Tool will show you something like

> NOTE: The IP of this machine will be publicly logged as having
> requested this certificate. If you're running certbot in manual mode
> on a machine that is not your server, please ensure you're okay with
> that.
>
> Are you OK with your IP being logged?

And some script about how you can manually start web server with python, similar to

```text
mkdir -p /tmp/certbot/public_html/.well-known/acme-challenge
cd /tmp/certbot/public_html
printf "%s" ZUyIBjB438BKscCNTE9a7MaaE6mANJ4mkE72PhFie27.gr_T0r2Vo85QG_WeF0EmMlcFC3kddVvTQqdE73IBgJK > .well-known/acme-challenge/ZUyIBjB438BKscCNTE9a7MaaE6mANJ4mkE72PhFie27
# run only once per server:
$(command -v python2 || command -v python2.7 || command -v python2.6) -c \
"import BaseHTTPServer, SimpleHTTPServer; \
s = BaseHTTPServer.HTTPServer(('', 80), SimpleHTTPServer.SimpleHTTPRequestHandler); \
s.serve_forever()"

Press ENTER to continue
```

Do first 3 steps from what letsecnrypt tol you 
and change port when you start web server to `1080` (port we used
on router)

```bash
$(command -v python2 || command -v python2.7 || command -v python2.6) -c \
"import BaseHTTPServer, SimpleHTTPServer; \
s = BaseHTTPServer.HTTPServer(('', 1080), SimpleHTTPServer.SimpleHTTPRequestHandler); \
s.serve_forever()"
```

You can also try that it actually works (use path from what letsencrypt generated for you)

```bash
curl http://myexample.com/.well-known/acme-challenge/ZUyIBjB438BKscCNTE9a7MaaE6mANJ4mkE72PhFie27
```

Should give you an answer with the key.

At this point you can go back to the terminal window where you launched `letsecnrypt`
and press enter. It will ask you to do the same for all other domains as well.

You don't have to restart python server, so for next domains just execute first 3 lines
to generate specific files.

After that let's encrypt will give you path where it saved certificates, similar to 
`/etc/letsencrypt/live/myexample.com`.

Change port back to the 80 on your home router and kill python server.

Now you can import certificate to the OS X Server. Just go to the Certificates page
in *Server.app* and use *Import a Certificate Identity* by pressing `+`.

## Settings up Web Applications in OS X Server

There are not a lot of documentation on this topic. And some of the discussions
are misleading to not the right solutions, like this one
[Reverse Proxy / ProxyPassReverse on Mountain Lion Server](https://discussions.apple.com/message/30085284#30085284).
Suggested solution does work, but only while you are not modifying anything in
the OS X Server management console or have not upgraded it.

To find the right way you need to read `man webappctl.plist`:

> Web applications managed with webappctl(8) are defined by plists placed in /Library/Server/Web/Config/apache2/webapps/.

> In this context, a webapp is a set of Apache configuration directives and related behaviors, usually managing a set of processes listening on specific TCP ports responding to
> HTTP requests, routed through the web service via reverse proxy mechanism. This mechanism is used for webapps bundled with Server app but can also be used for third-party or
> locally-developed web apps.  When certain special keys are present the webapp.plist, those webapps can be enabled/disabled via Server app's Web panel in as well as with the
> standard webappctl(8) command.

As simple as that, go to the suggested folder `/Library/Server/Web/Config/apache2/webapps/`,
where you will find `com.example.mywebapp.plist`. I created a copy of this file
with name `com.mydomain.securityspy.plist` and changed content to

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict> 
    <key>name</key>
    <string>com.mydomain.securityspy</string>
    <key>displayName</key>      <!-- Name shown in Server app -->
    <string>Security Spy</string>
    <key>requiredModuleNames</key>
    <array>
        <!-- Apache plugin modules are enabled when webapp is started -->
        <string>proxy_module</string>
    </array>
    <key>proxies</key>
    <dict>
        <key>/</key>
        <dict>
            <key>keysAndValues</key>
            <string></string>
            <key>path</key>
            <string>/</string>
            <key>urls</key>
            <array>
                <string>http://localhost:8000/</string>
            </array>
        </dict>
    </dict>
    <key>installationIndicatorFilePath</key>
    <string>/Applications/SecuritySpy.app/Contents/PkgInfo</string>
</dict>
</plist>
```

This is the minimum which required for me to make this Web application to work.
Just a note, that my Security Spy Web server is running on the same server on port
`8000`, so this is why I proxy everything to `http://localhost:8000/`.
And another important note - `installationIndicatorFilePath` is required, if the file
specified for this key does not exist - you will not see this web application
in **Server.app**.

Start web application with command

```
webappctl start com.mydomain.securityspy
```

If it says that it cannot start, just open *Console.app*, it should show you
what was the problem.

After that open *Server.app* and go to the *Websites* page.  Make sure that it is
running. Add new website by pressing `+`.

[![OS X Server add WebSite]({{ site.url }}/library/2016/05/osxserver_add_website.png)]({{ site.url }}/library/2016/05/osxserver_add_website.png)

And in advanced settings choose your web application from the list.

[![OS X Server WebSite Advanced Settings]({{ site.url }}/library/2016/05/osxserver_add_website.png)]({{ site.url }}/library/2016/05/osxserver_website_advanced_settings.png)

After that you should be able to have access to your website using *https://spy.myexample.com*.