#!bin/bash
username=$1
cpu=$2
gpu=$3

#Enable community repo
setup-apkrepos -cf
#Setup admin user
adduser $username wheel
apk add doas
echo "permit persist :wheel" >> /etc/doas.d/doas.conf
chmod o-rx /home/$username
#Configure for desktop use
setup-devd udev
apk add dbus
rc-update add dbus
rc-service dbus start
apk add mesa-dri-gallium mesa-va-gallium
if [$gpu = intel]; then
	apk add intel-media-driver
elif [$gpu = amd]; then
	apk add amd-media-driver
elif [$gpu = nvidia]; then
	apk add nvidia-media-driver
fi 
setup-desktop sway
#Add tuigreet display manager and configure it
apk add greetd greetd-tuigreet
cp sway-run /usr/local/bin/sway-run
chmod +x /usr/local/bin/sway-run
sed -i 's/agreety/tuigreet -t -r --asterisks -g \'who ARE you?\'/' /etc/greetd/config.toml
sed -i 's/\/bin\/sh/sway-run/' /etc/greetd/config.toml
rc-update add greetd
rc-service greetd start
mkdir -p /home/$username/.config/sway
cp config /home/$username/.config/sway/
#Setup bluetooth
apk add bluez
modprobe btusb
adduser $username lp
rc-service bluetooth start
rc-update add bluetooth default
#Add fonts
apk add font-terminus font-inconsolata font-dejavu font-noto font-noto-cjk font-awesome font-noto-extra
#Add microcode
if [$cpu = intel]; then
	apk add intel-ucode
elif [$cpu = amd]; then
	apk add amd-ucode
fi
#Setup printers
apk add cups cups-pdf cups-filters
rc-update add cupsd boot
#Setup Firewall
apk add ip6tables ufw
ufw default deny incoming
ufw default deny outgoing
ufw limit SSH         # open SSH port and protect against brute-force login attacks
ufw allow out 123/udp # allow outgoing NTP (Network Time Protocol)

# The following instructions will allow apk to work:
ufw allow out DNS     # allow outgoing DNS
ufw allow out 80/tcp  # allow outgoing HTTP traffic
ufw enable
rc-update add ufw
#Setup man pages
apk add mandoc mandoc-apropos
#Installs docs for all installed packages with man pages
apk add docs
#Setup podman and distrobox
apk add podman distrobox
modprobe tun
echo tun >>/etc/modules
echo $username:100000:65536 >/etc/subuid
echo $username:100000:65536 >/etc/subgid
echo "Remember to set root as shared for distrobox to work!"
echo "Remember to configure sway for your specific system"
#Install other packages
apk add git
