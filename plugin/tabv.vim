" Purpose: Vim global plugin for easily opening relevant groupings of files as a tab
" Author:  Kazark <kazark@zoho.com>
" License: Public domain

if exists('g:tabv_loaded_plugin')
    finish
endif
let g:tabv_loaded_plugin=1

let g:tabv_cplusplus_source_directory="src"
let g:tabv_cplusplus_source_extension=".cpp"
let g:tabv_cplusplus_include_directory="inc"
let g:tabv_cplusplus_include_extension=".hpp"
let g:tabv_cplusplus_unittest_directory="unittest"
let g:tabv_cplusplus_unittest_extension="Tests.cpp"

function s:OpenTabCPlusPlus(name)
    execute "tabe " . g:tabv_cplusplus_source_directory . "/" . a:name . g:tabv_cplusplus_source_extension
    execute "vs " . g:tabv_cplusplus_include_directory . "/" . a:name . g:tabv_cplusplus_include_extension
    execute "sp " . g:tabv_cplusplus_unittest_directory . "/" . a:name . g:tabv_cplusplus_unittest_extension
endfunction

let g:tabv_javascript_source_directory="src"
let g:tabv_javascript_source_extension=".js"
let g:tabv_javascript_unittest_directory="unittests"
let g:tabv_javascript_unittest_extension=".spec.js"

function s:OpenTabJavaScript(name)
    execute "tabe " . g:tabv_javascript_source_directory . "/" . a:name . g:tabv_javascript_source_extension
    execute "vs " . g:tabv_javascript_unittest_directory . "/" . a:name . g:tabv_javascript_unittest_extension
endfunction

command -nargs=1 -complete=file Tabv tabe src/<args>.cpp | vs inc/<args>.hpp | sp unittest/<args>Tests.cpp
command -nargs=1 -complete=file Tabcxxv call <SID>OpenTabCPlusPlus("<args>")
command -nargs=1 -complete=file Tabjsv call <SID>OpenTabJavaScript("<args>")
