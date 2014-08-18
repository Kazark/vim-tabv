if exists('g:tabv_cxx_loaded')
    finish
endif

let g:tabv_cplusplus_source_directory="src"
let g:tabv_cplusplus_source_extension=".cpp"
let g:tabv_cplusplus_include_directory="inc"
let g:tabv_cplusplus_include_extension=".hpp"
let g:tabv_cplusplus_unittest_directory="unittest"
let g:tabv_cplusplus_unittest_extension="Tests.cpp"

" This is for the OpenTabCPlusPlus function, which will not open a source file
" if a name is suffixed with <>, i.e. Tabcxxv List<> will only open, say,
" inc/List.hpp and unittest/ListTests.cpp, vertically split
let g:tabv_generic_regex = "<>$"

function tabv#cxx#OpenTab(name)
    if match(a:name, g:tabv_generic_regex) == -1
        call tabv#TabEdit(tabv#BuildPath(g:tabv_cplusplus_source_directory, a:name, g:tabv_cplusplus_source_extension))
        call tabv#VerticalSplit(tabv#BuildPath(g:tabv_cplusplus_include_directory, a:name, g:tabv_cplusplus_include_extension))
        call tabv#HorizontalSplit(tabv#BuildPath(g:tabv_cplusplus_unittest_directory, a:name, g:tabv_cplusplus_unittest_extension))
    else
        let l:name = substitute(a:name, g:tabv_generic_regex, "", "")
        call tabv#TabEdit(tabv#BuildPath(g:tabv_cplusplus_include_directory, l:name, g:tabv_cplusplus_include_extension))
        call tabv#VerticalSplit(tabv#BuildPath(g:tabv_cplusplus_unittest_directory, l:name, g:tabv_cplusplus_unittest_extension))
    endif
endfunction

let g:tabv_cxx_loaded=1
