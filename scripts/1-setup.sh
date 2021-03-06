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
                   SCRIPTHOME: archme
------------------------------------------------------
"
source $HOME/archme/configs/setup.conf
echo -ne "
------------------------------------------------------
                   Network Setup
------------------------------------------------------
"
pacman -S --noconfirm --needed networkmanager dhclient
systemctl enable --now NetworkManager
echo -ne "
------------------------------------------------------
       Setting up mirrors for optimal download
------------------------------------------------------
"
pacman -S --noconfirm --needed pacman-contrib curl
pacman -S --noconfirm --needed reflector rsync grub arch-install-scripts git
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak

nc=$(grep -c ^processor /proc/cpuinfo)
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

   You have " $nc" cores. Also changing the makeflags for "$nc" cores.
   As well as changing the compression settings.
-------------------------------------------------------
"
TOTAL_MEM=$(cat /proc/meminfo | grep -i 'memtotal' | grep -o '[[:digit:]]*')
if [[  $TOTAL_MEM -gt 8000000 ]]; then
sed -i "s/#MAKEFLAGS=\"-j2\"/MAKEFLAGS=\"-j$nc\"/g" /etc/makepkg.conf
sed -i "s/COMPRESSXZ=(xz -c -z -)/COMPRESSXZ=(xz -c -T $nc -z -)/g" /etc/makepkg.conf
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

            Setup Language to US and set locale
-------------------------------------------------------
"
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
timedatectl --no-ask-password set-timezone US/Central
timedatectl --no-ask-password set-ntp 1
ln -s /usr/share/zoneinfo/US/Central /etc/localtime
# Set keymaps
echo KEYMAP=us > /etc/vconsole.conf
echo FONT=ter-i24b.psf.gz >> /etc/vconsole.conf

# Add sudo no password rights
sed -i 's/^# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers
sed -i 's/^# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/' /etc/sudoers

#Add parallel downloading, Candy, Multilib repo, etc.
sed -i '/#UseSyslog/a ILoveCandy' /etc/pacman.conf
sed -i 's/^#Color/Color/' /etc/pacman.conf
sed -i 's/^#VerbosePkgLists/VerbosePkgLists/' /etc/pacman.conf
sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf
sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf
pacman -Sy --noconfirm --needed

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

                Installing Base System
------------------------------------------------------
"
# sed $INSTALL_TYPE is using install type to check for MINIMAL installation, if it's true, stop
# stop the script and move on, not installing any more packages below that line
if [[ ! $DESKTOP_ENV == server ]]; then
  sed -n '/'$INSTALL_TYPE'/q;p' $HOME/archme/pkg-files/pacman-pkgs.txt | while read line
  do
    if [[ ${line} == '--END OF MINIMAL INSTALL--' ]]; then
      # If selected installation type is FULL, skip the --END OF THE MINIMAL INSTALLATION-- line
      continue
    fi
    echo "INSTALLING: ${line}"
    sudo pacman -S --noconfirm --needed ${line}
  done
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

                Installing Microcode
------------------------------------------------------
"
# determine processor type and install microcode
proc_type=$(lscpu)
if grep -E "GenuineIntel" <<< ${proc_type}; then
    echo "Installing Intel microcode"
    pacman -S --noconfirm --needed intel-ucode
    proc_ucode=intel-ucode.img
elif grep -E "AuthenticAMD" <<< ${proc_type}; then
    echo "Installing AMD microcode"
    pacman -S --noconfirm --needed amd-ucode
    proc_ucode=amd-ucode.img
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

              Installing Graphics Drivers
------------------------------------------------------
"
# Graphics Drivers find and install
gpu_type=$(lspci)
if grep -E "NVIDIA|GeForce" <<< ${gpu_type}; then
    pacman -S --noconfirm --needed nvidia
	nvidia-xconfig
elif lspci | grep 'VGA' | grep -E "Radeon|AMD"; then
    pacman -S --noconfirm --needed xf86-video-amdgpu
elif grep -E "Integrated Graphics Controller" <<< ${gpu_type}; then
    pacman -S --noconfirm --needed libva-intel-driver libvdpau-va-gl lib32-vulkan-intel vulkan-intel libva-intel-driver libva-utils lib32-mesa
