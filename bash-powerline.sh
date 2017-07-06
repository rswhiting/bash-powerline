# github.com/rswhiting/bash-powerline

#########################################################################################
# Aliases

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias cc='cd && clear'
alias hosts='vim /etc/hosts'
alias catalina='vim ~/apache-tomcat-8.0.27/bin/catalina.sh'

# don't put duplicate lines or lines starting with space in the history.
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

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

ssh-rc() {
    ssh-add > /dev/null 2>&1
    ssh-copy-id $1
    scp -q ~/.bashrc $1:/tmp/.bashrc_temp
    /usr/bin/ssh -t $1 "bash --rcfile /tmp/.bashrc_temp ; rm /tmp/.bashrc_temp"
}
alias ssh=ssh-rc

__powerline() {

    # Unicode symbols
    readonly PS_SYMBOL_DARWIN=''       ; readonly PS_SYMBOL_LINUX='$'
    readonly PS_SYMBOL_OTHER='%'        ; readonly BRANCH_SYMBOL='⑂ '
    readonly BRANCH_CHANGED_SYMBOL='+'  ; readonly NEED_PUSH_SYMBOL='⇡'
    readonly NEED_PULL_SYMBOL='⇣'

    # Solarized colorscheme
    readonly FG_BASE03="\[$(tput setaf 8)\]"    ; readonly FG_BASE02="\[$(tput setaf 0)\]"
    readonly FG_BASE01="\[$(tput setaf 10)\]"   ; readonly FG_BASE00="\[$(tput setaf 11)\]"
    readonly FG_BASE0="\[$(tput setaf 12)\]"    ; readonly FG_BASE1="\[$(tput setaf 14)\]"
    readonly FG_BASE2="\[$(tput setaf 7)\]"     ; readonly FG_BASE3="\[$(tput setaf 15)\]"

    readonly BG_BASE03="\[$(tput setab 8)\]"    ; readonly BG_BASE02="\[$(tput setab 0)\]"
    readonly BG_BASE01="\[$(tput setab 10)\]"   ; readonly BG_BASE00="\[$(tput setab 11)\]"
    readonly BG_BASE0="\[$(tput setab 12)\]"    ; readonly BG_BASE1="\[$(tput setab 14)\]"
    readonly BG_BASE2="\[$(tput setab 7)\]"     ; readonly BG_BASE3="\[$(tput setab 15)\]"

    readonly FG_YELLOW="\[$(tput setaf 3)\]"    ; readonly FG_ORANGE="\[$(tput setaf 9)\]"
    readonly FG_RED="\[$(tput setaf 1)\]"       ; readonly FG_MAGENTA="\[$(tput setaf 5)\]"
    readonly FG_VIOLET="\[$(tput setaf 13)\]"   ; readonly FG_BLUE="\[$(tput setaf 4)\]"
    readonly FG_CYAN="\[$(tput setaf 6)\]"      ; readonly FG_GREEN="\[$(tput setaf 2)\]"
    readonly FG_WHITE="\[$(tput setaf 15)\]"

    readonly BG_YELLOW="\[$(tput setab 3)\]"    ; readonly BG_ORANGE="\[$(tput setab 9)\]"
    readonly BG_RED="\[$(tput setab 1)\]"       ; readonly BG_MAGENTA="\[$(tput setab 5)\]"
    readonly BG_VIOLET="\[$(tput setab 13)\]"   ; readonly BG_BLUE="\[$(tput setab 4)\]"
    readonly BG_CYAN="\[$(tput setab 6)\]"      ; readonly BG_GREEN="\[$(tput setab 2)\]"

    readonly DIM="\[$(tput dim)\]"              ; readonly REVERSE="\[$(tput rev)\]"
    readonly RESET="\[$(tput sgr0)\]"           ; readonly BOLD="\[$(tput bold)\]"

    # what OS?
    case "$(uname)" in
        Darwin)
            readonly PS_SYMBOL=$PS_SYMBOL_DARWIN
            ;;
        Linux)
            readonly PS_SYMBOL=$PS_SYMBOL_LINUX
            ;;
        *)
            readonly PS_SYMBOL=$PS_SYMBOL_OTHER
    esac

    __git_info() {
        [ -x "$(which git)" ] || return    # git not found

        local git_eng="env LANG=C git"   # force git output in English to make our work easier
        # get current branch name or short SHA1 hash for detached head
        local branch="$($git_eng symbolic-ref --short HEAD 2>/dev/null || $git_eng describe --tags --always 2>/dev/null)"
        [ -n "$branch" ] || return  # git branch not found

        local marks

        # branch is modified?
        [ -n "$($git_eng status --porcelain)" ] && marks+=" $BRANCH_CHANGED_SYMBOL"

        # how many commits local branch is ahead/behind of remote?
        local stat="$($git_eng status --porcelain --branch | grep '^##' | grep -o '\[.\+\]$')"
        local aheadN="$(echo $stat | grep -o 'ahead [[:digit:]]\+' | grep -o '[[:digit:]]\+')"
        local behindN="$(echo $stat | grep -o 'behind [[:digit:]]\+' | grep -o '[[:digit:]]\+')"
        [ -n "$aheadN" ] && marks+=" $NEED_PUSH_SYMBOL$aheadN"
        [ -n "$behindN" ] && marks+=" $NEED_PULL_SYMBOL$behindN"

        # print the git branch segment without a trailing newline
        printf " $BRANCH_SYMBOL$branch$marks "
    }

    __svn_branch() {
        local url=`svn info 2>&1 | grep '^URL:'`
        if [[ $url =~ trunk ]]; then
            echo trunk
        elif [[ $url =~ /branches/ ]]; then
            echo $url | sed -e 's#^.*/branches/\(.*\)$#\1#'
        elif [[ $url =~ /tags/ ]]; then
            echo $url | sed -e 's#^.*/tags/\(.*\)$#\1#'
        fi
    }

    __svn_info() {
        [ -x "$(which svn)" ] || return    # svn not found

        # get current branch name or short SHA1 hash for detached head
        local branch="$(__svn_branch)"
        [ -n "$branch" ] || return  # git branch not found

        local marks

        # branch is modified?
        [ -n "$(svn status)" ] && marks+=" $BRANCH_CHANGED_SYMBOL"

        # how many commits local branch is ahead/behind of remote?
        local aheadN="$(svn status | grep -c '^\S')"
        local behindN="$(svn status -u | grep -c '^\s')"
        local behindN="$(svn log -r BASE:HEAD | egrep -c '^r[[:digit:]]+ \|')"
        [ -n "$aheadN" ] && marks+=" $NEED_PUSH_SYMBOL$aheadN"
        [ -n "$behindN" ] && marks+=" $NEED_PULL_SYMBOL$behindN"

        # print the branch segment without a trailing newline
        printf " $BRANCH_SYMBOL$branch$marks "
    }

    ps1() {
        # Check the exit code of the previous command and display different
        # colors in the prompt accordingly.
        if [ $? -eq 0 ]; then
            local PROMPT_EXIT="$FG_WHITE"
        else
            local PROMPT_EXIT="$FG_RED"
        fi

        PS1="$BG_BLUE$FG_WHITE$BOLD \u$RESET" # user
        PS1+="$BG_BLUE$FG_WHITE@\h $RESET" # host
        PS1+="$BG_BASE1$FG_WHITE \t $RESET" # time
        PS1+="$BG_BASE1$FG_WHITE \w $RESET" # directory
        PS1+="$BG_GREEN$FG_WHITE$BOLD$(__git_info)$RESET" # git section
        PS1+="$BG_GREEN$FG_WHITE$BOLD$(__svn_info)$RESET" # svn section
        PS1+="\n$PROMPT_EXIT$BOLD$PS_SYMBOL$RESET " # prompt/error
    }

    PROMPT_COMMAND=ps1
}

# only run powerline for interactive shell
if [[ $- == *i* ]]; then
    __powerline
    unset __powerline
fi
