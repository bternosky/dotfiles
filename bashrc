# Include git completion bashrc fragments
# https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash
# https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh
source ~/.git-completion.bash
source ~/.git-prompt.sh

# Setup file creation permissions default as 644
umask=022

# Create function: [bash] set-tile foo 
# sets title of current xterm 
set-title(){
  echo -ne "\033]0;$@\007"
}

##################################################
# General Unix-y environment setup
export EDITOR=vi
export MANPATH=/usr/man:/usr/local/ma
export MPAGE='-b letter'
export MANPATH=/usr/share/man

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize
##################################################

################################################
# Define what your prompt looks like
# Standard Prompt
#export PS1="[\u@\h \W]\\$ "
# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

color_prompt=yes
#color_prompt=

# Pick prompt based on color support..but also add git branch info
# \u = user
# \h = host
# \W = relative path (\w  = absolute path)
# [01;32m] sets green on \u\h
# [01;34m] sets blue on \W
# [01;31m] sets red
# [03;33m] sets yellow
if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}[\[\033[01;32m\]\u@LAPTOP\[\033[00m\]:\[\033[01;34m\]\W\[\033[00m\]$(__git_ps1 " (%s)")]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}[\u@\h:\W$(__git_ps1 " (%s)")]\$ '
fi

# Prompt with git branch added - no colors
#export PS1='[\u@\h \W$(__git_ps1 " (%s)")]\$ '
################################################

################################################
# SSH Keychain
################################################
/usr/bin/keychain $HOME/.ssh/id_rsa
source $HOME/.keychain/$HOSTNAME-sh

################################################
# Command shortcuts - optional
alias which="type -path"
alias h='history'
alias l='ls -lh'
alias ls='ls --color'
alias tree='tree -C'
alias oocalc='libreoffice --calc'
alias oowriter='libreoffice --writer'

# Add some color to grep commands. Speed it up by skipping dir names
# handle common typos
alias egrep='egrep --color=tty -d skip'
alias egrpe='egrep --color=tty -d skip'
alias fgrep='fgrep --color=tty -d skip'
alias fgrpe='fgrep --color=tty -d skip'

# Frequent Typos
alias grep='grep --color=tty -d skip'
alias grpe='grep --color=tty -d skip'

# Pretty Print JSON. Usage: prettjson [inputfile] > [outputfile]
alias prettyjson='python -m json.tool'
################################################

#################################################
# Path control
export PATH=/bin:/usr/bin:/usr/X11R6/bin:/usr/local/bin:/sbin:/usr/sbin
#################################################

#################################################
# Mess with tab completion
# Tab completion to only show directories when using cd
complete -d cd

# Don't show files ending in ~ using tab completion (.o:~ would do .o's too).
export FIGNORE=\~
#################################################

####################################################
# Control "history" command behavior
# Append not overwrite
shopt -s histappend

# Store multiline commands as a single line
shopt -s cmdhist

# Record each line to .bash_history as it happens not on terminal exist
PROMPT_COMMAND='history -a'

# in memory readline history size (default is 500)
export HISTSIZE=100000000

# disk backed readline history size (default is 500)
export HISTFILESIZE=100000

# ignoreboth = ignore duplicate command and ignore command that start with whitespace
export HISTCONTROL=ignoreboth

# Don't capture these commands:
HISTIGNORE='ls:bg:fg:history:pwd:h'

# Add timestamps
HISTTIMEFORMAT="[%Y-%m-%d %H:%M:%S] "

####################################################

####################################################
# Utility functions

# Purpose: Convert a Unix time_t to a human readable date
#        e.g.: x 1234567890.0 returns: 2009-02-13 18:31:30
# Usage  : x TIME_T value
function x () {
   date -d"1970-01-01 UTC $1 seconds" +"%Y-%m-%d %H:%M:%S";
}

# Purpose: Show all process running as you
# Usage  : z
function z () {
   pstree -ap $USER
}

# Purpose: Function to do a ps with a search
# Usage  : pss SOMESTRING
function pss () {
    ps -aefl | grep "$1"
}

# Purpose: Function to do a filename search
# Usage  : ff FILENAMEPATTERN
function ff () {
    find . -name "$1" -print
}

# Purpose: Function to find files and perform a search
# Usage  : ffs FILENAMEPATTERN SOMESTRING
function ffs () {
    ff "$1" | xargs grep "$2"
}

# Purpose: Function to find files and perform a search case insensitively
# Usage  : ffs FILENAMEPATTERN SOMESTRING
function ffsi () {
    ff "$1" | xargs grep -i "$2"
}

# Purpose: Function to find .py files in the current directory and search for a string in them
# Usage  : fpy SOMESTRING
function fpy () {
    ffsi '*.py' "$1"
}

# Purpose: Function to find .sql files in the current directory and search for a string in them
# Usage  : fsql SOMESTRING
function fsql () {
    ffsi '*.sql' "$1"
}

# Purpose: Function to find .xml files in the current directory and search for a string in them
# Usage  : fxml SOMESTRING
function fxml () {
    ffsi '*.xml' "$1"
}

# Purpose: Function to find .js files in the current directory and search for a string in them
# Usage  : fjs SOMESTRING
function fjs () {
    ffsi '*.js' "$1"
}

# Purpose: Function to find .css files in the current directory and search for a string in them
# Usage  : fcss SOMESTRING
function fcss () {
    ffsi '*.css' "$1"
}

# Purpose: Function to find all .pyc files and remove them
# Usage  : rmpyc
function rmpyc () {
    ffsi '*.pyc' | xargs rm
}

####################################################
# Extract line #s between $1 and $2 from file $3
function extractlines() {
    /bin/sed -n "$1","$2"p "$3"
}
