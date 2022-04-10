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

               Installing AUR Software
------------------------------------------------------
"
source $HOME/archme/configs/setup.conf

sed -n '/'$INSTALL_TYPE'/q;p' ~/archme/pkg-files/${DESKTOP_ENV}.txt | while read line
do
  if [[ ${line} == '--END OF MINIMAL INSTALL--' ]]
  then
    # If selected installation type is FULL, skip the --END OF THE MINIMAL INSTALLATION-- line
    continue
  fi
  echo "INSTALLING: ${line}"
  sudo pacman -S --noconfirm --needed ${line}
done


if [[ ! $AUR_HELPER == none ]]; then
  cd ~
  git clone "https://aur.archlinux.org/$AUR_HELPER.git"
  cd ~/$AUR_HELPER
  makepkg -si --noconfirm
  # sed $INSTALL_TYPE is using install type to check for MINIMAL installation, if it's true, stop
  # stop the script and move on, not installing any more packages below that line
  sed -n '/'$INSTALL_TYPE'/q;p' ~/archme/pkg-files/aur-pkgs.txt | while read line
  do
    if [[ ${line} == '--END OF MINIMAL INSTALL--' ]]; then
      # If selected installation type is FULL, skip the --END OF THE MINIMAL INSTALLATION-- line
      continue
    fi
    echo "INSTALLING: ${line}"
    $AUR_HELPER -S --noconfirm --needed ${line}
  done
fi

export PATH=$PATH:~/.local/bin

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

            SYSTEM READY FOR 3-post-setup.sh
------------------------------------------------------
"
exit
