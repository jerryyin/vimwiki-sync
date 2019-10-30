vimwiki-sync
============

This is a fork of [vimwiki-sync](https://github.com/RollMan/vimwiki-sync/), the
original plugin *automatically* synchronised Vimwiki notes into a local git
repository, with all changed files being automatically committed. This fork
provides several improvements. These include:

* improved handling of modified files
* fully handle all supported (configured) extension and wiki paths
* refactored vimscript

ToDo
----

* better support for `git` (_thinking of using fugitive_)
* asynchronous operations (at the moment there is lag)
* test-suite...
