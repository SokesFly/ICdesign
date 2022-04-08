" sourcr plug vim

" au BufWritePost *.v *.sv *.f *.c,*.cpp,*.h silent! !ctags -R &

set nocompatible

set rtp+=~/.vim/bundle/Vundle.vim

" Display more character
set listchars=eol:$,tab:>-,trail:~,extends:>,precedes:<
set list

" 打开语法高亮
syntax on


" Resverd four blank when change lane.
set shiftwidth=4

" 按下Tab会显示vim的空格数
set tabstop=4

" Tab 转为多少空格
set softtabstop=4
set expandtab

" 关闭提示音
set vb t_vb=

" 在底部显示当前模式 
set showmode 

" 命令模式下显示键入的指令
set showcmd

" 支持使用鼠标
set mouse=a
"if has('mouse')
"    set mouse-=a
"endif


" 使用utf-8编码
set encoding=utf-8

" 启用256色
set t_Co=256

" 开启文件类型检查，并且载入与该类型对应的缩进规则(如.py 文件会去找~/.vim/indent/python.vim)
filetype indent on

" 显示行号
set number

" 显示光标所在行的行号，其它行都为相对改行的行号
set relativenumber

" 光标所在的当前行高亮
set cursorline

" 设置行宽
set textwidth=120

" 自动拆行,关闭用set nowtap 
" set wrap

" 遇到指定符号(如空格)才拆行
set linebreak

" 指定拆行与编辑窗口右边缘之间空出的字符数
set wrapmargin=2

" 垂直滚动时，光标距离顶部或者底部的位置
set scrolloff=15

" 水平滚动时，光标距离行首或行尾的位置(不拆行时有用)
set sidescrolloff=5

" 是否显示状态栏。0 表示不显示，1 表示只在多窗口时显示，2 表示显示
set laststatus=2

"在状态栏显示光标的当前位置（位于哪一行哪一列）
set ruler

"光标遇到圆括号、方括号、大括号时，自动高亮对应的另一个圆括号、方括号和大括号
set showmatch

" 搜索时，高亮显示匹配结果
set hlsearch

" 输入搜索模式时，每输入一个字符，就自动跳到第一个匹配的结果
" set incsearch

" 搜索时忽略大小写
" set smartcase

" 打开英语单词的拼写检查
" set spell spelllang=en_us
