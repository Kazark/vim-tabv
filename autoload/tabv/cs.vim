if exists('g:tabv_cs_loaded')
    finish
endif

let g:tabv_csharp_source_extension=".cs"
let g:tabv_csharp_unittest_extension="Tests.cs"

function tabv#cs#ScrapeProjectFilePathsFromLines(linesFromSolution)
    let l:projectList = []
    for line in a:linesFromSolution
        let l:matches = matchlist(l:line, '^Project(.\+) = ".\+", "\(.\+[/\\]\)\?\(.\+\.csproj\)"')
        if l:matches != []
            call add(l:projectList, [l:matches[1], l:matches[1] . l:matches[2]])
        endif
    endfor
    return l:projectList
endfunction

function tabv#cs#GuessSpecExtFromProjLines(linesFromCsProj)
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

function tabv#cs#GuessSpecExtFromProjects()
    for projectPair in g:tabv_csproj_list
        let l:extension = tabv#cs#GuessSpecExtFromProjLines(readfile(l:projectPair[1]))
        if l:extension != ""
            let g:tabv_csharp_unittest_extension = l:extension
            break
        endif
    endfor
endfunction

function tabv#cs#InProjLinesFindFilepathOf(linesFromCsProj, filename)
    for line in a:linesFromCsProj
        let l:matches = matchlist(l:line, '<Compile Include="\(.\+\\\)\?\(' . a:filename . '\)" />')
        if l:matches != []
            return l:matches[1] . l:matches[2]
        endif
    endfor
    return ''
endfunction

function tabv#cs#LookInProjsForFilepathOf(filename)
    for projectPair in g:tabv_csproj_list
        let l:filepath = tabv#cs#InProjLinesFindFilepathOf(readfile(l:projectPair[1]), a:filename)
        if l:filepath != ""
            return l:projectPair[0] . '/' . l:filepath
        endif
    endfor
    return ""
endfunction

function tabv#cs#OpenTab(name)
    let l:sourcePath = tabv#cs#LookInProjsForFilepathOf(a:name . g:tabv_csharp_source_extension)
    let l:specPath = tabv#cs#LookInProjsForFilepathOf(a:name . g:tabv_csharp_unittest_extension)
    if l:sourcePath != ""
        call tabv#TabEdit(l:sourcePath)
    endif
    if l:specPath != ""
        call tabv#VerticalSplit(l:specPath)
    endif
endfunction

function tabv#cs#GuessPathsFromSolutionFile()
    if exists('g:tabv_guessed_paths')
        return
    endif
    let g:tabv_csproj_list = tabv#cs#ScrapeProjectFilePathsFromLines(readfile(expand('*.sln'))) " Not multiple-solution safe
    call tabv#cs#GuessSpecExtFromProjects()
    let g:tabv_guessed_paths=1
endfunction

let g:tabv_cs_loaded=1
