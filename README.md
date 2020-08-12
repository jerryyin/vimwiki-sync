vimwiki-sync
============

This is a fork of [vimwiki-sync](https://github.com/RollMan/vimwiki-sync/), the
original plugin *automatically* synchronised Vimwiki notes into a local git
repository, with all changed files being automatically committed. This fork
provides several improvements. These include:

* Improved handling of modified files
* Fully handle all supported (configured) extension and wiki paths
* Refactored vimscript
* Asynchronous operations (depends on [vim-dispatch](https://github.com/tpope/vim-dispatch), and your personal `sync.sh` in notes directory)
  
  
### A sample of `sync.sh`

```bash
#!/bin/bash

gstatus=`git status --porcelain`

if [ ${#gstatus} -ne 0 ]
then

    git add --all
    git commit -m "$gstatus"

	git pull
    git push
 
fi
```
