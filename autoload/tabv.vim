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

" This is for the OpenTabCPlusPlus function, which will not open a source file
" if a name is suffixed with <>, i.e. Tabcxxv List<> will only open, say,
" inc/List.hpp and unittest/ListTests.cpp, vertically split
let g:tabv_generic_regex = "<>$"

function tabv#OpenTabCPlusPlus(name)
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

let g:tabv_javascript_source_directory="src"
let g:tabv_javascript_source_extension=".js"
let g:tabv_javascript_unittest_directory="unittests"
let g:tabv_javascript_unittest_extension=".spec.js"

function tabv#OpenTabJavaScript(name)
    call tabv#TabEdit(tabv#BuildPath(g:tabv_javascript_source_directory, a:name, g:tabv_javascript_source_extension))
    call tabv#VerticalSplit(tabv#BuildPath(g:tabv_javascript_unittest_directory, a:name, g:tabv_javascript_unittest_extension))
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

function tabv#ScrapeProjectFilePathsFromLines(linesFromSolution)
    let l:projectList = []
    for line in a:linesFromSolution
        let l:matches = matchlist(l:line, '^Project(.\+) = ".\+", "\(.\+[/\\]\)\?\(.\+\.csproj\)"')
        if l:matches != []
            call add(l:projectList, [l:matches[1], l:matches[1] . l:matches[2]])
        endif
    endfor
    return l:projectList
endfunction

function tabv#GuessSpecExtFromCsProjLines(linesFromCsProj)
    let l:candidates = {}
    let l:total = 0
    for line in a:linesFromCsProj
        if match(line, '<Compile Include=".\+" />') > -1
            if match(line, 'AssemblyInfo\.cs') > -1
                continue
            endif
            let l:total += 1
            let l:matches = matchlist(line, '[._]\?\([sS]pec\|[tT]est\)s\?.cs')
            if l:matches == []
                continue
            endif
            let l:extension = l:matches[0]
            if has_key(l:candidates, l:extension)
                let l:candidates[l:extension] += 1
            else
                let l:candidates[l:extension] = 1
            endif
        endif
    endfor
    for key in keys(l:candidates)
        if l:candidates[key]*1.0/l:total > 0.5
            return key
        endif
    endfor
    return ""
endfunction

function tabv#GuessSpecExtFromCsProjects()
    for projectPair in g:tabv_csproj_list
        let l:extension = tabv#GuessSpecExtFromCsProjLines(readfile(l:projectPair[1]))
        if l:extension != ""
            let g:tabv_csharp_unittest_extension = l:extension
            break
        endif
    endfor
endfunction

function tabv#InCsProjLinesFindFilepathOf(linesFromCsProj, filename)
    for line in a:linesFromCsProj
        let l:matches = matchlist(l:line, '<Compile Include="\(.\+\\\)\?\(' . a:filename . '\)" />')
        if l:matches != []
            return l:matches[1] . l:matches[2]
        endif
    endfor
    return ''
endfunction

function tabv#LookInCsProjsForFilepathOf(filename)
    for projectPair in g:tabv_csproj_list
        let l:filepath = tabv#InCsProjLinesFindFilepathOf(readfile(l:projectPair[1]), a:filename)
        if l:filepath != ""
            return l:projectPair[0] . '/' . l:filepath
        endif
    endfor
    return ""
endfunction

function tabv#OpenTabCSharp(name)
    let l:sourcePath = tabv#LookInCsProjsForFilepathOf(a:name . g:tabv_csharp_source_extension)
    let l:specPath = tabv#LookInCsProjsForFilepathOf(a:name . g:tabv_csharp_unittest_extension)
    if l:sourcePath != ""
        call tabv#TabEdit(l:sourcePath)
    endif
    if l:specPath != ""
        call tabv#VerticalSplit(l:specPath)
    endif
endfunction

function tabv#GuessPathsFromSolutionFile()
    if exists('g:tabv_guessed_paths')
        return
    endif
    let g:tabv_csproj_list = tabv#ScrapeProjectFilePathsFromLines(readfile(expand('*.sln'))) " Not multiple-solution safe
    call tabv#GuessSpecExtFromCsProjects()
    let g:tabv_guessed_paths=1
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
    if filereadable(g:tabv_gruntfile_path) " Assume this is a JavaScript project
        call tabv#GuessPathsFromGruntfile()
        return "javascript"
    elseif filereadable(expand("*.sln"))
        call tabv#GuessPathsFromSolutionFile()
        return "csharp"
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
        let l:specPath = tabv#LookInCsProjsForFilepathOf(l:name . g:tabv_csharp_unittest_extension)
        if l:specPath != ""
            call tabv#VerticalSplit(l:specPath)
        endif
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
