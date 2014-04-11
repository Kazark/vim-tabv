if exists('g:tabv_loaded')
    finish
endif

let g:tabv_cplusplus_source_directory="src"
let g:tabv_cplusplus_source_extension=".cpp"
let g:tabv_cplusplus_include_directory="inc"
let g:tabv_cplusplus_include_extension=".hpp"
let g:tabv_cplusplus_unittest_directory="unittest"
let g:tabv_cplusplus_unittest_extension="Tests.cpp"

function tabv#TabIsEmpty()
    return line('$') == 1 && getline(1) == '' && expand('%') == '' && len(tabpagebuflist()) == 1
endfunction

function tabv#TabEdit(directory, name, extension)
    let l:filepath = a:directory . "/" . a:name . a:extension
    let l:expandedPath = split(expand(l:filepath), "\n") " expand as list in case filepath is a glob
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
    if tabv#TabIsEmpty()
        let l:editcmd = "edit "
    endif
    execute l:editcmd . l:filepath
endfunction

function tabv#VerticalSplit(directory, name, extension)
    execute "vsplit " . a:directory . "/" . a:name . a:extension
endfunction

function tabv#HorizontalSplit(directory, name, extension)
    execute "split " . a:directory . "/" . a:name . a:extension
endfunction

" This is for the OpenTabCPlusPlus function, which will not open a source file
" if a name is suffixed with <>, i.e. Tabcxxv List<> will only open, say,
" inc/List.hpp and unittest/ListTests.cpp, vertically split
let g:tabv_generic_regex = "<>$"

function tabv#OpenTabCPlusPlus(name)
    if match(a:name, g:tabv_generic_regex) == -1
        call tabv#TabEdit(g:tabv_cplusplus_source_directory, a:name, g:tabv_cplusplus_source_extension)
        call tabv#VerticalSplit(g:tabv_cplusplus_include_directory, a:name, g:tabv_cplusplus_include_extension)
        call tabv#HorizontalSplit(g:tabv_cplusplus_unittest_directory, a:name, g:tabv_cplusplus_unittest_extension)
    else
        let l:name = substitute(a:name, g:tabv_generic_regex, "", "")
        call tabv#TabEdit(g:tabv_cplusplus_include_directory, l:name, g:tabv_cplusplus_include_extension)
        call tabv#VerticalSplit(g:tabv_cplusplus_unittest_directory, l:name, g:tabv_cplusplus_unittest_extension)
    endif
endfunction

let g:tabv_javascript_source_directory="src"
let g:tabv_javascript_source_extension=".js"
let g:tabv_javascript_unittest_directory="unittests"
let g:tabv_javascript_unittest_extension=".spec.js"

function tabv#OpenTabJavaScript(name)
    call tabv#TabEdit(g:tabv_javascript_source_directory, a:name, g:tabv_javascript_source_extension)
    call tabv#VerticalSplit(g:tabv_javascript_unittest_directory, a:name, g:tabv_javascript_unittest_extension)
endfunction

let g:tabv_gruntfile_path='Gruntfile.js'

let g:tabv_gruntfile_regex='[''"]\(.*\)/\*%s[''"]'

function tabv#ScrapeSpecDirectoryFromOpenGruntfile()
    call setreg('a', '')
    global/^\_s*['"].*\*\.spec\.js['"]\_s*[,\]]\_s*/y a
    let l:matches = matchlist(getreg('a'), printf(g:tabv_gruntfile_regex, escape(g:tabv_javascript_unittest_extension, '.')))
    if len(l:matches) > 1
        let g:tabv_javascript_unittest_directory = l:matches[1]
    endif
endfunction

function tabv#ScrapeSourceDirectoryFromOpenGruntfile()
    call setreg('a', '')
    global/^\_s*['"].*\*\.js['"]\_s*[,\]]\_s*/y a
    let l:matches = matchlist(getreg('a'), printf(g:tabv_gruntfile_regex, escape(g:tabv_javascript_source_extension, '.')))
    if len(l:matches) > 1
        let g:tabv_javascript_source_directory = l:matches[1]
    endif
endfunction

function tabv#GuessPathsFromGruntfile()
    if exists('g:tabv_guessed_paths')
        return
    endif
    execute "sview " . g:tabv_gruntfile_path
    call tabv#ScrapeSpecDirectoryFromOpenGruntfile()
    call tabv#ScrapeSourceDirectoryFromOpenGruntfile()
    let g:tabv_guessed_paths=1
    close
endfunction

let g:tabv_csharp_source_extension=".cs"
let g:tabv_csharp_unittest_extension="Tests.cs"

function tabv#OpenTabCSharp(name)
    call tabv#TabEdit(g:tabv_csharp_source_directory, a:name, g:tabv_csharp_source_extension)
    call tabv#VerticalSplit(g:tabv_csharp_unittest_directory, a:name, g:tabv_csharp_unittest_extension)
endfunction

function tabv#GuessPathsFromSolutionFile()
    if exists('g:tabv_guessed_paths')
        return
    endif
    execute "sview " . expand("*.sln")
    " TODO here
    let g:tabv_guessed_paths=1
    close
endfunction

function tabv#OpenTabForGuessedLanguage(name)
    let l:language = tabv#GuessLanguage()
    if l:language == "javascript"
        call tabv#OpenTabJavaScript(a:name)
    elseif l:language == "csharp"
        call tabv#OpenTabCSharp(a:name)
    else
        call tabv#OpenTabCPlusPlus(a:name)
    endif
endfunction

function tabv#GuessLanguage()
    if &filetype == ""
        if filereadable(g:tabv_gruntfile_path) " Assume this is a JavaScript project
            call tabv#GuessPathsFromGruntfile()
            return "javascript"
        elseif filereadable(expand("*.sln"))
            calls tabv#GuessPathsFromSolutionFile()
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

function tabv#VerticalSplitUnitTests()
    let l:language = tabv#GuessLanguage()
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
    call tabv#VerticalSplit(l:unittest_directory, expand('%:t:r'), l:unittest_extension)
endfunction

let g:tabv_loaded=1
