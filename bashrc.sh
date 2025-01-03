# overwrite these in .bash_aliases if they are different on this machine only
CODE_HOME=$HOME/code
NOTES_HOME=$CODE_HOME/notes-personal
WINDOWS_HOME=/mnt/c/Users/RobertWhiting

# Espanso
ESPANSO_CONFIG=$NOTES_HOME/espanso-config.yaml
ESPANSO_HOME=$WINDOWS_HOME/AppData/Roaming/espanso/match
alias espanso-sync="cp ${ESPANSO_CONFIG} ${ESPANSO_HOME}/base.yml"
alias espanso="echo $ESPANSO_HOME"


# PigDate calculator (SwineTech)
alias pigdate_today='d0="1971-09-27" && diff=$(( ($(date -u +%s) - $(date -u -d "$d0" +%s)) / 86400 )) && printf "%02d-%03d\n" $((diff / 1000)) $((diff % 1000))'

# Sprint calcuator (TSheets)
alias sprint_number='echo $(( ($(date +%s)-$(date +%s -d 20210802))/86400/14+169 ))'


alias ll='ls -alhF'
alias la='ls -A'
alias cc='cd && clear && source ~/.bashrc'
alias hosts='vim /etc/hosts'
alias ..='cd ..'
alias ...='cd ..; cd ..'
alias ....='cd ..; cd ..; cd ..'
alias bashrc='source ~/.bashrc'

export PROMPT_COMMAND=enter_directory

# don't put duplicate lines or lines starting with space in the history.
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# enables globbing directories with the ** syntax
shopt -s globstar

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi


# add scripts to path
if [ -d "$HOME/code/scripts" ] ; then
      PATH="$HOME/code/scripts:$PATH"
fi
if [ -d "$HOME/.local/bin" ] ; then
      PATH="$HOME/.local/bin:$PATH"
fi

# Set to VI mode
set -o vi

# Set the path
export LANG=en_US.UTF-8

