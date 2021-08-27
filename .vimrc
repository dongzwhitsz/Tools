" 设定默认解码 
set fenc=utf-8 
set fencs=utf-8,usc-bom,euc-jp,gb18030,gbk,gb2312,cp936

set nocompatible 
set clipboard+=unnamed 
filetype on 

set completeopt=longest,menu

filetype plugin on 

filetype indent on 

syntax enable
syntax on 
highlight StatusLine guifg=SlateBlue guibg=Yellow 
highlight StatusLineNC guifg=Gray guibg=White 
setlocal noswapfile 
set bufhidden=hide 
set linespace=0 

set wildmenu 

set ruler 
set rulerformat=%20(%2*%<%f%=\ %m%r\ %3l\ %c\ %p%%%)
set cmdheight=1 

set backspace=2 

set mouse=a 
set selection=exclusive 
set selectmode=mouse,key 
set showmatch 
set matchtime=5
set nohlsearch 

set incsearch 

set statusline=%F%m%r%h%w\[POS=%l,%v][%p%%]\%{strftime(\"%d/%m/%y\ -\ %H:%M\")} 

set autoindent 

set smartindent 

set cindent 

set tabstop=4 

set softtabstop=4 
set shiftwidth=4 
set noexpandtab 

set smarttab 


set nu

