# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin:$HOME/.local/bin:$PATH


ZSH_DISABLE_COMPFIX=true
# Path to your oh-my-zsh installation.
export ZSH="/home/avery/.oh-my-zsh"

ZSH_THEME="robbyrussell"
plugins=(zsh-autosuggestions colored-man-pages docker docker-compose gcloud git-flow-avh git gitignore history minikube terraform vagrant kubectl autojump)

source $ZSH/oh-my-zsh.sh

prompt_segment() {
  local bg fg
  [[ -n $1 ]] && bg="%K{$1}" || bg="%k"
  [[ -n $2 ]] && fg="%F{$2}" || fg="%f"
  if [[ $CURRENT_BG != 'NONE' && $1 != $CURRENT_BG ]]; then
    print -n "%{$bg%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR%{$fg%}"
  else
    print -n "%{$bg%}%{$fg%}"
  fi
  CURRENT_BG=$1
  [[ -n $3 ]] && print -n $3
}


# Git: branch/detached head, dirty status
prompt_git() {
  (( $+commands[git] )) || return
  if [[ "$(git config --get oh-my-zsh.hide-status 2>/dev/null)" = 1 ]]; then
    return
  fi
  start=$(date +%s)
  local PL_BRANCH_CHAR
  () {
    local LC_ALL="" LC_CTYPE="en_US.UTF-8"
    PL_BRANCH_CHAR=$'\ue0a0'         # 
  }
  local ref dirty mode repo_path

   if [[ "$(git rev-parse --is-inside-work-tree 2>/dev/null)" = "true" ]]; then
    repo_path=$(git rev-parse --git-dir 2>/dev/null)
    dirty=$(parse_git_dirty)
    ref=$(git symbolic-ref HEAD 2> /dev/null) || ref="➦ $(git rev-parse --short HEAD 2> /dev/null)"
    if [[ -n $dirty ]]; then
      prompt_segment yellow black
    else
      prompt_segment green $CURRENT_FG
    fi

    if [[ -e "${repo_path}/BISECT_LOG" ]]; then
      mode=" <B>"
    elif [[ -e "${repo_path}/MERGE_HEAD" ]]; then
      mode=" >M<"
    elif [[ -e "${repo_path}/rebase" || -e "${repo_path}/rebase-apply" || -e "${repo_path}/rebase-merge" || -e "${repo_path}/../.dotest" ]]; then
      mode=" >R>"
    fi

    setopt promptsubst
    autoload -Uz vcs_info

    zstyle ':vcs_info:*' enable git
    zstyle ':vcs_info:*' get-revision true
    zstyle ':vcs_info:*' check-for-changes true
    zstyle ':vcs_info:*' stagedstr '✚'
    zstyle ':vcs_info:*' unstagedstr '±'
    zstyle ':vcs_info:*' formats ' %u%c'
    zstyle ':vcs_info:*' actionformats ' %u%c'
    vcs_info

    branchname=${ref/refs\/heads\/}
    ref=$branchname

    length=${#ref}

    maxLength=$(command git config --get oh-my-zsh.max-branch-length 2>/dev/null)
    if [[ -z ${maxLength} ]]; then
      maxLength=20
    fi

    if [[ ${length} -gt ${maxLength} ]]; then
        regex="[^\/]*\/"
      if [[ -n ${regex} ]]; then
        ref=$(command echo ${ref} | sed "s/${regex}//1" ) #${regex})
      fi
      if [[ -n ${regex} ]]; then
          ref=$(command echo ${ref} | sed "s/${regex}//1" ) #${regex})
      fi

      prefixLength=$(command git config --get oh-my-zsh.prefix-length 2>/dev/null)
      if [[ -z ${prefixLength} ]]; then
        prefixLength=0
      fi
      if [[ ${prefixLength} -gt 0 ]]; then
        prefix=$(command echo ${ref} | cut -c ${prefixLength})
        ref=$(command echo ${ref} | cut -c `expr ${prefixLength} + 1`-)
        length=${#ref}
      fi
    fi
    length=${#ref}
    if [[ ${length} -gt ${maxLength} ]]; then
      suffixLength=$(command git config --get oh-my-zsh.suffix-length 2>/dev/null)
      if [[ -z ${suffixLength} ]]; then
        suffixLength=0
      fi

      length=${#ref}
      suffixStart=`expr ${length} - ${suffixLength} + 1`
      separatorLength=3 #3 dots...
      nameEnd=`expr ${maxLength} - ${suffixLength} - ${separatorLength}`
      ref="$(command echo ${ref} | cut -c 1-${nameEnd})...$(command echo ${ref} | cut -c ${suffixStart}-)"

    fi
    branchname=$ref
    end=$(date +%s)
    duration=$((end - start))
    echo -n "${PL_BRANCH_CHAR} ${branchname}${vcs_info_msg_0_%% }${mode} d:${duration}"
  fi
}

prompt_dir() {
  prompt_segment blue $CURRENT_FG '%2~'
}

alias e="emacs -nw"

# Kube Autocomplete
[[ /usr/local/bin/kubectl ]] && source <(kubectl completion zsh)

# Autojump
[ -f /usr/local/etc/profile.d/autojump.sh ] && . /usr/local/etc/profile.d/autojump.sh

export PATH="/usr/local/sbin:$PATH"


alias capsctrl="setxkbmap -layout us -option ctrl:nocaps"
alias altwin="setxkbmap -option altwin:swap_alt_win"
alias sl="ls"


PRE_PROMPT="%F{red}%n%f"
PRE_PROMPT+="@"
PRE_PROMPT+="%F{blue}${${(%):-%m}#zoltan-}%f"
PROMPT="$PRE_PROMPT $PROMPT"

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export TERM=xterm-256color
alias performance='echo "performance" | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor'


export SKIP_INPUT=true
alias sleepscreen='xset dpms force suspend'
export HF_HOME="/mnt/localdisk/hfdata"

alias dropdb='npx prisma db execute --file prisma/drop_db.sql'
alias pushdb='npx prisma db push'
alias seeddb='npx prisma db seed'
alias audiodac='pacmd set-default-sink alsa_output.usb-SMSL_SMSL_USB_AUDIO-00.analog-stereo'
alias watch='watch --color '
alias wn='watch -n 0.1 --color nvidia-smi'

HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000000
SAVEHIST=10000000
setopt HIST_IGNORE_SPACE         # Don't record an entry starting with a space.

export KUBECONFIG=/home/avery/.kube/azurek8s
alias dircache='find . -maxdepth 2 -mindepth 2 -type d | parallel "find {}" '

export PATH=$PATH:/home/avery/go/bin:/usr/local/go/bin:/home/avery/miniconda3/condabin:/usr/local/sbin:/home/avery/bin:/usr/local/bin:/home/avery/.local/bin:/home/avery/.cargo/bin:/home/avery/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:/snap/bin:
