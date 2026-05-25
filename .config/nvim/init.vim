" Bridge neovim to the vim config so there's a single source of truth.
set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc
