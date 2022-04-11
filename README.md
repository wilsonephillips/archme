# archme
 A modification of ArchTitus and some other scripts to learn from and personalize to my liking.
 
 This is a set of scripts to automate the tedious task of doing an Arch Linux installation. This is basically everything I would do by command line, condensed down into shell scripts. Of course this is personalized to load my laptop only. I would need to make a few edits to use it on my desktop PC.
 
This was a great learning experience for me. It was my first test of shell scripting. I think it was well worth my time and effort. I really enjoyed myself. I would recommed it highly.

###########################################################################

Boot the Arch ISO

pacman -Sy       #This will get the keys and sync the databases for the repositories

pacman -S git

git clone https://github.com/wilsonephillips/archme

cd archme

./archme

Follow the prompts and exit and reboot at the end.
