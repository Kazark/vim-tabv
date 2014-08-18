if exists('g:tabv_python_loaded')
    finish
endif

let g:tabv_python_source_extension=".py"
let g:tabv_python_unittest_extension="Tests.py"

function tabv#python#OpenTab(name)
    call tabv#TabEdit(a:name . g:tabv_python_source_extension)
    call tabv#VerticalSplit(a:name . g:tabv_python_unittest_extension)
endfunction

let g:tabv_python_loaded=1
