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

function s:TabHasOnlyOneBufferAndThatNamelessAndVoid()
    return line('$') == 1 && getline(1) == '' && expand('%') == '' && len(tabpagebuflist()) == 1
endfunction

function s:TabEdit(directory, name, extension)
    let l:filepath = a:directory . "/" . a:name . a:extension
    let l:expandedPath = expand(l:filepath, 0, 1) " expand as list in case filepath is a glob
    if len(l:expandedPath) > 1
        let l:listForPrompt = ["Multiple files found. Please select one:"]
        let l:index = 1
        for l:item in l:expandedPath
            call add(l:listForPrompt, l:index . ". " . l:item)
            let l:index += 1
        endfor
        let l:index = inputlist(l:listForPrompt)
        let l:filepath = l:expandedPath[l:index-1]
    endif
    let l:editcmd = "tabedit "
    if s:TabHasOnlyOneBufferAndThatNamelessAndVoid()
        let l:editcmd = "edit "
    endif
    execute l:editcmd . l:filepath
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

let g:tabv_csharp_source_extension=".cs"
let g:tabv_csharp_unittest_extension="Tests.cs"

function s:OpenTabCSharp(name)
    call s:TabEdit(g:tabv_csharp_source_directory, a:name, g:tabv_csharp_source_extension)
    call s:VerticalSplit(g:tabv_csharp_unittest_directory, a:name, g:tabv_csharp_unittest_extension)
endfunction

function s:GuessPathsFromSolutionFile()
    if exists('g:tabv_guessed_paths')
        return
    endif
    execute "sview " . expand("*.sln")
    " TODO here
    let g:tabv_guessed_paths=1
    close
endfunction

function s:OpenTabForGuessedLanguage(name)
    let l:language = s:GuessLanguage()
    if l:language == "javascript"
        call s:OpenTabJavaScript(a:name)
    elseif l:language == "csharp"
        call s:OpenTabCSharp(a:name)
    else
        call s:OpenTabCPlusPlus(a:name)
    endif
endfunction

function s:GuessLanguage()
    if &filetype == ""
        if filereadable(g:tabv_grunt_file_path) " Assume this is a JavaScript project
            call s:GuessPathsFromGruntfile()
            return "javascript"
        elseif filereadable(expand("*.sln"))
            calls s:GuessPathsFromSolutionFile()
            return "csharp"
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
        let l:unittest_directory=g:tabv_javascript_unittest_directory
        let l:unittest_extension=g:tabv_javascript_unittest_extension
        let l:source_directory=g:tabv_javascript_source_directory
    else
        let l:unittest_directory=g:tabv_cplusplus_unittest_directory
        let l:unittest_extension=g:tabv_cplusplus_unittest_extension
        let l:source_directory=g:tabv_cplusplus_source_directory
    endif
    " Attempt to handle globs in filepaths...
    let l:globlocation=match(getcwd() . '/' . l:source_directory, '\*\*')
    if l:globlocation > -1
        " Substititute ** in the unit test directory name for what it
        " expanded to in the path of the source file, escaping backslashes and
        " spaces in case we are on Windows
        let l:unittest_directory=substitute(l:unittest_directory, '\*\*', escape(expand('%:p:h')[l:globlocation :], ' \'), "")
    endif
    call s:VerticalSplit(l:unittest_directory, expand('%:t:r'), l:unittest_extension)
endfunction

command -nargs=1 -complete=file Tabv call <SID>OpenTabForGuessedLanguage(<f-args>)
command -nargs=1 -complete=file Tabcxxv call <SID>OpenTabCPlusPlus(<f-args>)
command -nargs=1 -complete=file Tabjsv call <SID>OpenTabJavaScript(<f-args>)

command -nargs=0 Vsunittests call <SID>VerticalSplitUnitTests()

