if exists('g:tabv_loaded')
    finish
endif

function tabv#TabIsEmpty()
    return line('$') == 1 && getline(1) == '' && expand('%') == '' && len(tabpagebuflist()) == 1
endfunction

function tabv#BuildPath(directory, name, extension)
    return a:directory . "/" . a:name . a:extension
endfunction

function tabv#ExpandToUniqueFilepath(filepath)
    let l:expandedPath = split(expand(a:filepath), "\n") " expand as list in case filepath is a glob
    if len(l:expandedPath) > 1
        let l:listForPrompt = ["Multiple files found. Please select one:"]
        let l:index = 1
        for l:item in l:expandedPath
            call add(l:listForPrompt, l:index . ". " . l:item)
            let l:index += 1
        endfor
        let l:index = inputlist(l:listForPrompt)
        return l:expandedPath[l:index-1]
    endif
    return a:filepath
endfunction

function tabv#TabEdit(filepath)
    let l:editcmd = "tabedit "
    if tabv#TabIsEmpty()
        let l:editcmd = "edit "
    endif
    execute l:editcmd . tabv#ExpandToUniqueFilepath(a:filepath)
endfunction

function tabv#VerticalSplit(filepath)
    execute "vsplit " . tabv#ExpandToUniqueFilepath(a:filepath)
endfunction

function tabv#HorizontalSplit(filepath)
    execute "split " . tabv#ExpandToUniqueFilepath(a:filepath)
endfunction

function tabv#OpenTabForGuessedLanguage(name)
    let l:language = tabv#GuessLanguage()
    if l:language == "javascript"
        call tabv#js#OpenTab(a:name)
    elseif l:language == "csharp"
        call tabv#cs#OpenTab(a:name)
    elseif l:language == "go"
        call tabv#go#OpenTab(a:name)
    elseif l:language == "python"
        call tabv#python#OpenTab(a:name)
    else
        call tabv#cxx#OpenTab(a:name)
    endif
endfunction

function tabv#GuessSpecDirectory()
    for path in ['specs', 'unittests', 'unittest', 'tests', 'Tests']
        if isdirectory(path)
            return path
        endif
    endfor
endfunction

let g:tabv_javascript_gruntfile_path='Gruntfile.js'
let g:tabv_javascript_gulpfile_path='gulpfile.js'
let g:tabv_coffeescript_gruntfile_path='Gruntfile.coffee'

function tabv#GuessLanguage()
    if filereadable(g:tabv_javascript_gruntfile_path) " Assume this is a JavaScript project
        call tabv#js#GuessPathsFromGruntfile()
        return "javascript"
    elseif filereadable(g:tabv_javascript_gulpfile_path) " Assume this is a JavaScript project
        return "javascript"
    elseif filereadable(g:tabv_coffeescript_gruntfile_path) " Assume this is a CoffeeScript project
        return "coffeescript"
    elseif filereadable(expand("*.sln"))
        call tabv#cs#GuessPathsFromSolutionFile()
        return "csharp"
    elseif tabv#go#CurrentDirectoryIsChildOfGopath()
        return "go"
    elseif isdirectory('__pycache__')
        return "python"
    elseif &filetype == "javascript"
        return "javascript"
    else
        return "unknown"
    endif
endfunction

function tabv#VerticalSplitUnitTests()
    let l:name = expand('%:t:r')
    let l:language = tabv#GuessLanguage()
    if l:language == 'javascript'
        let l:unittest_directory=g:tabv_javascript_unittest_directory
        let l:unittest_extension=g:tabv_javascript_unittest_extension
        let l:source_directory=g:tabv_javascript_source_directory
    elseif l:language == 'csharp'
        let l:specPath = tabv#cs#LookInProjsForFilepathOf(l:name . g:tabv_csharp_unittest_extension)
        if l:specPath != ""
            call tabv#VerticalSplit(l:specPath)
        endif
        return
    " TODO support Python
    elseif l:language == 'go'
        call tabv#VerticalSplit(l:name . g:tabv_go_unittest_extension)
        return
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
    call tabv#VerticalSplit(tabv#BuildPath(l:unittest_directory, l:name, l:unittest_extension))
endfunction

let g:tabv_loaded=1
