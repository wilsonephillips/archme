# archme
 A modification of ArchTitus and some other scripts by various experts like Chris Titus Tech and Ermmano at EFLinux to learn from and personalize to my liking.
 
 This is a set of scripts to automate the tedious task of doing an Arch Linux installation. This is basically everything I would do by command line, condensed down into shell scripts. Of course this is personalized to load my laptop only. I would need to make a few edits to use it on my desktop PC.
 
This was a great learning experience for me. It was my first test of shell scripting. I think it was well worth my time and effort. I really enjoyed myself. I would recommed it highly for anyone who wants to learn scripting. You don't have to know a lot of bash. You can just modify things.

Right now, this seems to be working very well. I just gave it a test run with a full install of everything I use on my laptop and Timeshift is making snapshots. Grub is customized and shows the snapshots too. The printer and scanner work. Pacman has Color Candy, Verbose Package Lists and Parallel Downloads. Zsh is the default shell. 

###########################################################################

Boot the Arch ISO

setfont ter-i28n # The small font on the laptop screen is not readable for me. The script sets this in vconsole.conf as well.

iwctl

station wlan0 connect <SSID>

Put in the password for the Wi-Fi

exit

pacman -Sy       #This will verify your connectivity, get the keys and sync the databases for the repositories

pacman -S git

git clone https://github.com/wilsonephillips/archme

cd archme

./archme

Follow the prompts and exit and reboot at the end.
