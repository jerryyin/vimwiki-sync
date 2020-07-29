" vim:tabstop=2:shiftwidth=2:expandtab:textwidth=99
" Vimwiki-Sync plugin file
" Home: https://github.com/hv15/vimwiki-sync/

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

let s:known_wiki_exts_paths = s:vimwiki_get_paths_and_extensions()

augroup vimwiki
  autocmd!
  for s:ext in keys(s:known_wiki_exts_paths)
    for s:path in s:known_wiki_exts_paths[s:ext]
      " sync changes at the start
      exe 'autocmd BufRead,BufWritePost '.s:path.'*'.s:ext.' :Dispatch! "'.s:path.'/sync.sh"'
    endfor
  endfor
augroup END
