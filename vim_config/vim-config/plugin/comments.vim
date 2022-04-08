
" Add annotation
map <F2> : call AddAnnotation_module()<cr>'s
function AddAnnotation_module()
    call append(line ("."),        "/****************************  Module Instance **********************************/")
    call append(line (".") + 1,    "/********************************************************************************/")
    call append(line (".") + 2,    "/****************************  Module Instance **********************************/")
    let  pos = getpos(".")
    echo pos
    call setpos(".", pos)
endf

" Add annotation
map <F3> : call AddAnnotation_declare()<cr>'s
function AddAnnotation_declare()
    call append(line ("."),        "/****************************  General Comments *********************************/")
    let  pos = getpos(".")
    echo pos
    call setpos(".", pos)
endf

map <F1> : call TitleDet()<cr>'s
function AddTitle()
    call append(0,"/***************************************************************************************")
    call append(1,"* Function: ")
    call append(2,"* Author: SK ")
    call append(3,"* Company: Ltd.JRLC.SK")
    call append(4,"* Right : ")
    call append(5,"* Tel : ")
    call append(6,"* Last modified: ".strftime("%Y-%m-%d %H:%M"))
    call append(7,"* None: ")
    call append(8,"* Filename: ".expand("%:t"))
    call append(9,"* Resverd: ")
    call append(10,"* Description: ")
    call append(11,"**************************************************************************************/")
    echohl WarningMsg | echo "Successful in adding the copyright." | echohl None
endf

function UpdateTitle()
    normal m'
    execute '/* *Last modified:/s@:.*$@\=strftime(":\t%Y-%m-%d %H:%M")@'
    normal ''
    normal mk
    execute '/* *Filename:/s@:.*$@\=":\t\t".expand("%:t")@'
    execute "noh"
    normal 'k
    echohl WarningMsg | echo "Successful in updating the copy right." | echohl None
endfunction

function TitleDet()
    let n=1
    "默认为添加
    while n < 10
        let line = getline(n)
        if line =~ '^\*\s*\S*Last\smodified:\S*.*$'
            call UpdateTitle()
            return
        endif
        let n = n + 1
    endwhile
    call AddTitle()
endfunction
