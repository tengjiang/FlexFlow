#! /bin/bash

# disable nouveau
# could see if lsmod | grep nouveau produces anything first, but in the context of cloudlab, we do not need to do this.
sudo touch /etc/modprobe.d/blacklist-nouveau.conf
sudo echo "blacklist nouveau" > /etc/modprobe.d/blacklist-nouveau.conf
sudo echo "options nouveau modeset=0" >> /etc/modprobe.d/blacklist-nouveau.conf
sudo update-initramfs -u
sudo reboot