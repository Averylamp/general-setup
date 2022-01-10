# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin:$HOME/.local/bin:$PATH


ZSH_DISABLE_COMPFIX=true
# Path to your oh-my-zsh installation.
export ZSH="/home/avery/.oh-my-zsh"

ZSH_THEME="robbyrussell"
plugins=(zsh-autosuggestions colored-man-pages docker docker-compose gcloud git-flow-avh git gitignore history minikube terraform vagrant kubectl autojump)

source $ZSH/oh-my-zsh.sh

# Git: branch/detached head, dirty status
prompt_git() {
  (( $+commands[git] )) || return
  if [[ "$(git config --get oh-my-zsh.hide-status 2>/dev/null)" = 1 ]]; then
    return
  fi
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
    echo -n "${PL_BRANCH_CHAR} ${branchname}${vcs_info_msg_0_%% }${mode}"
  fi
}

prompt_dir() {
  prompt_segment blue $CURRENT_FG '%2~'
}

alias e="emacs -nw"

alias m="mctl"
alias mo="cd ~/mosaic"
alias mc="cd ~/mosaic/mctl"
alias b="mctl"
alias kdelinteractive="kubectl delete jobs -l type=interactive"
alias kdeljobs="kubectl delete jobs --all"
alias kdeljobsall="benchctl delete jobs -l type=interactive"
alias kgj="kubectl get jobs"
alias kdj="kubectl describe job"
alias python="/usr/bin/python3"
alias kgc="kubectl config get-contexts"
alias kscc="kubectl config use-context colo-research-01"
alias ksca="kubectl config use-context aws-research-01"
alias kscaz="kubectl config use-context azure-research-01"
alias kscg="kubectl config use-context gcp-research-01"
alias mutil="mctl util -v"
alias klf="kubectl logs -f "
alias check_failed="kubectl get jobs | grep 0/1 | awk '{ print $1; }' | xargs -I {} kubectl describe job {} | grep -E  '1 Failed'"
# Kube Autocomplete
[[ /usr/local/bin/kubectl ]] && source <(kubectl completion zsh)

run_on_all_contexts(){
    echo "Running '$@' on all contexts"
    current=$(kubectl config current-context)
    kscc
    eval $@
    ksca
    eval $@
    kscaz
    eval $@
    kscg
    eval $@
    kcuc $current
}

kgaj(){
    run_on_all_contexts kgj
}


kdevaws(){
	instance=${1:-g4dn.2xlarge}
    kcuc aws-research-01
    existing=$(kgj -o name | grep "avery-aws-$instance-interactive" | head -n 1 )
    if [ $? -eq 0 ]; then
        echo -e "Existing interactive pod found\n"
        kubectl exec -it $(echo $existing | head -n 1) -- zsh
    else
        echo -e "No existing interactive pod found\nCreating pod...\n"
        echo -e "benchmark interactive --instance $instance --image mosaicml/avery --name avery-aws-$instance-interactive"
        out=$(benchmark interactive --instance $instance --image mosaicml/avery --name avery-aws-$instance-interactive)
        echo $out
        out=$(echo $out | grep -A 2 "Pod launched" |  sed -n 2p | sed s/bash/zsh/)
        echo $out
        eval $out
    fi

}

kdevaws8() {
	kdevaws p3.16xlarge
}

kdevcolo(){
	accelerator=$1
	acc_type=$2
	echo "Accelerator: $gpu"
    kcuc colo-research-01

	job_name="avery-interactive-$accelerator$acc_type"
	if [ ! -n "$accelerator" ]
	then
		job_name="avery-interacitve-cpu"	
	fi
	echo "Job: $job_name"
    existing=$(kgj -o name | grep "$job_name")
    if [ $? -eq 0 ]; then
        echo -e "Existing interactive pod found\n"
        kubectl exec -it $(echo $existing | head -n 1) -- zsh
    else
        echo -e "No existing interactive pod found\nCreating pod...\n"
        echo -e "Running: benchmark interactive --instance cota-$accelerator$acc_type --image mosaicml/avery --name $job_name"
        out=$(benchmark interactive --instance cota-$accelerator$acc_type --image mosaicml/avery --name "$job_name")
        echo $out
        out=$(echo $out | grep -A 2 "Pod launched" |  sed -n 2p | sed s/bash/zsh/)
        echo $out
        eval $out
    fi
}

kdevc(){
	cpus=${1:-10}
	kdevcolo "" "c$cpus"
}
kdev(){
	gpu=${1:-3080}
	gpu_num=${2:-1}
	kdevcolo "g$gpu_num-" "$gpu"
}

aws_clean(){
    kubectl get jobs | grep 1/1 | awk '{ print $1; }' > jobs;
    kubectl get jobs | grep 1/1 | awk '{ print $1; }'  | xargs -I {} kubectl describe job {} | grep -A 3 ebs-pvc | grep -E 'ClaimName:' | awk '{print $2;}' > pvcs;
    echo Deleting jobs;
    cat jobs | parallel --bar kubectl delete job {};
    echo Deleting pvcs;
    cat pvcs | parallel --bar kubectl delete pvc {};
    rm jobs pvcs
}

export PATH="/usr/local/sbin:$PATH"
[ -f /usr/local/etc/profile.d/autojump.sh ] && . /usr/local/etc/profile.d/autojump.sh

xset r rate 600 35
alias worksetup="/home/avery/.xprofile-work"
alias werk="worksetup"
alias work="worksetup"
alias homesetup="/home/avery/.xprofile-home"
alias mob="/home/avery/.xprofile-mobile"
alias srcv="source venv/bin/activate"
alias capsctrl="setxkbmap -layout us -option ctrl:nocaps"
alias sl="ls"

alias audioout="pacmd set-default-sink 'alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__hw_sofhdadsp__sink'"
alias audiodac="pacmd set-default-sink 'alsa_output.usb-OPPO_OPPO_HA-2_USB_AUDIO_2.0_DAC-00.analog-stereo'"
alias connectbose="bluetoothctl connect 4C:87:5D:A3:AC:5B"
alias performance="echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor"
alias powersave="echo powersave | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor"
alias pyr="pyright ."
alias next="npx next"
alias nd="npm run dev"
alias nbs="npm run build && npm run start"
alias vercel="npx vercel"


PROMPT="%F{red}%n%f"
PROMPT+="@"
PROMPT+="%F{blue}${${(%):-%m}#zoltan-}%f"
PROMPT+=" "
PROMPT+="%F{yellow}%1~ %f"
PROMPT+="$ "

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export TERM=xterm-256color

