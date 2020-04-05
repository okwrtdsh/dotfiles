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
export PAGER=/usr/local/bin/vimpager
export MANPAGER=/usr/local/bin/vimpager

# -------------------------------------
# macvimの設定
# -------------------------------------
alias gvim="open -a MacVim.app"

# -------------------------------------
# pyenvの設定
# -------------------------------------
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if [ $commands[pyenv] ]; then eval "$(pyenv init -)"; fi
if [ $commands[pyenv] ]; then eval "$(pyenv virtualenv-init -)"; fi

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

# -------------------------------------
# その他設定
# -------------------------------------

# portの設定
export PATH=/opt/local/bin:/opt/local/sbin:$PATH
export MANPATH=/opt/local/share/man:/opt/local/man:$MANPATH

export XDG_CONFIG_HOME="$HOME/.config"

# Here, with vim, ignore .(aux|log|pdf) files
zstyle ':completion:*:*:vim:*' file-patterns '^*.(aux|log|pdf|bbl|dvi|blg):source-files' '*:all-files'
zstyle ':completion:*:*:open:*' file-patterns '^*.(aux|log|tex|bbl|dvi|blg):source-files' '*:all-files'

alias vim=nvim
