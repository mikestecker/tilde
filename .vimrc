set nocompatible                                          " We aren't interested in backward compatability with vi, set before all other

" ====================
" Plugins
" ====================

call plug#begin('~/.vim/plugged')

" IDE-like features
Plug 'kien/ctrlp.vim'                                     " Easily open files
Plug 'mkitt/tabline.vim'                                  " Easier control of tabline
Plug 'airblade/vim-gitgutter'                             " Keep track of additions, subtractions, and modifications
Plug 'vim-scripts/gitignore'                              " Sync wildignore with .gitignore
Plug 'tpope/vim-commentary'                               " tpope's comment plugin
Plug 'tpope/vim-vinegar'                                  " Salad dressing for netrw
Plug 'junegunn/goyo.vim'                                  " Distraction-free writing for Vim
Plug 'scrooloose/nerdtree'                                " Treeview
Plug 'neoclide/coc.nvim', {'branch': 'release'}           " VSCode-style code completion

" Syntax
Plug 'pangloss/vim-javascript'
Plug 'leafgarland/typescript-vim'
Plug 'maxmellon/vim-jsx-pretty'
Plug 'jxnblk/vim-mdx-js'

" Tmux
Plug 'christoomey/vim-tmux-navigator'

" Themes
Plug 'jonathanfilip/vim-lucius'
Plug 'jlong/luscious.vim'

" Misc plugins
Plug 'jlong/sass-convert.vim'                             " Easily convert between Sass syntaxes
Plug 'tpope/vim-git'                                      " Basic git support
Plug 'tpope/vim-fugitive'                                 " Tim Pope's amazing git plugin
Plug 'bronson/vim-trailing-whitespace'                    " Whitespace plugin
" Plug 'guns/xterm-color-table.vim'                       " Show color table for adjusting Vim themes

" runtime ftplugin/man.vim                                " :Man plugin

call plug#end()


" ====================
" General
" ====================

" Auto-reload file changes from disk
set autoread

" Keyboard
set timeoutlen=1000
set ttimeoutlen=0

" File types
filetype plugin indent on                                  " Required for Vundle
autocmd BufRead,BufNewFile Capfile set filetype=ruby       " recognize Capfile
autocmd BufRead,BufNewFile Gemfile set filetype=ruby       " recognize Gemfile

" Search
set ignorecase smartcase                                   " Ignore case in search patterns, unless uppercase letters used
set incsearch                                              " Incremental searching with /
set hlsearch                                               " Highlight searches

" Splits
set splitbelow                                             " Split below
set splitright                                             " Vsplit right

" Indentation
set smartindent
set expandtab                                              " Expand tabs to spaces
set shiftwidth=2
set tabstop=2
set smarttab

" Don't write eol characters
set nofixendofline

" Directories
set backupdir=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp        " Backup Dir
set directory=~/.vim-tmp/,~/.tmp/,~/tmp/,/var/tmp/,/tmp/   " Swapfile Dir

" Word wrap
set nowrap                                                 " Don't wrap lines longer than window width
set linebreak                                              " Wrap on words

" Syntax highlighting
syntax enable                                              " Enable syntax higlighting
set t_Co=256                                               " Turn 256 color support on
set background=dark
colorscheme luscious

" User interface
set visualbell
set cursorline                                             " highlight the current line
set winheight=15
set winminheight=0

