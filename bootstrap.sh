#!/bin/bash

# check for root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root" 1>&2
    exit 1
fi

PWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# update software
echo "== Updating software"
apt-get update
apt-get dist-upgrade -y

# install tor and related packages
echo "== Installing Tor and related packages"
apt-get install -y tor tor-arm tor-geoipdb

# configure tor
cp $PWD/etc/tor/torrc /etc/tor/torrc

# configure automatic updates
echo "== Configuring unattended upgrades"
apt-get install -y unattended-upgrades apt-listchanges
cp $PWD/etc/apt/apt.conf.d/20auto-upgrades /etc/apt/apt.conf.d/20auto-upgrades
systemctl restart unattended-upgrades

# configure upnpc
echo "== Configuring port forwarding"
apt-get install -y miniupnpc
cat <<EOF >/usr/local/bin/update-upnp-forwards
#!/bin/bash
upnpc -e 'Forward OrPort'  -r 443 TCP  >/dev/null
upnpc -e 'Forward DirPOrt' -r 8080 TCP >/dev/null
EOF
chmod a+x /usr/local/bin/update-upnp-forwards


cp $PWD/etc/systemd/system/upnp-forward-ports.service /etc/systemd/system/
cp $PWD/etc/systemd/system/upnp-forward-ports.timer /etc/systemd/system/

systemctl daemon-reload
systemctl start upnp-forward-ports.timer

# final instructions
echo "== Edit /etc/tor/torrc"
echo "  - Set Address, Nickname, Contact Info, and MyFamily for your Tor relay"
echo "  - Check your Bandwidth numbers: you probably want half of your residential upload speed"
echo "  - Optional: limit the amount of data transferred by your Tor relay (to avoid additional hosting costs)"
echo "    - Uncomment the lines beginning with '#AccountingMax' and '#AccountingStart'"
echo ""
echo "== REBOOT THIS SERVER"
