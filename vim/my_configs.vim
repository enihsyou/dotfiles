let $LANG='zh_CN.UTF-8'
language zh_CN.UTF-8
set langmenu=zh_CN.UTF-8

if has("mac") || has("macunix")
    set guifont=VictorMono\ Nerd\ Font:h16
    set guifontwide=Sarasa\ Mono\ SC:h16
endif

set mouse=a

set grepprg=rg\ --vimgrep\ --smart-case\ --follow

nnoremap <esc><esc> :noh<return><esc>
