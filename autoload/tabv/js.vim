if exists('g:tabv_js_loaded')
    finish
endif

let g:tabv_javascript_source_directory="src"
let g:tabv_javascript_source_extension=".js"
let g:tabv_javascript_unittest_directory="unittests"
let g:tabv_javascript_unittest_extension=".spec.js"

function tabv#js#OpenTab(name)
    call tabv#TabEdit(tabv#BuildPath(g:tabv_javascript_source_directory, a:name, g:tabv_javascript_source_extension))
    call tabv#VerticalSplit(tabv#BuildPath(g:tabv_javascript_unittest_directory, a:name, g:tabv_javascript_unittest_extension))
endfunction

let g:tabv_gruntfile_regex='[''"]\(.*\)/\*%s[''"]'

function tabv#js#ScrapeSpecDirectoryFromOpenGruntfile()
    call setreg('a', '')
    global/^\_s*['"].*\*\.spec\.js['"]\_s*[,\]]\_s*/y a
    let l:matches = matchlist(getreg('a'), printf(g:tabv_gruntfile_regex, escape(g:tabv_javascript_unittest_extension, '.')))
    if len(l:matches) > 1
        let g:tabv_javascript_unittest_directory = l:matches[1]
    endif
endfunction

function tabv#js#ScrapeSourceDirectoryFromOpenGruntfile()
    call setreg('a', '')
    global/^\_s*['"].*\*\.js['"]\_s*[,\]]\_s*/y a
    let l:matches = matchlist(getreg('a'), printf(g:tabv_gruntfile_regex, escape(g:tabv_javascript_source_extension, '.')))
    if len(l:matches) > 1
        let g:tabv_javascript_source_directory = l:matches[1]
    endif
endfunction

function tabv#js#GuessPathsFromGruntfile()
    if exists('g:tabv_guessed_paths')
        return
    endif
    execute "sview " . g:tabv_gruntfile_path
    call tabv#js#ScrapeSpecDirectoryFromOpenGruntfile()
    call tabv#js#ScrapeSourceDirectoryFromOpenGruntfile()
    let g:tabv_guessed_paths=1
    close
endfunction

let g:tabv_js_loaded=1
