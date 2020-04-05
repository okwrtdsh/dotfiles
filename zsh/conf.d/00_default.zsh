# -------------------------------------
# 環境変数
# -------------------------------------

# SSHで接続した先で日本語が使えるようにする
export LC_CTYPE=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# エディタ
# export EDITOR=/usr/local/bin/vim

# ページャ
# export PAGER=/usr/local/bin/vimpager #
# export MANPAGER=/usr/local/bin/vimpager #
export PAGER=/usr/bin/less


# -------------------------------------
# zshのオプション
# -------------------------------------

## 補完機能の強化
# autoload -U compinit
# compinit

autoload -Uz compinit && compinit -u
zstyle ':completion:*' menu select interactive
setopt menu_complete

## 補完で大文字小文字の区別をしない
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' '+m:{A-Z}={a-z}' '+r:|[-_.]=**'

## 入力しているコマンド名が間違っている場合にもしかして：を出す。
# setopt correct

# ビープを鳴らさない
setopt nobeep

## 色を使う
setopt prompt_subst
zstyle ':completion:*' list-colors 'di=44' 'ln=35' 'so=32' 'ex=31' 'bd=46;34' 'cd=43;34'

## ^Dでログアウトしない。
setopt ignoreeof

## バックグラウンドジョブが終了したらすぐに知らせる。
setopt no_tify

# 補完
## タブによるファイルの順番切り替えをしない
unsetopt auto_menu

# cd -[tab]で過去のディレクトリにひとっ飛びできるようにする
setopt auto_pushd

# ディレクトリ名を入力するだけでcdできるようにする
# setopt auto_cd
