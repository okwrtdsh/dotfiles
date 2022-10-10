# -------------------------------------
# Macの設定
# -------------------------------------
# iTerm2のタブ名を変更する
function title {
    echo -ne "\033]0;"$*"\007"
}

# エディタ
export EDITOR=/usr/local/bin/vim

# ページャ
#export PAGER=/usr/local/bin/vimpager
#export MANPAGER=/usr/local/bin/vimpager
export PAGER=less
export MANPAGER=less

# -------------------------------------
# macvimの設定
# -------------------------------------
alias gvim="open -a MacVim.app"

# -------------------------------------
# pyenvの設定
# -------------------------------------
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if [ $commands[pyenv] ]; then eval "$(pyenv init --path)"; fi
if [ $commands[pyenv] ]; then eval "$(pyenv virtualenv-init -)"; fi


# -------------------------------------
# nodebrewの設定
# -------------------------------------
export PATH=$HOME/.nodebrew/current/bin:$PATH

# -------------------------------------
# k8sの設定
# -------------------------------------

if [ $commands[kubectl] ]; then source <(kubectl completion zsh); fi
if [ $commands[minikube] ]; then source <(minikube completion zsh); fi
if [ $commands[helm] ]; then source <(helm completion zsh); fi
alias k=kubectl
alias kg="kubectl get"
alias kubedebug="kubectl run --rm -i --tty --image busybox x"

# -------------------------------------
# PostgreSQL設定
# -------------------------------------
export PGDATA=/usr/local/var/postgres

# -------------------------------------
# MySQL設定
# -------------------------------------
export PATH="/usr/local/opt/mysql-client/bin:$PATH"

# -------------------------------------
# Mac用のエイリアス
# -------------------------------------
alias g++="g++ -std=c++11"
function findword() {
    grep -r $1 ./
}
function mktouch() {
    mkdir -p "$(dirname $1)"
    /usr/bin/touch "$1"
}
alias touch=mktouch

function ping() {
  ip=$(echo "$1")
  /sbin/ping ${ip:='8.8.8.8'}
}

function pping() {
  nc -v -w 1 $1 -z ${2:-22}
}

function digshort() {
  dig $1 +short
}

alias free='top -l 1 -s 0 | /usr/bin/grep PhysMem'

# cdしたあとで、自動的に ls する
function chpwd() {
  ls -1
}

alias ..='cd ..'

gitresetbranch(){
  git branch -r --merged develop | grep -v -e master -e develop | sed -e 's%[0-9]*: *%%' | xargs -I% git branch -d -r %
  git branch --merged develop | grep -vE '^\*|master$|develop$' | sed -e 's%[0-9]*: *%%' | xargs -I % git branch -d %
  git branch -a
}

alias clock="watch -n 1 -t 'date +\"%Y/%m/%d %H:%M:%S\"'"

function mkmd() {
  touch $(date +'%m%d.md')
}

function sp() {
  spinners=(⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏)
  cmd="$@"
  tmp_log=$(mktemp)
  (eval "COLUMNS=$COLUMNS CLICOLOR_FORCE=1 $cmd" > $tmp_log 2>&1 & id=$!
  while [[ $jobstates =~ $id ]]
  do
    for spinner in "${spinners[@]}"
    do
      sleep 0.05
      printf "\r\033[$fg[white]$spinner$reset_color  $cmd" 2>/dev/null
      [[ $jobstates =~ $id ]] || break
    done
  done)
  printf "\r$fg_bold[green]\U2714$reset_color  $cmd\n"
  cat $tmp_log
  rm -f $tmp_log
}

sshap_northeast_1() {
  ssh "ec2-user@$1" -i ~/pem/ap-northeast-1.pem
}

sshsa_east_1() {
  ssh "ec2-user@$1" -i ~/pem/sa-east-1.pem
}

sshus_east_1() {
  ssh "ec2-user@$1" -i ~/pem/us-east-1.pem
}

ssheu_west_1() {
  ssh "ec2-user@$1" -i ~/pem/eu-west-1.pem
}

_sshap_northeast_1() {
  _values $(echo "PublicIP " $(aws ec2 describe-instances --filters Name=instance-state-name,Values=running --query 'Reservations[].Instances[].[PublicIpAddress,InstanceId,InstanceType,LaunchTime,Tags[?Key==`Name`].Value|[0]]' | jq -r '.[] | @csv' | sed -e 's/"//g' | awk -F, '{print $1"["$2"......"$3"......"$4"......"$5"]"}' | tr \\n " "))
}
compdef _sshap_northeast_1 sshap_northeast_1

