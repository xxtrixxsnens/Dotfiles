" Disable compatibility with vi which can cause unexpected issues.
set nocompatible

" Enable type file detection. Vim will be able to try to detect the type of file in use.
filetype on

" Enable plugins and load plugin for the detected file type.
filetype plugin on

" Load an indent file for the detected file type.
filetype indent on

" Turn syntax highlighting on.
syntax on

" Add numbers to each line on the left-hand side.
set number

" Set relativnumber
set relativenumber

" Highlight cursor line underneath the cursor horizontally.
set cursorline

" Highlight cursor line underneath the cursor vertically.
" set cursorcolumn

" Set shift width to 4 spaces.
set shiftwidth=4

" Set tab width to 4 columns.
set tabstop=4

" Use space characters instead of tabs.
set expandtab

" Do not save backup files.
set nobackup

" Do not let cursor scroll below or above N number of lines when scrolling.
" set scrolloff=10

" Do not wrap lines. Allow long lines to extend as far as the line goes.
" set nowrap

" While searching though a file incrementally highlight matching characters as you type.
set incsearch

" Ignore capital letters during search.
set ignorecase

" Override the ignorecase option if searching for capital letters.
" This will allow you to search specifically for capital letters.
set smartcase

" Show partial command you type in the last line of the screen.
set showcmd

" Show the mode you are on the last line.
set showmode

" Show matching words during a search.
set showmatch

" Use highlighting when doing a search.
set hlsearch

" Set the commands to save in history default number is 20.
set history=1000

" Enable auto completion menu after pressing TAB.
set wildmenu

" Make wildmenu behave like similar to Bash completion.
set wildmode=longest:full,full

" There are certain files that we would never want to edit with Vim.
" Wildmenu will ignore files with these extensions.
set wildignore=*.docx,*.jpg,*.png,*.gif,*.pdf,*.pyc,*.exe,*.flv,*.img,*.xlsx

" Automatically create missing directories when saving a file
autocmd BufWritePre * call mkdir(expand('<afile>:p:h'), 'p')


" " FUNCTIONS  ---------------------------------------------------------------- {{{
set tabline=%!MyTabLine()

function! MyTabLine()
  let s = ''
  for i in range(tabpagenr('$'))
    " Tab page number (1-based)
    let tabnr = i + 1

    " Get the current window in tab
    let winnr = tabpagewinnr(tabnr)

    " Get the buffer name of the window in the tab
    let buflist = tabpagebuflist(tabnr)
    let bufnr = buflist[winnr - 1]
    let bufname = bufname(bufnr)

    " If buffer has no name, show directory of buffer's file or current dir
    if bufname == ''
      let name = fnamemodify(getcwd(), ':t')
    else
      let name = fnamemodify(bufname, ':t')
    endif

    if tabnr == tabpagenr()
      let s .= '%#TabLineSel#'  " Highlight current tab
    else
      let s .= '%#TabLine#'
    endif

    " Make tab clickable, show number and name
    let s .= '%' . tabnr . 'T' . ' ' . tabnr . ':'. name . ' '
  endfor

  " Fill the rest of the tabline with TabLineFill
  let s .= '%#TabLineFill#%='
  return s
endfunction
" " }}}

" " PLUGINS ---------------------------------------------------------------- {{{

" " Plugin code goes here.
" call plug#begin('~/.vim/plugged')

"   "https://github.com/dense-analysis/ale
"   Plug 'dense-analysis/ale'

"   " https://github.com/preservim/nerdtree
"   Plug 'preservim/nerdtree'

" call plug#end()
" " }}}
" MAPPINGS --------------------------------------------------------------- {{{

" Set the backslash as the leader key.
let mapleader = " "

" ONLY WORKS WITH A VERSION OF VIM THAT SUPPORTS CLIPBOARD
" Pasting and Copying to the system
if has('clipboard')
  nnoremap y "+y
  xnoremap y "+y
  nnoremap yy "+yy
  nnoremap p "+p
  nnoremap P "+P
  xnoremap p "+p
  xnoremap P "+P
endif
" END OF EXCEPTION FOR VERSION THAT SUPPORTS CLIPBOARD

" Press SPACE+B to jump back to the last cursor position.
nnoremap <leader>b ``

" Type jk to exit insert mode quickly.
inoremap jk <Esc>

" Pressing the letter o will open a new line below the current one.
" Exit insert mode after creating a new line above or below the current line.
nnoremap o o<esc>
nnoremap O O<esc>

" Press ß to get to the end of a line.
nnoremap ß $
vnoremap ß $
omap ß $

" Center the cursor vertically when moving to the next word during a search.
nnoremap n nzz
nnoremap N Nzz

" Yank from cursor to the end of line.
nnoremap Y y$

" Map the F5 key to run a Python script inside Vim.
" I map F5 to a chain of commands here.
" :w saves the file.
" <CR> (carriage return) is like pressing the enter key.
" !clear runs the external clear screen command.
" !python3 % executes the current file with Python.
nnoremap <f5> :w <CR>:!clear <CR>:!python3 % <CR>

