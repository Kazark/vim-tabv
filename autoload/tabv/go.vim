if exists('g:tabv_go_loaded')
    finish
endif

let g:tabv_go_source_extension=".go"
let g:tabv_go_unittest_extension="_test.go"

function tabv#go#OpenTab(name)
    call tabv#TabEdit(a:name . g:tabv_go_source_extension)
    call tabv#VerticalSplit(a:name . g:tabv_go_unittest_extension)
endfunction

function tabv#go#GopathAsCrossPlatformRegex()
    return escape(substitute($GOPATH, '/', '[/\\]', 'g'), ' \')
endfunction

function tabv#go#BeginsWithGopath(path)
    return match(a:path, tabv#go#GopathAsCrossPlatformRegex()) == 0
endfunction

function tabv#go#CurrentDirectoryIsChildOfGopath()
    return $GOPATH != '' && tabv#go#BeginsWithGopath(getcwd())
endfunction

