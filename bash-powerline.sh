# github.com/rswhiting/bash-powerline


source "$(dirname "${BASH_SOURCE[0]}")/bashrc.sh"

# Jump Up multiple directories
# from https://unix.stackexchange.com/questions/14303/bash-cd-up-until-in-certain-folder
ju ()
{
    if [ -z "$1" ]; then
        return
    fi
    local upto=$1
    cd "${PWD/\/$upto\/*//$upto}"
}

# autocomplete for upto()
_ju()
{
    local cur=${COMP_WORDS[COMP_CWORD]}
    local d=${PWD//\//\ }
    COMPREPLY=( $( compgen -W "$d" -- "$cur" ) )
}
complete -F _ju ju

# Jump to a directory down the chain
jd(){
    if [ -z "$1" ]; then
        echo "Usage: jd [directory]"
        return 1
    fi

    local matches=($(compgen -G "**/$1"))

    if [ ${#matches[@]} -eq 0 ]; then
        echo "No matching directories found"
        return 1
    elif [ ${#matches[@]} -eq 1 ]; then
        cd "${matches[0]}"
    else
        echo "Multiple matches found:"
        select dir in "${matches[@]}"; do
            if [ -n "$dir" ]; then
                cd "$dir"
                break
            else
                echo "Invalid selection"
            fi
        done
    fi
}

# autocomplete for jd()
_jd()
{
    local cur=${COMP_WORDS[COMP_CWORD]}
    local matches=($(find . -type d -name "*$cur*"))
    local basenames=()
    for match in "${matches[@]}"; do
        basenames+=("$(basename "$match")")
    done
    COMPREPLY=( $( compgen -W "${basenames[@]}" -- "$cur" ) )
}
complete -F _jd jd

ssh-rc() {
    ssh-add > /dev/null 2>&1
    ssh-copy-id $1
    scp -q ~/.bashrc $1:/tmp/.bashrc_temp
    /usr/bin/ssh -t $1 "bash --rcfile /tmp/.bashrc_temp"
}
#alias ssh=ssh-rc

__powerline() {

    # Unicode symbols
    PS_SYMBOL_DARWIN=''       ; PS_SYMBOL_LINUX='$'
    PS_SYMBOL_OTHER='%'        ; BRANCH_SYMBOL='⑂ '
    BRANCH_CHANGED_SYMBOL='+'  ; NEED_PUSH_SYMBOL='⇡'
    NEED_PULL_SYMBOL='⇣'

    # Solarized colorscheme
    FG_BASE03="\[$(tput setaf 8)\]"    ; FG_BASE02="\[$(tput setaf 0)\]"
    FG_BASE01="\[$(tput setaf 10)\]"   ; FG_BASE00="\[$(tput setaf 11)\]"
    FG_BASE0="\[$(tput setaf 12)\]"    ; FG_BASE1="\[$(tput setaf 14)\]"
    FG_BASE2="\[$(tput setaf 7)\]"     ; FG_BASE3="\[$(tput setaf 15)\]"

    BG_BASE03="\[$(tput setab 8)\]"    ; BG_BASE02="\[$(tput setab 0)\]"
    BG_BASE01="\[$(tput setab 10)\]"   ; BG_BASE00="\[$(tput setab 11)\]"
    BG_BASE0="\[$(tput setab 12)\]"    ; BG_BASE1="\[$(tput setab 14)\]"
    BG_BASE2="\[$(tput setab 7)\]"     ; BG_BASE3="\[$(tput setab 15)\]"

    FG_YELLOW="\[$(tput setaf 3)\]"    ; FG_ORANGE="\[$(tput setaf 9)\]"
    FG_RED="\[$(tput setaf 1)\]"       ; FG_MAGENTA="\[$(tput setaf 5)\]"
    FG_VIOLET="\[$(tput setaf 13)\]"   ; FG_BLUE="\[$(tput setaf 4)\]"
    FG_CYAN="\[$(tput setaf 6)\]"      ; FG_GREEN="\[$(tput setaf 2)\]"
    FG_WHITE="\[$(tput setaf 15)\]"

    BG_YELLOW="\[$(tput setab 3)\]"    ; BG_ORANGE="\[$(tput setab 9)\]"
    BG_RED="\[$(tput setab 1)\]"       ; BG_MAGENTA="\[$(tput setab 5)\]"
    BG_VIOLET="\[$(tput setab 13)\]"   ; BG_BLUE="\[$(tput setab 4)\]"
    BG_CYAN="\[$(tput setab 6)\]"      ; BG_GREEN="\[$(tput setab 2)\]"

    DIM="\[$(tput dim)\]"              ; REVERSE="\[$(tput rev)\]"
    RESET="\[$(tput sgr0)\]"           ; BOLD="\[$(tput bold)\]"

    # what OS?
    case "$(uname)" in
        Darwin)
            PS_SYMBOL=$PS_SYMBOL_DARWIN
            ;;
        Linux)
            PS_SYMBOL=$PS_SYMBOL_LINUX
            ;;
        *)
            PS_SYMBOL=$PS_SYMBOL_OTHER
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

    ps1() {
        # Check the exit code of the previous command and display different
        # colors in the prompt accordingly.
        if [ $? -eq 0 ]; then
            local PROMPT_EXIT="$FG_WHITE"
        else
            local PROMPT_EXIT="$FG_RED"
        fi

        # PS1="$BG_BLUE$FG_WHITE$BOLD \u$RESET" # user
        # PS1+="$BG_BLUE$FG_WHITE@\h $RESET" # host
        # PS1+="$BG_BASE1$FG_WHITE \t $RESET" # time
        # PS1+="$BG_BASE1$FG_WHITE \w $RESET" # directory
        # PS1+="$BG_GREEN$FG_WHITE$BOLD$(__git_info)$RESET" # git section
        # PS1+="\n$PROMPT_EXIT$BOLD$PS_SYMBOL$RESET " # prompt/error

        PS1=""
        PS1+="$BG_BLUE$FG_WHITE \t $RESET" # time
        # PS1+="$FG_WHITE$BOLD \u$RESET" # user
        # PS1+="$FG_WHITE@\h $RESET" # host
        PS1+="$FG_BLUE \w$RESET" # directory
        PS1+="$FG_GREEN$BOLD$(__git_info)$RESET" # git section
        PS1+="\n$PROMPT_EXIT$BOLD$PS_SYMBOL$RESET " # prompt/error
    }

    PROMPT_COMMAND=ps1
}

# only run powerline for interactive shell
if [[ $- == *i* ]]; then
    __powerline
    unset __powerline
fi