" You can split the window in Vim by typing :split or :vsplit.
" Navigate the split view easier by pressing CTRL+j, CTRL+k, CTRL+h, or CTRL+l.
nnoremap <C-j> <c-w>j
nnoremap <C-k> <c-w>k
nnoremap <C-h> <c-w>h
nnoremap <C-l> <c-w>l

" Resize split windows using arrow keys by pressing:
" CTRL+UP, CTRL+DOWN, CTRL+LEFT, or CTRL+RIGHT.
noremap <C-up> <c-w>-
noremap <C-down> <c-w>+
noremap <C-right> <c-w>>
noremap <C-left> <c-w><

" Create a split screen using CTRL+Ö (vertical) and CTRL+Ä (horizontal) when in
" Normal Mode
nnoremap <C-ö> :vsplit<CR>
nnoremap <C-ä> :split<CR>

" You can close a window with CTRL+W
nnoremap <C-w> :close<CR>

" You can open a window with SPACE+w
nnoremap <leader>w :vsplit %:p:h/<C-R>=input('New file name: ')<CR><CR>

" TABS
" MOVEMENT TABS
nnoremap H :tabprevious<CR>
nnoremap L :tabnext<CR>

" Create a new tab in the current dir
nnoremap <leader>t :tabnew %:p:h/<C-R>=input('New file name: ')<CR><CR>

" Open the directory in a new tab
nnoremap <leader>e :tabnew \| cd %:p:h \| Ex<CR>

" Open git in a new terminal
nnoremap <leader>g :silent !kitty fish -c "cd %:p:h && git status; exec fish"<CR>


" NERDTree specific mappings.
" Map the F3 key to toggle NERDTree open and close.
nnoremap <F3> :NERDTreeToggle<cr>


" Open Git in new terminal tab with <leader> g
nnoremap <leader>g :silent !kitty bash -c "cd %:p:h && git status; exec bash"<CR>


" Have nerdtree ignore certain files and directories.
let NERDTreeIgnore=['\.git$', '\.jpg$', '\.mp4$', '\.ogg$', '\.iso$', '\.pdf$', '\.pyc$', '\.odt$', '\.png$', '\.gif$', '\.db$']

" }}}

" VIMSCRIPT -------------------------------------------------------------- {{{

" Enable the marker method of folding.
augroup filetype_vim
    autocmd!
    autocmd FileType vim setlocal foldmethod=marker
augroup END

" If the current file type is HTML, set indentation to 2 spaces.
autocmd Filetype html setlocal tabstop=2 shiftwidth=2 expandtab

" If Vim version is equal to or greater than 7.3 enable undofile.
" This allows you to undo changes to a file even after saving it.
if version >= 703
    set undodir=~/.vim/backup
    set undofile
    set undoreload=10000
endif

" You can split a window into sections by typing `:split` or `:vsplit`.
" Display cursorline and cursorcolumn ONLY in active window.
augroup cursor_off
    autocmd!
    autocmd WinLeave * set nocursorline nocursorcolumn
    autocmd WinEnter * set cursorline cursorcolumn
augroup END

" If GUI version of Vim is running set these options.
if has('gui_running')

    " Set the background tone.
    set background=dark

    " Set the color scheme.
    colorscheme molokai

    " Set a custom font you have installed on your computer.
    " Syntax: set guifont=<font_name>\ <font_weight>\ <size>
    set guifont=Monospace\ Regular\ 12

    " Display more of the file by default.
    " Hide the toolbar.
    set guioptions-=T

    " Hide the the left-side scroll bar.
    set guioptions-=L

    " Hide the the right-side scroll bar.
    set guioptions-=r

    " Hide the the menu bar.
    set guioptions-=m

    " Hide the the bottom scroll bar.
    set guioptions-=b

    " Map the F4 key to toggle the menu, toolbar, and scroll bar.
    " <Bar> is the pipe character.
    " <CR> is the enter key.
    nnoremap <F4> :if &guioptions=~#'mTr'<Bar>
        \set guioptions-=mTr<Bar>
        \else<Bar>
        \set guioptions+=mTr<Bar>
        \endif<CR>

endif

" }}}

" STATUS LINE ------------------------------------------------------------ {{{

" Clear status line when vimrc is reloaded.
set statusline=

" Status line left side.
set statusline+=\ %F\ %M\ %Y\ %R

" Use a divider to separate the left side from the right side.
set statusline+=%=

" Status line right side.
set statusline+=\ ascii:\ %b\ hex:\ 0x%B\ row:\ %l\ col:\ %c\ percent:\ %p%%

" Show the status on the second to last line.
set laststatus=2

" }}}


" EXPLAINATIONS
"
" NAVIGATION
" zo to open a single fold under the cursor.
" zc to close the fold under the cursor.
" zR to open all folds.
" zM to close all folds.
