#!bin/bash
username=$1
displayname=$2
if [ "$username" = '' ]; then
        echo "Username not set. Quitting!"
        exit 1
fi
if [ "$displayname" = '' ]; then
        echo "displayname not set. Setting to $username !"
        exit 1
fi
#Setup admin user
echo "Setting up admin account!"
setup-user -a -f $displayname $username
#Configure for desktop use
rc-update add dbus
rc-service dbus start
#Configure tuigreet 
cp sway-run /usr/local/bin/sway-run
chmod +x /usr/local/bin/sway-run
mkdir /etc/greetd
touch /etc/greetd/config.toml
sed -i "s/agreety/tuigreet -t -r --asterisks -g 'who ARE you?' --power-shutdown 'doas poweroff' --power-reboot 'doas reboot'/" /etc/greetd/config.toml
sed -i "s/\/bin\/sh/sway-run/" /etc/greetd/config.toml
rc-update add greetd
#Configure Sway with a minimal viable config
mkdir -p /home/$username/.config/sway
cp config /home/$username/.config/sway/
chown -R /home/$username/.config $username
#Setup bluetooth
modprobe btusb
adduser $username lp
rc-service bluetooth start
rc-update add bluetooth default
#Setup printers
rc-update add cupsd boot
#Setup Firewall for ssh access, NTP HTTP and DNS 
ufw default deny incoming
ufw default deny outgoing
ufw limit SSH         # open SSH port and protect against brute-force login attacks
ufw allow out 123/udp # allow outgoing NTP (Network Time Protocol)

# The following instructions will allow apk to work:
ufw allow out DNS     # allow outgoing DNS
ufw allow out 80/tcp  # allow outgoing HTTP traffic
ufw enable
rc-update add ufw
#Configure distrobox and podman for rootless use 
rc-update add cgroups
rc-service cgroups start
modprobe tun
echo tun >>/etc/modules
echo $username:100000:65536 >/etc/subuid
echo $username:100000:65536 >/etc/subgid
echo "Remember to set root as shared for distrobox to work!"
cp mount-rshared.start /etc/local.d/
chmod +x /etc/local.d/mount-rshared.start
rc-update add local default
rc-service local start
#Change user and root shells to bash
chsh -s /bin/bash "$username"
chsh -s /bin/bash root
