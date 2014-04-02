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

function s:TabEdit(directory, name, extension)
    let l:editcmd = "tabedit "
    if line('$') == 1 && getline(1) == '' && expand('%') == '' && len(tabpagebuflist()) == 1
        let l:editcmd = "edit "
    endif
    execute l:editcmd . a:directory . "/" . a:name . a:extension
endfunction

function s:VerticalSplit(directory, name, extension)
    execute "vsplit " . a:directory . "/" . a:name . a:extension
endfunction

function s:HorizontalSplit(directory, name, extension)
    execute "split " . a:directory . "/" . a:name . a:extension
endfunction

" This is for the OpenTabCPlusPlus function, which will not open a source file
" if a name is suffixed with <>, i.e. Tabcxxv List<> will only open, say,
" inc/List.hpp and unittest/ListTests.cpp, vertically split
let s:GENERIC_REGEX = "<>$"

function s:OpenTabCPlusPlus(name)
    if match(a:name, s:GENERIC_REGEX) == -1
        call s:TabEdit(g:tabv_cplusplus_source_directory, a:name, g:tabv_cplusplus_source_extension)
        call s:VerticalSplit(g:tabv_cplusplus_include_directory, a:name, g:tabv_cplusplus_include_extension)
        call s:HorizontalSplit(g:tabv_cplusplus_unittest_directory, a:name, g:tabv_cplusplus_unittest_extension)
    else
        let l:name = substitute(a:name, s:GENERIC_REGEX, "", "")
        call s:TabEdit(g:tabv_cplusplus_include_directory, l:name, g:tabv_cplusplus_include_extension)
        call s:VerticalSplit(g:tabv_cplusplus_unittest_directory, l:name, g:tabv_cplusplus_unittest_extension)
    endif
endfunction

let g:tabv_javascript_source_directory="src"
let g:tabv_javascript_source_extension=".js"
let g:tabv_javascript_unittest_directory="unittests"
let g:tabv_javascript_unittest_extension=".spec.js"

function s:OpenTabJavaScript(name)
    call s:TabEdit(g:tabv_javascript_source_directory, a:name, g:tabv_javascript_source_extension)
    call s:VerticalSplit(g:tabv_javascript_unittest_directory, a:name, g:tabv_javascript_unittest_extension)
endfunction

let g:tabv_grunt_file_path='Gruntfile.js'

function s:GuessPathsFromGruntfile()
    if exists('g:tabv_guessed_paths')
        return
    endif
    execute "sview " . g:tabv_grunt_file_path
    global/^\_s*['"].*\*\.spec\.js['"]\_s*[,\]]\_s*/y a
    let l:matches = matchlist(getreg('a'), '[''"]\(.*\)/\*\.spec\.js[''"]')
    if len(l:matches) > 1
        let g:tabv_javascript_unittest_directory = l:matches[1]
    endif
    global/^\_s*['"].*\*\.js['"]\_s*[,\]]\_s*/y a
    let l:matches = matchlist(getreg('a'), '[''"]\(.*\)/\*\.js[''"]')
    if len(l:matches) > 1
        let g:tabv_javascript_source_directory = l:matches[1]
    endif
    let g:tabv_guessed_paths=1
    close
endfunction

function s:OpenTabForGuessedLanguage(name)
    let l:language = s:GuessLanguage()
    if l:language == "javascript"
        call s:OpenTabJavaScript(a:name)
    else
        call s:OpenTabCPlusPlus(a:name)
    endif
endfunction

function s:GuessLanguage()
    if &filetype == ""
        if filereadable(g:tabv_grunt_file_path) " Assume this is a JavaScript project
            call s:GuessPathsFromGruntfile()
            return "javascript"
        else
            return "unknown"
        endif
    elseif &filetype == "javascript"
        return "javascript"
    else
        return "unknown"
    endif
endfunction

function s:VerticalSplitUnitTests()
    let l:language = s:GuessLanguage()
    if l:language == 'javascript'
        call s:VerticalSplit(g:tabv_javascript_unittest_directory, expand('%:t:r'), g:tabv_javascript_unittest_extension)
    else
        call s:VerticalSplit(g:tabv_cplusplus_unittest_directory, expand('%:t:r'), g:tabv_cplusplus_unittest_extension)
    endif
endfunction

command -nargs=1 -complete=file Tabv call <SID>OpenTabForGuessedLanguage("<args>")
command -nargs=1 -complete=file Tabcxxv call <SID>OpenTabCPlusPlus("<args>")
command -nargs=1 -complete=file Tabjsv call <SID>OpenTabJavaScript("<args>")

command -nargs=0 Vsunittests call <SID>VerticalSplitUnitTests()

