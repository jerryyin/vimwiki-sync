" vim:tabstop=2:shiftwidth=2:expandtab:textwidth=99
" Vimwiki-Sync plugin file
" Home: https://github.com/hv15/vimwiki-sync/

if exists('g:loaded_vimwiki_sync')
  finish
endif
let g:loaded_vimwiki_sync = 1

if !exists('s:vimwiki_synced')
    let s:vimwiki_synced = 0
endif

if !exists('s:vimwiki_changes')
    let s:vimwiki_changes = 0
endif

if !exists('s:vimwiki_push_on_commit')
    let s:vimwiki_push_on_commit = 0
endif

" pull related
function! s:pull_exit()
    echomsg "Vimwiki: changes pulled from remote"
endfunction

function! s:pull_changes(path) abort
    if s:vimwiki_synced == 0
        let l:cmdmsg = system ("git -C " . a:path . " pull origin master")
        call s:pull_exit()
        let s:vimwiki_synced = 1
    endif
endfunction

" push related
function! s:push_exit()
    echomsg "Vimwiki: changes pushed to remote"
endfunction

function! s:push_changes(path) abort
    if s:vimwiki_changes == 1
        let l:cmdmsg = system ("git -C " . a:path . " push origin master")
        call s:push_exit()
        let s:vimwiki_changes = 0
    endif
endfunction

" commit related
function! s:commit(path, msg) abort
    echomsg "Vimwiki: committing '" . a:msg . "'"
    let l:cmdmsg = system ("git -C " . a:path . " commit -m 'Auto commit: " . a:msg . "'")
    let s:vimwiki_changes = 1
    if s:vimwiki_push_on_commit == 1
        call s:push_changes()
    endif
endfunction

function! s:commit_changes(path, file) abort
  let l:cmdmsg = system ("git -C " . a:path . " add " . a:file)
  call s:commit(a:path, "file " . a:file)
endfunction

function! s:vimwiki_get_paths_and_extensions()
  " Getting all extensions and paths that different wikis could have
  " These are then placed together {ext -> [path], ...}.
  let wikis = {}
  let paths = {}
  for idx in range(vimwiki#vars#number_of_wikis())
    let ext = vimwiki#vars#get_wikilocal('ext', idx)
    let path = vimwiki#vars#get_wikilocal('path', idx)
    let wikis[ext] = 1
    let paths[path] = 1
  endfor
  " append extensions from g:vimwiki_ext2syntax
  for ext in keys(vimwiki#vars#get_global('ext2syntax'))
    let wikis[ext] = 1
  endfor
  " combine exts and paths
  for key in keys(wikis)
    let wikis[ext] = keys(paths)
  endfor
  return wikis
endfunction

let s:known_wiki_exts_paths = s:vimwiki_get_paths_and_extensions()

augroup vimwiki
  for s:ext in keys(s:known_wiki_exts_paths)
    for s:path in s:known_wiki_exts_paths[s:ext]
      " sync changes at the start
      exe 'autocmd VimEnter,BufRead '.s:path.'*'.s:ext.' call s:pull_changes("'.s:path.'")'
      " auto commit changes on each file change
      exe 'autocmd BufWritePost '.s:path.'*'.s:ext.' call s:commit_changes("'.s:path.'", expand("<amatch>:t"))'
      " push changes only on at the end
      exe 'autocmd VimLeave,BufLeave '.s:path.'*'.s:ext.' call s:push_changes("'.s:path.'")'
    endfor
  endfor
augroup END
