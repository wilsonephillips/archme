# ~/.bashrc

export EDITOR="/usr/bin/micro"
export VISUAL="/usr/bin/micro"

test -s ~/.alias && . ~/.alias || true

#                        [Your_Name]-----|                     [Computer Name]---|
#                 [Color]--------|       |                  [Color]------|       |
#          [Style]------------|  |       |            [Style]---------|  |       |
#                             V  V       V                            V  V       V
PS1='\[\033[01;37m\]┌─[\[\033[01;32m\]wilson\[\033[01;37m\]]-[\[\033[01;36m\]DeathStar\[\033[01;37m\]]-[\[\033[01;33m\]\W\[\033[00;37m\]\[\033[01;37m\]]
\[\033[01;37m\]└─[\[\033[05;33m\]$\[\033[00;37m\]\[\033[01;37m\]]\[\033[00;37m\] '
#                         A  A   A
#          [Style]--------|  |   |-------- [Your_Choice]
#                [Color]-----|

HISTCONTROL=ignoreboth
HISTTIMEFORMAT="%Y-%m-%d %T "

# ALIAS SECTION
alias ls="exa -aHl --group-directories-first"
alias cat="bat"
alias clean="yay -Sc"
alias upy="yay -Syyu"
alias find="fd -Hl"
alias search="fd -Hl --base-directory /"
alias top="htop"
alias reflector="sudo reflector --country US --age 4 --sort rate --score 20 --save /etc/pacman.d/mirrorlist"

# neofetch

# exec fish

