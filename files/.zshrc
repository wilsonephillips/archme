# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=5000
setopt autocd beep extendedglob nomatch notify
bindkey -e
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/wilson/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall
#
#
############################### DO NOT EDIT LINES ABOVE ################################
#
#
########### INITIALIZE THE CUSTOM PROMPT #################
autoload -Uz promptinit
promptinit
prompt fire
#
########### PATHS AND DEFAULTS #############
export EDITOR="/usr/bin/micro"
export VISUAL="/usr/bin/micro"

test -s ~/.alias && . ~/.alias || true

setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_EXPIRE_DUPS_FIRST

########### ALIAS SECTION #############
# List and Search
alias ls="exa -aHl --group-directories-first"
alias find="fd -Hl"
alias search="fd -Hl --base-directory /"

# Program Swaps
alias cat="bat"
alias top="htop"

# Pacman and YAY commands
alias clean="yay -Sc"
alias upy="yay -Syu"
alias cache="sudo paccache -rk1"

# Commands that are just too long to remember
alias mirror="sudo reflector --country US --age 6 --sort rate --score 20 --save /etc/pacman.d/mirrorlist"
alias grub="sudo grub-mkconfig -o /boot/grub/grub.cfg"
alias init="mkinitcpio -p linux"

############ STARTUP SECTION ###############
# Execute these commands when the terminal starts
neofetch