sshec2() {
  if [ $# -lt 2 ]; then
    echo "Syntax Error: sshec2 REGION IP_ADDRESS" >&2
  elif [ ! -f ~/pem/$1.pem ]; then
    echo "PEM file not found: ~/pem/$1.pem" >&2
  else
    ssh -A "${3:-ec2-user}@$2" -i ~/pem/$1.pem
  fi
}

# https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.zsh
_sshec2() {
  _arguments \
    '1:region:->region' \
    '2:ip:->ip' \
    '3:user:->user'

  case $state in
    region) __sshec2_regions;;
    ip) __sshec2_ips $words;;
    user) __sshec2_users;;
  esac
}

__sshec2_regions() {
  # regions="ap-northeast-1 ap-northeast-3 us-east-1 us-east-2 us-west-1 us-west-2 eu-central-1 eu-west-1 eu-west-2 eu-south-1 eu-west-3 eu-north-1 ap-east-1 ap-south-1 ap-northeast-2 ap-southeast-1 ap-southeast-2 ca-central-1 me-south-1 sa-east-1 af-south-1"
  regions="ap-northeast-1 ap-northeast-3 us-east-1 us-east-2 us-west-1 us-west-2"
  _values $(echo "REGION $regions")
}
__sshec2_ips() {
  region=$2
  _values $(echo "PublicIP " $(aws --region $region ec2 describe-instances --filters Name=instance-state-name,Values=running --query 'Reservations[].Instances[].[PublicIpAddress,InstanceId,InstanceType,LaunchTime,Tags[?Key==`Name`].Value|[0]]' | jq -r '.[] | @csv' | sed -e 's/"//g' | awk -F, '{print $1"["$2"......"$3"......"$4"......"$5"]"}' | tr " " "_" | tr \\n " "))
}

__sshec2_users() {
  users="ec2-user centos ubuntu"
  _values $(echo "USER $users")
}

compdef _sshec2 sshec2


sftpec2() {
  if [ $# -lt 2 ]; then
    echo "Syntax Error: sftpec2 REGION IP_ADDRESS" >&2
  elif [ ! -f ~/pem/$1.pem ]; then
    echo "PEM file not found: ~/pem/$1.pem" >&2
  else
    sftp -i ~/pem/$1.pem "${3:-ec2-user}@$2"
  fi
}

_sftpec2() {
  _arguments \
    '1: :__sshec2_regions' \
    '2: :->ip' \
    '3: :__sshec2_users'

  pyenv activate work >/dev/null 2>&1
  case $state in
    ip) _values $(echo "PublicIP " $(aws ec2 describe-instances --filters Name=instance-state-name,Values=running --query 'Reservations[].Instances[].[PublicIpAddress,InstanceId,InstanceType,LaunchTime,Tags[?Key==`Name`].Value|[0]]' | jq -r '.[] | @csv' | sed -e 's/"//g' | awk -F, '{print $1"["$2"......"$3"......"$4"......"$5"]"}' | tr \\n " ")) ;;
  esac
  pyenv deactivate >/dev/null 2>&1
}

compdef _sftpec2 sftpec2

runinstances() {
  if [ $# -lt 5 ]; then
    echo "Syntax Error: runinstances REGION INSTANCE_TYPE AMI SUBNET SECURITY_GROUP" >&2
  elif [ ! -f ~/pem/$1.pem ]; then
    echo "PEM file not found: ~/pem/$1.pem" >&2
  else
    InstanceId=$(
      aws ec2 run-instances \
        --region $1 \
        --image-id $3\
        --instance-type $2 \
        --key-name $1 \
        --subnet-id $4 \
        --security-group-ids $5 \
        --count 1 \
        --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=${3}-${2}},{Key=auto-delete,Value=no}]" \
        --associate-public-ip-address | jq -r '.Instances[0].InstanceId'
    )
    aws ec2 describe-instances \
      --region $1 \
      --instance-ids $InstanceId \
      --query 'Reservations[0].Instances[0].[InstanceId, PublicIpAddress, PrivateIpAddress]' \
      --output text \
      | awk -v REGION=$1\
      '{print "InstanceId:\t"$1"\nPublicIpAddress:\t"$2"\nPrivateIpAddress:\t"$3"\n\nsshec2 "REGION" "$2"\nssh -A -i ~/pem/"REGION".pem ec2-user@"$2"\naws ssm start-session --target "$1"\n"}'
  fi
}

_runinstances() {
  _arguments \
    '1:region:->region' \
    '2:instance_type:->instance_type' \
    '3:ami:->ami' \
    '4:subnet:->subnet' \
    '5:security_group:->security_group'
  case $state in
    region) __runinstances_regions;;
    instance_type) __runinstances_instance_type;;
    ami) __runinstances_ami $words;;
    subnet) __runinstances_subnet $words;;
    security_group) __runinstances_security_group $words;;
  esac

}
__runinstances_regions() {
  regions="ap-northeast-1 ap-northeast-3 us-east-1 us-east-2 us-west-1 us-west-2"
  _values $(echo "REGION $regions")
}

