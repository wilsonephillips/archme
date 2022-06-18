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
        Setting up mirrors for optimal download
"
source $CONFIGS_DIR/setup.conf
iso=$(curl -4 ifconfig.co/country-iso)
timedatectl set-ntp true
pacman -S --noconfirm archlinux-keyring #update keyrings to latest to prevent packages failing to install
pacman -S --noconfirm --needed pacman-contrib terminus-font
setfont ter-i28n
sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf
pacman -S --noconfirm --needed reflector rsync grub
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
echo -ne "
-------------------------------------------------------
      Setting up $iso mirrors for faster downloads
-------------------------------------------------------
"
reflector -a 48 -c $iso -f 5 -l 20 --sort rate --save /etc/pacman.d/mirrorlist
mkdir /mnt &>/dev/null # Hiding error message if any
echo -ne "
-------------------------------------------------------
               Installing Prerequisites
-------------------------------------------------------
"
pacman -S --noconfirm --needed gptfdisk btrfs-progs glibc
echo -ne "
-------------------------------------------------------
                  Formating Disk
-------------------------------------------------------
"
umount -A --recursive /mnt # make sure everything is unmounted before we start
# disk prep
sgdisk -Z /dev/nvme0n1 # zap all on disk
sgdisk -a 2048 -o /dev/nvme0n1 # new gpt disk 2048 alignment

# create partitions
sgdisk -n 1::+500M --typecode=1:ef00 --change-name=1:'EFIBOOT' /dev/nvme0n1 # partition 1 (UEFI Boot Partition)
sgdisk -n 2::-0 --typecode=2:8300 --change-name=2:'ARCH' /dev/nvme0n1 # partition 2 (Arch), default start, remaining
partprobe /dev/nvme0n1 # reread partition table to ensure it is correct

# make filesystems
echo -ne "
--------------------------------------------------------
               Creating Filesystems
--------------------------------------------------------
"
# @description Creates the btrfs subvolumes. 
createsubvolumes () {
    btrfs subvolume create /mnt/@
    btrfs subvolume create /mnt/@home
    btrfs subvolume create /mnt/@var
    btrfs subvolume create /mnt/@tmp
    btrfs subvolume create /mnt/@.snapshots
}

# @description Mount all btrfs subvolumes after root has been mounted.
mountallsubvol () {
    mount -o ${MOUNT_OPTIONS},subvol=@home /dev/nvme0n1p2 /mnt/home
    mount -o ${MOUNT_OPTIONS},subvol=@var /dev/nvme0n1p2 /mnt/var
    mount -o ${MOUNT_OPTIONS},subvol=@tmp /dev/nvme0n1p2 /mnt/tmp
    mount -o ${MOUNT_OPTIONS},subvol=@.snapshots /dev/nvme0n1p2 /mnt/.snapshots
}

# @description BTRFS subvolume creation and mounting. 
subvolumesetup () {
# create nonroot subvolumes
    createsubvolumes     
# unmount root to remount with subvolume 
    umount /mnt
# mount @ subvolume
    mount -o ${MOUNT_OPTIONS},subvol=@ /dev/nvme0n1p2 /mnt
# make directories home, .snapshots, var, tmp (separated for reasons)
    mkdir -p /mnt/home
    mkdir -p /mnt/.snapshots
    mkdir -p /mnt/var
    mkdir -p /mnt/tmp
# mount subvolumes
    mountallsubvol
}

if [[ "${FS}" == "btrfs" ]]; then
    mkfs.fat -F32 -n "EFIBOOT" /dev/nvme0n1p1
    mkfs.btrfs -L Arch /dev/nvme0n1p2 -f
    mount -t btrfs /dev/nvme0n1p2 /mnt
    subvolumesetup
fi

# mount target
mkdir -p /mnt/boot/efi
mount -t vfat -L EFIBOOT /mnt/boot/

if ! grep -qs '/mnt' /proc/mounts; then
    echo "Drive is not mounted can not continue"
    echo "Rebooting in 3 Seconds ..." && sleep 1
    echo "Rebooting in 2 Seconds ..." && sleep 1
    echo "Rebooting in 1 Second ..." && sleep 1
    reboot now
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
               Arch Install on Main Drive
------------------------------------------------------
"
pacstrap /mnt --noconfirm --needed base base-devel linux linux-firmware linux-headers btrfs-progs micro vim nano sudo archlinux-keyring git curl wget terminus-font libnewt
echo "keyserver hkp://keyserver.ubuntu.com" >> /mnt/etc/pacman.d/gnupg/gpg.conf
cp -R ${SCRIPT_DIR} /mnt/root/archme
cp /etc/pacman.d/mirrorlist /mnt/etc/pacman.d/mirrorlist

genfstab -U /mnt >> /mnt/etc/fstab
echo "
  Generated /etc/fstab:
"
cat /mnt/etc/fstab
echo -ne "
-------------------------------------------------------
         GRUB BIOS Bootloader Install & Check
-------------------------------------------------------
"
if [[ ! -d "/sys/firmware/efi" ]]; then
    grub-install --boot-directory=/mnt/boot /dev/nvme0n1p1
else
    pacstrap /mnt efibootmgr --noconfirm --needed
fi
echo -ne "
--------------------------------------------------------
         Checking for low memory systems <8G
--------------------------------------------------------
"
TOTAL_MEM=$(cat /proc/meminfo | grep -i 'memtotal' | grep -o '[[:digit:]]*')
if [[  $TOTAL_MEM -lt 8000000 ]]; then
    # Put swap into the actual system, not into RAM disk, otherwise there is no point in it, it'll cache RAM into RAM. So, /mnt/ everything.
    mkdir -p /mnt/opt/swap # make a dir that we can apply NOCOW to to make it btrfs-friendly.
    chattr +C /mnt/opt/swap # apply NOCOW, btrfs needs that.
    dd if=/dev/zero of=/mnt/opt/swap/swapfile bs=1M count=2048 status=progress
    chmod 600 /mnt/opt/swap/swapfile # set permissions.
    chown root /mnt/opt/swap/swapfile
    mkswap /mnt/opt/swap/swapfile
    swapon /mnt/opt/swap/swapfile
    # The line below is written to /mnt/ but doesn't contain /mnt/, since it's just / for the system itself.
    echo "/opt/swap/swapfile	none	swap	sw	0	0" >> /mnt/etc/fstab # Add swap to fstab, so it KEEPS working after installation.
fi
echo -ne "
--------------------------------------------------------
            SYSTEM READY FOR 1-setup.sh
--------------------------------------------------------
"