elif grep -E "Intel Corporation UHD" <<< ${gpu_type}; then
    pacman -S --needed --noconfirm libva-intel-driver libvdpau-va-gl lib32-vulkan-intel vulkan-intel libva-intel-driver libva-utils lib32-mesa
fi
#SETUP IS WRONG THIS IS RUN
if ! source $HOME/archme/configs/setup.conf; then
	# Loop through user input until the user gives a valid username
	while true
	do
		read -p "Please enter username:" username
		# username regex per response here https://unix.stackexchange.com/questions/157426/what-is-the-regex-to-validate-linux-users
		# lowercase the username to test regex
		if [[ "${username,,}" =~ ^[a-z_]([a-z0-9_-]{0,31}|[a-z0-9_-]{0,30}\$)$ ]]
		then
			break
		fi
		echo "Incorrect username."
	done
# convert name to lowercase before saving to setup.conf
echo "username=${username,,}" >> ${HOME}/archme/configs/setup.conf

    #Set Password
    read -p "Please enter password:" password
echo "password=${password,,}" >> ${HOME}/archme/configs/setup.conf

    # Loop through user input until the user gives a valid hostname, but allow the user to force save
	while true
	do
		read -p "Please name your machine:" name_of_machine
		# hostname regex (!!couldn't find spec for computer name!!)
		if [[ "${name_of_machine,,}" =~ ^[a-z][a-z0-9_.-]{0,62}[a-z0-9]$ ]]
		then
			break
		fi
		# if validation fails allow the user to force saving of the hostname
		read -p "Hostname doesn't seem correct. Do you still want to save it? (y/n)" force
		if [[ "${force,,}" = "y" ]]
		then
			break
		fi
	done

    echo "NAME_OF_MACHINE=${name_of_machine,,}" >> ${HOME}/archme/configs/setup.conf
fi


# add btrfs in mkinitcpio.conf in modules section
    sed -i 's/^MODULES=()/MODULES=(btrfs)/' /etc/mkinitcpio.conf.conf
# making mkinitcpio with linux kernel
    mkinitcpio -p linux

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

                      Adding User
------------------------------------------------------
"
if [ $(whoami) = "root"  ]; then
    groupadd libvirt
    useradd -m -G wheel,libvirt -s /bin/zsh $USERNAME
    echo "$USERNAME created, home directory created, added to wheel and libvirt group, default shell set to /bin/zsh"

# use chpasswd to enter $USERNAME:$password
    echo "$USERNAME:$PASSWORD" | chpasswd
    echo "$USERNAME password set"

	cp -R $HOME/archme /home/$USERNAME/
    chown -R $USERNAME: /home/$USERNAME/archme
    echo "archme copied to home directory"
    
# Copy some wallpaper and other files to the system
	cp $HOME/archme/files/99-disable-touchscreen.sh /etc/X11/xinit/xinitrc.d
	cp $HOME/archme/files/.bash_profile $HOME
	cp $HOME/archme/files/.bashrc $HOME
	cp $HOME/archme/files/.histfile $HOME
	cp $HOME/archme/files/.nanorc $HOME
	cp $HOME/archme/files/.zshrc $HOME
	cp $HOME/archme/files/.bash_profile /root
	cp $HOME/archme/files/.bashrc /root
	cp $HOME/archme/files/.histfile /root
	cp $HOME/archme/files/.nanorc /root
	cp $HOME/archme/files/.zshrc /root
	cp -R $HOME/archme/files/archlinux /usr/share/backgrounds
	cp -R $HOME/archme/files/wilson /usr/share/backgrounds
	cp -R $HOME/archme/files/wilson $HOME/Pictures
    echo "wallpaper and user icons coppied to system"

# enter $NAME_OF_MACHINE to /etc/hostname and /etc/hosts
	echo $NAME_OF_MACHINE > /etc/hostname
	echo "127.0.0.1		localhost" >> /etc/hosts
	echo "::1		localhost" >> /etc/hosts
	echo "127.0.1.1		$NAME_OF_MACHINE.local	$NAME_OF_MACHINE" >> /etc/hosts
	echo "192.168.1.5	brother.local		brother" >> /etc/hosts
	echo "192.168.1.10	heisenberg.local	heisenberg" >> /etc/hosts

else
	echo "You are already a user. Proceed with aur installs"
fi

1-setup.sh

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

	       SYSTEM READY FOR 2-user.sh
------------------------------------------------------
"
