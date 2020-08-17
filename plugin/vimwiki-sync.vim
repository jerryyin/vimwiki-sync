" vim:tabstop=2:shiftwidth=2:expandtab:textwidth=99
" Vimwiki-Sync plugin file
" Home: https://github.com/icalvin102/vimwiki-sync/

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
    let wikis[key] = keys(paths)
  endfor
  return wikis
endfunction

function! s:on_out(job_id, data, event)
    echom 'VimWikiSync:' join(a:data, '  ')
endfunction

function! s:on_exit(job_id, data, event)
    echom 'VimWikiSync:' (a:data == 0 ? 'Finished syncing' : 'Syncing error')
endfunction

function! CloseHandler(channel)
  echom 'something something'
  while ch_status(a:channel, {'part':'out'}) == 'buffered'
    echom ch_read(a:channel)
  endwhile
endfunction

function! ExitHandler(channel,msg )
  echom "VimWikiSync: Finished"
endfunction

function! s:vimwiki_sync(path)
    let l:cmd =  'git -C "'. a:path .'" add --all && '
    let l:cmd .= 'git -C "'. a:path .'" commit -m "Auto update: $(git -C "'. a:path .'" status --porcelain)" ; '
    let l:cmd .= 'git -C "'. a:path .'" pull --rebase && '
    let l:cmd .= 'git -C "'. a:path .'" push'
    if has('nvim')
      let s:job = jobstart(l:cmd, {'on_stdout': function('s:on_out'),'on_stderr': function('s:on_out'),  'on_exit': function('s:on_exit') })
    else
      let s:job = job_start(['/bin/sh', '-c', l:cmd], {'exit_cb': 'ExitHandler', 'close_cb': 'CloseHandler'})
    endif
endfunction


let s:known_wiki_exts_paths = s:vimwiki_get_paths_and_extensions()

augroup vimwiki
  autocmd!
  for s:ext in keys(s:known_wiki_exts_paths)
    for s:path in s:known_wiki_exts_paths[s:ext]
      " sync changes at the start
      exe 'autocmd BufRead,BufWritePost '.s:path.'*'.s:ext.' :call s:vimwiki_sync("'.s:path.'")'
    endfor
  endfor
augroup END
