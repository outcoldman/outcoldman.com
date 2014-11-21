---
layout: post
title: "Ubuntu as a home server. Part 2. Open VPN."
date: 2014-10-21 00:00:00 -00:08:00
categories: en
tags: [Ubuntu, OpenVPN, Tunnelblick, easy-rsa]
---

1. [Dynamic DNS]({{ site.url }}/en/archive/2014/10/14/ubuntu-as-a-home-server-part-1-dynamic-dns/).
1. [OpenVPN]({{ site.url }}/en/archive/2014/10/21/ubuntu-as-a-home-server-part-2-openvpn/).
1. [AFP Server (for OS X)]({{ site.url }}/en/archive/2014/11/09/ubuntu-as-home-server-part-3-afp-server/).
1. [SMB server (for Windows and Linux)]({{ site.url }}/en/archive/2014/11/20/ubuntu-as-a-home-server-part-4-smb-server/).
1. Reliability (Backups).
1. Other tricks.

In part 1 we configured DNS name for our home server, which we can use outside of our network to find it. After that you have an option to make some ports available for public access, like Remote Desktop, ssh and VNC server and just protect these services by password. This solution is not very secure, because somebody can attack you in two different ways: [brute-force](http://en.wikipedia.org/wiki/Brute-force_attack) your password or use [Man-in-the-middle](http://en.wikipedia.org/wiki/Man-in-the-middle_attack) attack. You probably think that because you are not so important that nobody has a reason to attack you. This is not true, illegal botnets always are looking for new members. 

## OpenVPN

So what you can do for that? You can use [OpenVPN](https://openvpn.net). It protects you from brute-force attach by just not accepting clients with invalid certificates and it does not allow to perform Man-in-the-middle attack, because your client always will verify server certificate (just make sure to keep your keys in safe place).

The other reason to use OpenVPN is to protect yourself when you use public WiFi networks from [Session hijacking](http://en.wikipedia.org/wiki/Session_hijacking). To do that you can connect to your own home server, and transfer all network traffic to your home server using encrypted channel, so nobody on this public WiFi network will see what you are doing, they will only see that you are connected to home server. 

### Prepare OpenVPN server

On Ubuntu you can switch to root session, because these steps will require to perform a lot of root commands, you can do it by

```bash
$ sudo -s
```

You can read detailed explanation of all steps on [Ubuntu Server Guide → VPN](https://help.ubuntu.com/lts/serverguide/openvpn.html), 

```bash
# install openvpn and easy-rsa to generate certificates and keys
root $ apt-get install openvpn easy-rsa
# create a folder for keys and certificates /etc/openvpn/easy-rsa/
root $ mkdir /etc/openvpn/easy-rsa/
# copy examples of configuration files for easy-rsa
root $ cp -r /usr/share/easy-rsa/* /etc/openvpn/easy-rsa/
# edit certificate authority properties (this is not very important)
# just something you will see in certificate definitions
# so don't spend to much time on what to specify in these fields
root $ vim /etc/openvpn/easy-rsa/vars
```

In file `vars` you just need to adjust next lines

```bash
export KEY_COUNTRY="US"
export KEY_PROVINCE="WA"
export KEY_CITY="Settle"
export KEY_ORG="example"
export KEY_EMAIL="vpn@example.com"
export KEY_OU="vpn.example.com"
```

After that create your Certificate Authority

```bash
root $ cd /etc/openvpn/easy-rsa/
# load all specified by you settings in Environment Variables
root $ source vars
root $ ./clean-all
# generate your master certificate and key, 
# this will generate a certificate of your Certificate Authority
# all other certificates will depend on this one
root $ ./build-ca
```

#### Generate server certificate

Every time when you will need to generate certificates you need to be sure that you did `source vars`. If you still in the same session as we started, just continue to execute commands

```bash
# generate server certificate 
# this will guarantee for clients that this is your home server
# all parameters will be defined from vars file, so just accept all of
# them and at the end say yes for ""Sign the certificate?" and "Commit?"
root $ ./build-key-server vpn.example.com
# Generate Diffie Hellman parameters
# This one is used by OpenVPN for keys exchange
# see http://en.wikipedia.org/wiki/Diffie–Hellman_key_exchange
root $ ./build-dh
```

All your keys and certificates will be generated in `/etc/openvpn/keys` folder. Keep it secure!

For the server you will need to use 4 files which you should copy to folder `/etc/openvpn/` (this is where OpenVPN is looking for config files by default)

```bash
root $ cd /etc/openvpn/keys
root $ cp vpn.example.com.crt vpn.example.com.key ca.crt dh2048.pem /etc/openvpn/
```

#### Generate client certificates

After that you can generate as many client certificates as you need. Better to use one certificate per client, so if it will be compromised you can easily [revoke](https://openvpn.net/index.php/open-source/documentation/howto.html#revoke) it.

You can come back to this step any time when you need to generate client certificates, just don't forget to do `source vars` before that

```bash
# don't need to do these 2 steps if you still in the same session
root $ cd /etc/openvpn/easy-rsa/
root $ source vars
# generate client key and certificate (name myphone should be unique)
# you can keep all settings by default
root $ ./build-key myphone
```

For client you only need to use next files:

```bash
/etc/openvpn/easy-rsa/keys/ca.crt
/etc/openvpn/easy-rsa/keys/myphone.crt
/etc/openvpn/easy-rsa/keys/myphone.key
```

You will need to transfer these files with configuration later to your devices.

### Setup OpenVPN server 

In this example I'm going to setup two VPN servers, because in most cases I need to just get access to the home network without redirecting my Internet thought VPN. So one VPN network will allow me to redirect Internet traffic and other one will allow me to get access to home network. And yes, you can use both at the same time.

#### ... to safely browse Internet on public networks

This one is very simple to do, just copy sample configuration files and do some adjustments

```bash
root $ cp /usr/share/doc/openvpn/examples/sample-config-files/server.conf.gz /etc/openvpn/
root $ gzip -d /etc/openvpn/server.conf.gz
```

Save `server.conf` as a backup file and rename it to something more meaningful for you

```bash
root $ cp /etc/openvpn/server.conf /etc/openvpn/server.conf.bak
root $ mv /etc/openvpn/server.conf /etc/openvpn/server-internet.conf
```

Edit `/etc/openvpn/server-internet.conf` file

```bash
root $ vim server-internet.conf
```

Most important settings which we want to modify

```bash
# Using 80 or 443 ports is a good idea if you don't 
# need to host any websites on your home server.
# Some public WiFi can block not HTTP/HTTPS ports, so
# using 80 or 443 will guarantee connection to VPN
port 80

# Take these files from /etc/openvpn/easy-rsa/keys/
ca ca.crt
cert vpn.example.com.crt
key vpn.example.com.key

# In example file I had dh1024.pem but build-dh generates dh2048.pem 
# by default, so don't forget to update
dh dh2048.pem

# Configure range of IP addresses for this VPN network
server 10.8.0.0 255.255.255.0

# Configuration for clients to direct all Internet traffic through this VPN
push "redirect-gateway def1 bypass-dhcp"

# I use Google DNS servers
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 8.8.4.4"
```

All other settings you can keep by default or modify after reading manual.

Restart `openvpn` service to load this configuration

```bash
root $ service openvpn restart
```

You can verify that you now have `tun0` network interface

```
root $ ifconfig
```

The last step is to configure IP forwarding on Ubuntu

First we need to enable [IP forwarding](http://en.wikipedia.org/wiki/IP_forwarding) by 

```bash
root $ sysctl -w net.ipv4.ip_forward=1
```

To persist this setting between restarts you also need to edit `/etc/sysctl.conf` and uncomment/add this line 

```bash
net.ipv4.ip_forward=1
```

After that add couple of rules to [iptables](https://help.ubuntu.com/community/IptablesHowTo), don't forget to update your network mask `10.8.0.0/24` and Ethernet interface `eth0` (probably you will have `eth0` by default)

```bash
root & iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE
root & iptables -A FORWARD -p tcp -s 10.8.0.0/24 -d 0.0.0.0/0 -j ACCEPT
```

To [persist these settings](https://help.ubuntu.com/community/IptablesHowTo#Saving_iptables) we need to save them to file

```bash
root $ sh -c "iptables-save > /etc/iptables.rules"
```

And auto load them on boot, edit `/etc/network/interfaces` file

```bash
root $ vim /etc/network/interfaces
```

To include line which will load `iptables.rules`

```bash
auto eth0
iface eth0 inet dhcp
  pre-up iptables-restore < /etc/iptables.rules
```

Server is ready for VPN. But before configuring clients let's add one more VPN configuration, which will allow us to connect to home network.

#### ... to get access to home network

Let's setup second configuration

```bash
root $ cp /etc/openvpn/server.conf.bak /etc/openvpn/server-home.conf
```

Where we will specify

```bash
# For Internet we used port 80, for this VPN 443
port 443

# The same server certificates
ca ca.crt
cert vpn.outcoldman.com.crt
key vpn.outcoldman.com.key

# Update DH file, because we used 2048 bit key
dh dh2048.pem

# Specify which subnet we want to use (it should be different from above)
server 10.9.0.0 255.255.255.0

# Push route for home network
# This setting depends on your own home settings, verify them with 
# `ifconfig eth0`, in most cases if your home IP address is 192.168.1.x 
# this setting should work for you  
push "route 192.168.1.0 255.255.255.0"

# Because we also want to be able to reach devices at home by name, let's
# push DNS settings
# Again first DNS record depends on your home configuration. 
# This is a gateway IP address (usually your home router)
# Second record here appends .home domain when it is not specified
# Without this setting OpenVPN can add some other weird names like `example.openvpn`
push "dhcp-option DNS 192.168.1.1"
push "dhcp-option DOMAIN home"

# this setting tells what is doing
client-to-client
```

Restart `openvpn` service

```bash
root $ service openvpn restart
```

Verify that new interface created (probably `tun1`)

```bash
root $ ifconfig
```

After that we need to configure `iptables` again (verify network interface names `tun1` and `eth0`, also VPN subnet and home subnet)

```bash
# To allow traffic initialized from VPN to access LAN
root $ iptables -I FORWARD -i tun1 -o eth0  -s 10.9.0.0/24 -d 192.168.1.0/24 -m conntrack --ctstate NEW -j ACCEPT
# Allow to pass traffic back and forth
root $ iptables -I FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
```

And don't forget to [persist `ipconfig` settings](https://help.ubuntu.com/community/IptablesHowTo#Saving_iptables). If your configured previous VPN than just save it again

```bash
root $ sh -c "iptables-save > /etc/iptables.rules"
```

No need to modify `/etc/network/interfaces` again.

Ok, so clients know how to communicate to devices on your home network, but devices on your home network don't know how to get back to connected to VPN clients. To do that you will need to update Routing Tables on your devices, the easiest way to do that will be to add them to your home router (if it supports that). 

This is how it looks in my case, where `10.111.0.0` - subnet of my VPN network (`10.9.0.0` should be in our example) and `192.168.1.10` - address of my Ubuntu Server (OpenVPN server) in my home network

[![Routing Table]({{ site.url }}/library/2014/10/router.routing_table.png)]({{ site.url }}/library/2014/10/router.routing_table.png)

### Setup OpenVPN client

Does not matter which client you are going to setup you always need 4 files

```bash
config.conf
ca.crt
myphone.crt
myphone.key
```

#### Linux client

Install openvpn

```bash
$ sudo apt-get install openvpn
```
Copy example configuration

```bash
$ cp /usr/share/doc/openvpn/examples/sample-config-files/client.conf /etc/openvpn/
```

Download `ca.crt`, `mylinuxclient.crt` and `mylinuxclient.key` from OpenVPN server (`mylinuxclient.*` files are generated with `./build-key mylinuxclient`) and copy them in `/etc/openvpn/`.

Adjust `client.conf`

```bash
$ sudo vim /etc/openvpn/client.conf
```

Most important settings are

```bash
# remote server name and port
remote vpn.example.com 80
ca ca.crt
cert mylinuxclient.crt
key mylinuxclient.key
```

Restart `openvpn` service

```bash
$ sudo service openvpn restart
```

Verify that new network interface `tun0` has been created

```bash
# ifconfig
```

Verify that everything is fine in `syslog`

```bash
$ grep vpn /var/log/syslog | tail -50
```

If you connected to VPN which forwards Internet traffic through VPN server check that IP address has been changed

```bash
$ curl http://ifconfig.me/ips
```

#### OS X Client

The best client as I know is [Tunnelblick](https://code.google.com/p/tunnelblick/). [Download it, install it](https://code.google.com/p/tunnelblick/wiki/UsingTunnelblick) and start it.

Create new folder somewhere, for example on desktop

```bash
$ mkdir ~/Desktop/vpn
```

Download `ca.crt`, `myosxclient.crt` and `myosxclient.key` from OpenVPN server (`mylinuxclient.*` files are generated with `./build-key myosxclient`) and copy them in `~/Desktop/vpn`.

Copy sample configuration file 

```bash
$ cp /Applications/Tunnelblick.app/Contents/Resources/openvpn.conf ~/Desktop/vpn 
```

Adjust it 

```bash
remote vpn.example.com 80
ca ca.crt
cert myosxclient.crt
key myosxclient.key
```

Rename folder to `vpn.tblk` and open it

```
$ mv ~/Desktop/vpn ~/Desktop/vpn.tblk
$ open ~/Desktop/vpn.tblk
```

Last command will open it and add it to Tunnelblick.

#### iOS Client

First of all install [OpenVPN](https://itunes.apple.com/us/app/openvpn-connect/id590379981?mt=8) on your device.

Do everything as you did for `OS X Client`, but instead of renaming and opening this folder in Tunnelblick you need to copy this folder on your iOS device. I used iTunes for that: go to the tab `Apps`, section `File Sharing`, select OpenVPN and add all 4 files to this application. Do sync and after that in OpenVPN application on your iOS device you will see something like `1 new OpenVPN profile is available for import`

#### Android Client

Install [OpenVPN](https://play.google.com/store/apps/details?id=net.openvpn.openvpn&hl=en) on your device. Again, do the same settings as for `OS X Client`, but instead of renaming and opening this folder in Tunnelblick you need to copy this folder on your Android device.

Use [Android File Transfer](https://www.android.com/filetransfer/) tool to copy these files on your device and do import.

### Links

* [Ubuntu Server Guide → VPN](https://help.ubuntu.com/lts/serverguide/openvpn.html)
* [OpenVPN → Revoking Certificates](https://openvpn.net/index.php/open-source/documentation/howto.html#revoke)
* [OpenVPN → Bridging vs. routing](https://community.openvpn.net/openvpn/wiki/BridgingAndRouting)
* [Ubuntu Community Help Wiki → Iptables HowTo](https://help.ubuntu.com/community/IptablesHowTo)
