cpu=$1
gpu=$2
#Dbus
setup-devd udev
apk add dbus
#Login Greeter
apk add greetd greetd-tuigreet
#Hardware Enablement
apk add mesa-dri-gallium mesa-va-gallium
if [ "$gpu" = 'intel' ]; then
	echo "Installing intel drivers!"
	apk add intel-media-driver
elif [ "$gpu" = 'amd' ]; then
	echo "Installing amd drivers!"
	apk add linux-firmware-amdgpu
elif [ "$gpu" = 'nvidia' ]; then
	echo "Installing nvidia drivers!"
#Raspberry pi and over devices have own drivers, nothing to do here
fi 
#Add microcode
if [ "$cpu" = 'intel' ]; then
	echo "Installing intel microcode!"
	apk add intel-ucode
elif [ "$cpu" = 'amd' ]; then
	echo "Installing amd microcode!"
	apk add amd-ucode
fi
#Window Manager 
setup-desktop sway
#Bluetooth
apk add bluez 
#Fonts
apk add font-terminus font-inconsolata font-dejavu font-noto font-noto-cjk font-awesome font-noto-extra
#Printers
apk add cups
#Firewall
apk add ip6tables font-awesome
#Man pages 
apk add mandoc mandoc-apropos
#Podman and distrobox
apk add podman distrobox
#Bash
apk add bash shadow 
#Terminal
apk add foot
