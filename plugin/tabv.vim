" Purpose: Vim global plugin for easily opening relevant groupings of files as a tab
" Author:  Kazark <kazark@zoho.com>
" License: Public domain

if exists('g:tabv_loaded_plugin')
    finish
endif
let g:tabv_loaded_plugin=1

let g:tabv_cxx_source_directory="src"
let g:tabv_cxx_source_extension="cpp"
let g:tabv_cxx_include_directory="inc"
let g:tabv_cxx_include_extension="hpp"
let g:tabv_cxx_unittest_directory="unittest"

function s:OpenTabCxx(name)
    execute "tabe " . g:tabv_cxx_source_directory . "/" . a:name . "." . g:tabv_cxx_source_extension
    execute "vs " . g:tabv_cxx_include_directory . "/" . a:name . "." . g:tabv_cxx_include_extension
    execute "sp " . g:tabv_cxx_unittest_directory . "/" . a:name . "." . g:tabv_cxx_source_extension
endfunction

command -nargs=1 -complete=file Tabv tabe src/<args>.cpp | vs inc/<args>.hpp | sp unittest/<args>Tests.cpp
command -nargs=1 -complete=file Tabcxxv call <SID>OpenTabCxx("<args>")
command -nargs=1 -complete=file Tabjsv tabe src/<args>.js | vs unittests/<args>.spec.js
