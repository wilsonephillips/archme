#!/usr/bin/env bash
#github-action genshdoc
echo -ne "
------------------------------------------------------
   █████╗ ██████╗  ██████╗██╗  ██╗ ██████╗  ██████╗
  ██╔══██╗██╔══██╗██╔════╝██║  ██║██╔██╔██╗██╔════╝
  ███████║██████╔╝██║     ███████║██║██║██║██████╗ 
  ██╔══██║██╔══██╗██║     ██╔══██║██║██║██║██╔═══╝ 
  ██║  ██║██║  ██║╚██████╗██║  ██║██║██║██║╚██████╗
  ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═╝╚═╝╚═╝ ╚═════╝
------------------------------------------------------
             Automated Arch Linux Installer
------------------------------------------------------

            Final Setup and Configurations
         GRUB EFI Bootloader Install & Check
------------------------------------------------------
"
# Let's configure the ZRAM. You can edit it to suit you later in the .conf file.

touch /etc/systemd/zram-generator.conf
echo "[zram0]" > /etc/systemd/zram-generator.conf
echo "zram-size = min(ram, 2048)" >> /etc/systemd/zram-generator.conf
echo "mount-point = /var/compressed" >> /etc/systemd/zram-generator.conf

touch /etc/sysctl.d/99-swappiness.conf
echo "vm.swappiness=10" /etc/sysctl.d/99-swappiness.conf

# Let's setup Grub.

source ${HOME}/archme/configs/setup.conf

if [[ -d "/sys/firmware/efi" ]]; then
    grub-install --efi-directory=/boot ${DISK}
fi

echo -ne "
------------------------------------------------------
   █████╗ ██████╗  ██████╗██╗  ██╗ ██████╗  ██████╗
  ██╔══██╗██╔══██╗██╔════╝██║  ██║██╔██╔██╗██╔════╝
  ███████║██████╔╝██║     ███████║██║██║██║██████╗ 
  ██╔══██║██╔══██╗██║     ██╔══██║██║██║██║██╔═══╝ 
  ██║  ██║██║  ██║╚██████╗██║  ██║██║██║██║╚██████╗
  ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═╝╚═╝╚═╝ ╚═════╝
------------------------------------------------------
            Automated Arch Linux Installer
------------------------------------------------------
               Creating Grub Boot Menu
------------------------------------------------------
"
# set kernel parameter for decrypting the drive
if [[ "${FS}" == "luks" ]]; then
sed -i "s%GRUB_CMDLINE_LINUX_DEFAULT=\"%GRUB_CMDLINE_LINUX_DEFAULT=\"cryptdevice=UUID=${ENCRYPTED_PARTITION_UUID}:ROOT root=/dev/mapper/ROOT %g" /etc/default/grub
fi

echo -e "Backing up Grub config..."
cp -an /etc/default/grub /etc/default/grub.bak
echo -e "Updating grub..."
grub-mkconfig -o /boot/grub/grub.cfg
echo -e "All set!"

echo -ne "
------------------------------------------------------
   █████╗ ██████╗  ██████╗██╗  ██╗ ██████╗  ██████╗
  ██╔══██╗██╔══██╗██╔════╝██║  ██║██╔██╔██╗██╔════╝
  ███████║██████╔╝██║     ███████║██║██║██║██████╗ 
  ██╔══██║██╔══██╗██║     ██╔══██║██║██║██║██╔═══╝ 
  ██║  ██║██║  ██║╚██████╗██║  ██║██║██║██║╚██████╗
  ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═╝╚═╝╚═╝ ╚═════╝
------------------------------------------------------
            Automated Arch Linux Installer
------------------------------------------------------
     Enabling (and Theming) Login Display Manager
------------------------------------------------------
"
if [[ ${DESKTOP_ENV} == "kde" ]]; then
  systemctl enable sddm.service

elif [[ "${DESKTOP_ENV}" == "gnome" ]]; then
  systemctl enable gdm.service

elif [[ "${DESKTOP_ENV}" == "lxde" ]]; then
  systemctl enable lxdm.service

elif [[ "${DESKTOP_ENV}" == "openbox" ]]; then
  systemctl enable lightdm.service

else
  if [[ ! "${DESKTOP_ENV}" == "server"  ]]; then
  sudo pacman -S --noconfirm --needed lightdm lightdm-gtk-greeter
  systemctl enable lightdm.service
  fi
fi

echo -ne "
------------------------------------------------------
   █████╗ ██████╗  ██████╗██╗  ██╗ ██████╗  ██████╗
  ██╔══██╗██╔══██╗██╔════╝██║  ██║██╔██╔██╗██╔════╝
  ███████║██████╔╝██║     ███████║██║██║██║██████╗ 
  ██╔══██║██╔══██╗██║     ██╔══██║██║██║██║██╔═══╝ 
  ██║  ██║██║  ██║╚██████╗██║  ██║██║██║██║╚██████╗
  ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═╝╚═╝╚═╝ ╚═════╝
------------------------------------------------------
             Automated Arch Linux Installer
------------------------------------------------------

              Enabling Essential Services
------------------------------------------------------
"
systemctl enable cups.service
echo "  Cups enabled"
ntpd -qg
systemctl enable ntpd.service
echo "  NTP enabled"
systemctl disable dhcpcd.service
echo "  DHCP disabled"
systemctl stop dhcpcd.service
echo "  DHCP stopped"
systemctl enable NetworkManager.service
echo "  NetworkManager enabled"
systemctl enable bluetooth
echo "  Bluetooth enabled"
systemctl enable avahi-daemon.service
echo "  Avahi enabled"
systemctl enable plasma-powerdevil
echo "  PowerDevil enabled"
systemctl enable fstrim.timer
echo "  fstrim enabled"
systemctl enable kwrited
echo "  Kwrited enabled"
systemctl enable zram0.service
echo " zRam-generator enabled"

echo -ne "
------------------------------------------------------
   █████╗ ██████╗  ██████╗██╗  ██╗ ██████╗  ██████╗
  ██╔══██╗██╔══██╗██╔════╝██║  ██║██╔██╔██╗██╔════╝
  ███████║██████╔╝██║     ███████║██║██║██║██████╗ 
  ██╔══██║██╔══██╗██║     ██╔══██║██║██║██║██╔═══╝ 
  ██║  ██║██║  ██║╚██████╗██║  ██║██║██║██║╚██████╗
  ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═╝╚═╝╚═╝ ╚═════╝
------------------------------------------------------
             Automated Arch Linux Installer
------------------------------------------------------

                     Cleaning Up
------------------------------------------------------
"
# Set a password for the user ROOT
# if this is not done, root is disabled.
passwd root

# Remove no password sudo rights
sed -i 's/^%wheel ALL=(ALL) NOPASSWD: ALL/# %wheel ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers
sed -i 's/^%wheel ALL=(ALL:ALL) NOPASSWD: ALL/# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/' /etc/sudoers
# Add sudo rights
sed -i 's/^# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

rm -r $HOME/archme
rm -r /home/$USERNAME/archme

# Replace in the same state
cd $pwd