" Other settings
set history=1000                                           " Lots of command line history
set autowrite
set wildmode=list:longest                                  " Helpful command tab completion
set wildcharm=<Tab>                                        " :h wildcharm
set wildignore+=public/assets/**,build/**,vendor/**,Libraries/**,coverage/**,tmp/**,db/sphinx/**,db/mongodb/**,logs/**,db/*.sqlite*
set backspace=start,indent,eol                             " Allow delete across lines
set fileformats=unix,mac,dos
set showmatch                                              " Show matching brackets
set nojoinspaces                                           " Don't join lines with 2 spaces after a period
set scrolloff=2                                            " Scroll up or down with at least 2 lines on either side of the cursor
set spelllang=en_us                                        " Spelling!
set nofoldenable                                           " disable folding


" Status line
let g:airline_powerline_fonts=1                            " use airline with powerline fonts
let g:airline_theme='badwolf'                              " airline theme
set laststatus=2                                           " always show status line
set statusline=
set statusline+=%-3.3n\                                    " buffer number
set statusline+=%f%{&modified?'+':''}\                     " filename (+ modified)
set statusline+=%h%r%w\                                    " status flags
set statusline+=%=                                         " right align remainder
set statusline+=\[%{strlen(&ft)?&ft:'none'}]\ \ \          " file type
set statusline+=%-14(%l,%c%V%)                             " line, character
set statusline+=%<%P                                       " file position

" Mouse
set mouse=a

" GUI Options
if has("gui_running")
  set guioptions+=TlRLrb
  set guioptions-=TlRLrb
  set guifont=Source\ Code\ Pro\ for\ Powerline:h14
  set antialias
  set transparency=2
endif

" Our whitespace plugin highlights it by default. Let's turn this off for now:
" autocmd BufRead * highlight ExtraWhitespace ctermbg=bg guibg=bg

" Expand all folds
autocmd BufRead * call feedkeys("zR")

" Make sure we can use HTML snippets in erb
" autocmd BufNewFile,BufRead *.html.erb set filetype=eruby.html

" Make pasting work without indentation in terminal
if &term =~ "xterm.*"
    let &t_ti = &t_ti . "\e[?2004h"
    let &t_te = "\e[?2004l" . &t_te
    function XTermPasteBegin(ret)
        set pastetoggle=<Esc>[201~
        set paste
        return a:ret
    endfunction
    map <expr> <Esc>[200~ XTermPasteBegin("i")
    imap <expr> <Esc>[200~ XTermPasteBegin("")
endif


" ====================
" Coc
" ====================

let g:coc_global_extensions = ['coc-tsserver']

if isdirectory('./node_modules') && isdirectory('./node_modules/prettier')
  let g:coc_global_extensions += ['coc-prettier']
endif

if isdirectory('./node_modules') && isdirectory('./node_modules/eslint')
  let g:coc_global_extensions += ['coc-eslint']
endif

function! ShowDocIfNoDiagnostic(timer_id)
  if (coc#float#has_float() == 0 && CocHasProvider('hover') == 1)
    silent call CocActionAsync('doHover')
  endif
endfunction

function! s:show_hover_doc()
  call timer_start(200, 'ShowDocIfNoDiagnostic')
endfunction

autocmd CursorHoldI * :call <SID>show_hover_doc()
autocmd CursorHold * :call <SID>show_hover_doc()


" ==================
" Buffers
" ==================

set hidden                                                 " Leave buffers even when they're changed

autocmd BufReadPost *                                      " Restore cursor position
  \ if line("'\"") > 1 && line("'\"") <= line("$") |
  \   exe "normal! g`\"" |
  \ endif

if v:version >= 703                                        " Persistent UNDO, only available in Vim 7.3 or greater
  set undofile
  set undodir=~/.vim/.undo
endif

set clipboard+=unnamed                                     " Cause yank, p, etc to work with the System clipboard (requires +clipboard)


" ==================
" Custom commands
" ==================

" Handy for testing new .vimrc changes
function! RunCommands()
    exe getline('.')
endfunction
command -range RunCommands <line1>,<line2>call RunCommands()

" Clear the backup dir
command ClearBackups execute "!rm -rf ~/.vim-tmp/*"

" Wipeout inactive buffers
function! WipeoutInactiveBuffers()
  " From tabpagebuflist() help, get a list of all buffers in all tabs
  let tablist = []
  for i in range(tabpagenr('$'))
    call extend(tablist, tabpagebuflist(i + 1))
  endfor

  " Below originally inspired by Hara Krishna Dara and Keith Roberts
  " http://tech.groups.yahoo.com/group/vim/message/56425
  let nWipeouts = 0
  for i in range(1, bufnr('$'))
    if bufexists(i) && !getbufvar(i,"&mod") && index(tablist, i) == -1
      " bufno exists AND isn't modified AND isn't in the list of buffers open in windows and tabs
      silent exec 'bwipeout' i
      let nWipeouts = nWipeouts + 1
    endif
  endfor
  echomsg nWipeouts . ' buffer(s) wiped out'
endfunction
command Wipeout call WipeoutInactiveBuffers()

" Project-wide search with Git. Use <q-args> so multi-word patterns like
" `:G file not found` arrive as a single pattern instead of being split
" into a pattern + path filters.
func! GitGrep(pattern)
  let output = systemlist('git grep -n -- ' . shellescape(a:pattern))
  cgetexpr output
  if len(output) > 0
    copen
  else
    echo 'GitGrep: no matches for ' . a:pattern
  endif
  redraw!
endfun
command! -nargs=+ G call GitGrep(<q-args>)

" Visual Mode searching
xnoremap * :<C-u>call <SID>VSetSearch('/')<CR>/<C-R>=@/<CR><CR>
xnoremap # :<C-u>call <SID>VSetSearch('?')<CR>?<C-R>=@/<CR><CR>

function! s:VSetSearch(cmdtype)
  let temp = @s
  norm! gv"sy
  let @/ = '\V' . substitute(escape(@s, a:cmdtype.'\'), '\n', '\\n', 'g')
  let @s = temp
endfunction


" ==================
" Mappings
" ==================

let mapleader = ","                                        " A way to make command mapping shorter; see <leader> throughout this
imap ;; <Esc>

" Completion
inoremap <expr> <CR> pumvisible() ? "\<C-Y>" : "\<CR>"

" Paste linewise after with indent
" nnoremap <leader>p :put *<cr>`[v`]=

" move between windows
" nnoremap <c-j> <c-w>j
" nnoremap <c-k> <c-w>k
" nnoremap <c-h> <c-w>h
" nnoremap <c-l> <c-w>l

" move and maximize
" nnoremap <d-j> <c-w>j<c-w>_
" nnoremap <d-k> <c-w>k<c-w>_

" html template
nmap ,html _i<!doctype html><CR><html><CR><head><CR><TAB><meta charset="UTF-8"><CR><title></title><CR><link rel="stylesheet" href=""><CR><BS></head><CR><body><CR><CR><TAB><script src=""></script><CR><BS></body><CR></html><ESC>kkkkkkklla

" resize windows
nmap <S-Left> <C-W><<C-W><
nmap <S-Right> <C-W>><C-W>>
nmap <S-Up> <C-W>+<C-W>+
nmap <S-Down> <C-W>-<C-W>-
nmap <C--> <C-W>_
nmap <C-_> <C-W>_

" split explore hotkey
nmap <F2> <leader>d<CR>

" toggle line numbers
nmap <F3> :set nonumber!<CR>

" toggle wordwrap
nmap <F4> :set nowrap!<CR>

" Goyo
let g:goyo_margin_top=1
let g:goyo_margin_bottom=1
map <F5> :Goyo<CR>

" vimrc Hotkey
map <F6> :tabnew<CR><C-L>:e ~/.vimrc<CR>

" Notes
let g:notes_directories = ['~/Dropbox/Notes']
map <F7> :Note master<CR>

" toggle spelling
nmap <F8> :set spell!<CR>

" Ctrl-p
silent! nmap <unique> <silent> <Leader>f :CtrlP<CR>
nnoremap <leader>F :CtrlPClearAllCaches<CR>:CtrlP<CR>
set wildignore+=public/assets/**,build/**,vendor/plugins/**,vendor/linked_gems/**,vendor/gems/**,vendor/rails/**,vendor/ruby/**,vendor/cache/**,Libraries/**,coverage/**
let g:ctrlp_max_height=20
let g:ctrlp_user_command = ['.git/', 'cd %s && git ls-files . -co --exclude-standard']
let g:ctrlp_custom_ignore = {
  \ 'dir':  '\v(\.git|\.yardoc|log|tmp|build)$',
  \ 'file': '\v\.(so|dat|DS_Store|png|gif|jpg|jpeg)$'
  \ }

" NERDtree
let NERDTreeWinSize=31
let NERDTreeMinimalUI=1
let NERDTreeDirArrows=1
let NERDTreeHijackNetrw=0
let NERDTreeIgnore=['tmp$[[dir]]', 'build$[[dir]]']
map <leader>nt :NERDTree<space>
map <leader>nb :NERDTreeFromBookmark<space>
map <leader>d :NERDTreeToggle
map <leader>R :NERDTreeFind<CR>
