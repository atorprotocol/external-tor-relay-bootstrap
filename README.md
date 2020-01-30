tor-relay-bootstrap-rpi
=======================

This is a script to bootstrap a Raspberry PI to be a set-and-forget Tor relay.
It assumes it will be running at home behind a residential router that
supports UPNP (most of them do).

The script should be used with Raspbian Stretch Lite (tested with 2018-04-18
release).

tor-relay-bootstrap does this:

* Upgrades all the software on the system
* Installs and configures Tor to be a relay (but still requires you to manually
  edit torrc to set Nickname, ContactInfo, etc. for this relay)
* Configures automatic updates
* Tells your residential router to forward the necessary ports to reach the Tor relay
* Gives instructions on what the sysadmin needs to manually do at the end

To use it, boot up your raspberry PI, login as pi user, then:

```sh
sudo apt-get install -y git
git clone https://github.com/mricon/tor-relay-bootstrap-rpi.git
cd tor-relay-bootstrap-rpi
sudo ./bootstrap.sh
```

Once it is done, you can disconnect it from keyboard/monitor, plug it into a
free Ethernet port on your router, attach the rpi power cable to some USB port
(there's probably one on the router you can use), and pretty much forget about
it.

## Adjusting the bandwidth limits

You want to set Tor bandwidth limit to be about half of your residential
upload max. Here's how to calculate it:

First, find out your upload max:
https://www.google.com/search?q=speed+test

Click "Run Speed Test" and wait for your upload numbers. Take the "Mbps
upload" number and multiply it by 128 (we divide by 8 and multiply by 1024).
E.g. if you got 21.5 Mbps, your maximum upload is 21.5*128 = 2752 KBytes.

You should set your bandwidth limit to about half of that, and burst to close
to the max (unless you're feeling generous):

```
RelayBandwidthRate 1300 KBytes
RelayBandwidthBurst 2600 KBytes
```

Remember to `systemctl restart tor@default` after making any changes to torrc.

## Making sure it's working by watching pretty graphs

If you want to make sure everything is working, as user pi run:

```sh
sudo -u debian-tor nyx
```

On older versions the command is:

```sh
sudo -u debian-tor arm
```

It will take a bit to start, but eventually will show pretty usage graphs (or
errors that will help you troubleshoot if something is not working).
