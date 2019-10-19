augroup vimwiki
    if !exists('g:vimwiki_synced')
        let g:vimwiki_synced = 0
    endif

    if !exists('g:vimwiki_changes')
        let g:vimwiki_changes = 0
    endif

    if !exists('g:vimwiki_dir')
        let g:vimwiki_dir = vimwiki#vars#get_wikilocal('path')
    endif

    if !exists('g:vimwiki_file_ext')
        let g:vimwiki_file_ext = vimwiki#vars#get_wikilocal('ext')
    endif

    if !exists('g:vimwiki_push_on_commit')
        let g:vimwiki_push_on_commit = 0
    endif

    let g:vimwiki_dir_expanded = expand(g:vimwiki_dir)

    " pull related
    function! s:pull_exit()
        echomsg "Vimwiki: changes pulled from remote"
    endfunction

    function! s:pull_changes()
        if g:vimwiki_synced == 0
            let l:cmdmsg = system ("git -C " . g:vimwiki_dir_expanded . " pull origin master")
            call s:pull_exit()
            let g:vimwiki_synced = 1
        endif
    endfunction

    " push related
    function! s:push_exit()
        echomsg "Vimwiki: changes pushed to remote"
    endfunction

    function! s:push_changes()
        if g:vimwiki_changes == 1
            let l:cmdmsg = system ("git -C " . g:vimwiki_dir_expanded . " push origin master")
            call s:push_exit()
            let g:vimwiki_changes = 0
        endif
    endfunction

    " commit related
    function! s:commit(msg)
        echomsg "Vimwiki: committing '" . a:msg . "'"
        let l:cmdmsg = system ("git -C " . g:vimwiki_dir_expanded . " commit -m 'Auto commit: " . a:msg . "'")
        let g:vimwiki_changes = 1
        if g:vimwiki_push_on_commit == 1
            call s:push_changes()
        endif
    endfunction

    function! s:commit_changes(file)
        let l:command = "git -C " . g:vimwiki_dir_expanded . " add " . a:file
        call s:commit("file " . a:file)
    endfunction

    " sync changes at the start
    au! VimEnter,BufRead g:vimwiki_dir_expanded ."/*". g:vimwiki_file_ext call s:pull_changes()
    " auto commit changes on each file change
    au! BufWritePost g:vimwiki_dir_expanded ."/*". g:vimwiki_file_ext call s:commit_changes(<afile>)
    " push changes only on at the end
    au! VimLeave,BufLeave g:vimwiki_dir_expanded ."/*". g:vimwiki_file_ext call s:push_changes()
augroup END
