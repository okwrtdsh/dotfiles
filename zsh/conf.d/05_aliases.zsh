# -------------------------------------
# エイリアス
# -------------------------------------

# -n 行数表示, -I バイナリファイル無視, svn関係のファイルを無視
alias grep="grep --color -n -I --exclude='*.svn-*' --exclude='entries' --exclude='*/cache/*'"

# ls
export LSCOLORS=xefxcxdxbxegedabagacad
alias ls="ls -G" # color for darwin
alias l="ls -l"
alias ll="ls -la"
alias la="ls -a"
alias l1="ls -1"

# tree
alias tree="tree -NC" # N: 文字化け対策, C:色をつける

# -------------------------------------
# マイエイリアス
# -------------------------------------

alias freeze="pip freeze"
alias runserver="python manage.py runserver"
function reset_db() {
  python manage.py flush --noinput
  python manage.py loaddata **/fixtures/*.json
}

# -------------------------------------
# その他
# -------------------------------------

# cdしたあとで、自動的に ls する
function chpwd() { ls -1 }

# 空のディレクトリに.gitkeepを追加する
alias gitkeep="find . -name .git -prune -o -type d -empty -exec touch {}/.gitkeep \;"

