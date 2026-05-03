" 标准字体渲染地太粗了
set guifont=Maple_Mono_NF_CN:h12:cANSI:qDRAFT

set renderoptions=type:directx,gamma:1.0,geom:1,renmode:5,taamode:2

" https://stackoverflow.com/questions/19754849/vim-syntax-highlighting-does-not-work
" activates filetype detection
filetype plugin indent on

" activates syntax highlighting among other things
syntax on

set nocompatible        " use vim defaults
set scrolloff=3         " keep 3 lines when scrolling
set ai                  " set auto-indenting on for programming
set nofixendofline      " do not add eol to binary file

set showcmd             " display incomplete commands
set nobackup            " do not keep a backup file
set number              " show line numbers
set relativenumber      " show relative line numbers
set ruler               " show the current row and column

augroup numbertoggle
    autocmd!
    autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu && mode() != "i" | set rnu   | endif
    autocmd BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu                  | set nornu | endif
augroup END

set hlsearch            " highlight searches
set incsearch           " do incremental searching
set showmatch           " jump to matches when entering regexp
set ignorecase          " ignore case when searching
set smartcase           " no ignorecase if Uppercase char present
nnoremap <leader><space> :nohlsearch<CR>

set tabstop=4           " spaces to be inserted when press tab in insert mode
set shiftwidth=4        " columns to be indented when using >>

" set cursor style to block
" https://vimhelp.org/term.txt.html#termcap-cursor-shape
set termguicolors
if (&term =~ 'xterm' || &term == 'win32') && &t_Co > 16
    "  1 = blinking block,        2 = steady block
    "  3 = blinking underline,    4 = steady underline
    "  5 = blinking vertical bar, 6 = steady vertical bar
    let &t_SI = "\e[5 q"   " cursor in insert mode
    let &t_EI = "\e[2 q"   " cursor in normal mode
    let &t_SR = "\e[3 q"   " cursor in replace mode
    let &t_ti ..= "\e[2 q"  " cursor when vim starts
    let &t_te ..= "\e[0 q"  " cursor when vim exits
endif

" 环境变量来自 PSHelper_Environment.ps1 自定义脚本
if $AppUseLightTheme == '1'
    set background=light
endif
