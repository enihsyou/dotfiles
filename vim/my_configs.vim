let $LANG='zh_CN.UTF-8'
language zh_CN.UTF-8
set langmenu=zh_CN.UTF-8

if has("mac") || has("macunix")
    set guifont=VictorMono\ Nerd\ Font:h24
    set guifontwide=Sarasa\ Mono\ SC:h24
endif

set mouse=a

set grepprg=rg\ --vimgrep\ --smart-case\ --follow

" nnoremap <esc><esc> :noh<return><esc>

" remove some mapping comes with vimrc
silent! unmap <space>
silent! unmap <C-space>

set nu

" enable errorbell but no visualbell
" https://vim.fandom.com/wiki/Disable_beeping
set errorbells

" always show command on the way
set showcmd

" https://sw.kovidgoyal.net/kitty/faq/#using-a-color-theme-with-a-background-color-does-not-work-well-in-vim
let &t_ut=''

" https://vi.stackexchange.com/questions/1983/how-can-i-get-vim-to-stop-putting-comments-in-front-of-new-lines
" augroup Format-Options
"     autocmd!
"     autocmd BufEnter * setlocal formatoptions-=c formatoptions-=r formatoptions-=o
" augroup END