__runinstances_instance_type() {
  instance_types="t3.micro t2.micro"
  _values $(echo "INSTANCE_TYPE $instance_types")
}
__runinstances_ami() {
  region=$2
  parameter_names=$(aws --region $region ssm get-parameters-by-path --path /aws/service/ami-amazon-linux-latest --query 'Parameters[].Name' --output text | tr '\t' '\n' | grep -E -e "hvm-x86_64-gp2$" -e "-x86_64$" | grep -v "minimal" | sort -r | tr \\n " ")
  cmd='aws --region '$region' ssm get-parameters --names '$parameter_names' --query '\''Parameters[].[Value,Name]'\'' --output text | awk '\''{print $1"["$2"]"}'\'' | tr \\n " "'
  amis=$(bash -c $cmd)
  _values $(echo "AMI $amis")
}

__runinstances_subnet() {
  region=$2
  cmd='aws --region '$region' ec2 describe-subnets --query '\''Subnets[].[SubnetId,VpcId,Tags|[?Key==`Name`].Value|[0]]'\'' --output text | sort -k 2 -r | awk '\''{print $1"["$2"......"$3"]"}'\'' | tr \\n " "'
  subnets=$(bash -c $cmd)
  _values $(echo "SUBNET $subnets")
}

__runinstances_security_group() {
  region=$2
  subnet=$5
  vpc=$(aws --region $region ec2 describe-subnets --subnet-ids $subnet --query 'Subnets[0].VpcId' --output text)
  cmd='aws --region '$region' ec2 describe-security-groups --query '\''SecurityGroups[].[GroupId,GroupName]'\'' --filters '\''Name=vpc-id,Values='$vpc\'' --output text | tr " " "_" | sort -k 2 | awk '\''{print $1"["$2"]"}'\'' | tr \\n " "'
  security_groups=$(bash -c $cmd)
  _values $(echo "SECURITY_GROUP $security_groups")
}

compdef _runinstances runinstances

# AWS CLI 補完
# source "$(dirname $(which aws_completer))/aws_zsh_completer.sh"
autoload bashcompinit
bashcompinit
complete -C $(which aws_completer) aws


pwgen() {
  /usr/local/bin/pwgen $@ | pbcopy | pbpaste
}


# -------------------------------------
# その他設定
# -------------------------------------

export FPATH="$HOME/dotfiles/zsh/functions:$FPATH"


# portの設定
export PATH=/opt/local/bin:/opt/local/sbin:$PATH
export MANPATH=/opt/local/share/man:/opt/local/man:$MANPATH

export XDG_CONFIG_HOME="$HOME/.config"

# Here, with vim, ignore .(aux|log|pdf) files
zstyle ':completion:*:*:vim:*' file-patterns '^*.(aux|log|pdf|bbl|dvi|blg):source-files' '*:all-files'
zstyle ':completion:*:*:open:*' file-patterns '^*.(aux|log|tex|bbl|dvi|blg):source-files' '*:all-files'

# alias vim=nvim
function vim() {
  if [ $# -gt 0 ]; then
    nvim $@
  else
    tmp_file="$(date +/tmp/temp-%Y%m%d%H%M%S.txt)"
    touch $tmp_file
    nvim $tmp_file
  fi
}

alias ssh='ssh -o ServerAliveInterval=60'



case_search () {
  local q=()
  local param
  for w in "$@"
  do
    w=${w//-/\\-}
    q+=("(subject:\"${w}\"|topic:\"${w}\"|correspondence:\"${w}\")")
  done
  param="$(printf "%s\n" "${q[@]}" | paste -sd '&' - | od -v -An -tx1 | awk 'NF{OFS="%";$1=$1;print "%"$0}' | tr '[:lower:]' '[:upper:]' | tr -d '\n')"
  open "https://command-center.support.aws.a2z.com/case-console#/search/cases?search=$param"
}

case_search_linux () {
  local q=()
  local param
  q+=("(queue:\"aws\-support\-tier1\-compute\-linux@amazon.co.jp\"|queue:\"aws\-support\-tier2\-compute\-linux@amazon.co.jp\"|queue:\"aws\-support\-tier3\-compute\-linux@amazon.co.jp\")")
  for w in "$@"
  do
    w=${w//-/\\-}
    q+=("(subject:\"${w}\"|topic:\"${w}\"|correspondence:\"${w}\")")
  done
  param="$(printf "%s\n" "${q[@]}" | paste -sd '&' - | od -v -An -tx1 | awk 'NF{OFS="%";$1=$1;print "%"$0}' | tr '[:lower:]' '[:upper:]' | tr -d '\n')"
  open "https://command-center.support.aws.a2z.com/case-console#/search/cases?search=$param"
}
