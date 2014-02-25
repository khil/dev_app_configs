setlocal tabstop=4
setlocal shiftwidth=4
setlocal expandtab
setlocal autoindent
setlocal nosmartindent
setlocal smarttab
setlocal formatoptions=croql

cd $USERPROFILE/src/python

" pymode plugin settings
let g:pymode = 1
let g:pymode_warnings = 1
let g:pymode_trim_whitespaces = 1
let g:pymode_options = 1
let g:pymode_python = 'python3'
let g:pymode_folding = 1
let g:pymode_virtualenv = 1

" code folding
set foldmethod=indent
set foldlevel=99

inoremap __    ____<Left><Left>


" highlight text of lines over 80 characters in length
highlight OverLength guibg=red guifg=white
match OverLength /\%80v.\+/
