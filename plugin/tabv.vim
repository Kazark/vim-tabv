" Purpose: Vim global plugin for easily opening relevant groupings of files as a tab
" Author:  Kazark <kazark@zoho.com>
" License: Public domain

if exists('g:tabv_loaded_plugin')
    finish
endif
let g:tabv_loaded_plugin=1

command -nargs=1 -complete=file Tabv tabe src/<args>.cpp | vs inc/<args>.hpp | sp unittest/<args>Tests.cpp
command -nargs=1 -complete=file Tabcxxv tabe src/<args>.cpp | vs inc/<args>.hpp | sp unittest/<args>Tests.cpp
command -nargs=1 -complete=file Tabjsv tabe src/<args>.js | vs unittests/<args>.spec.js
