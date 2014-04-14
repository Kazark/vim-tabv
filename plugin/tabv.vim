" Purpose: Vim global plugin for easily opening relevant groupings of files as a tab
" Author:  Kazark <kazark@zoho.com>
" License: Public domain

if exists('g:tabv_loaded_plugin')
    finish
endif
let g:tabv_loaded_plugin=1

command -nargs=1 -complete=file Tabv call tabv#OpenTabForGuessedLanguage(<f-args>)
command -nargs=0 Tvword call tabv#OpenTabForGuessedLanguage(expand('<cword>'))
command -nargs=0 Vsunittests call tabv#VerticalSplitUnitTests()

