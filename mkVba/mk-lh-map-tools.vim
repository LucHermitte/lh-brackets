"=============================================================================
" File:		mkvba/mk-lh-map-tools.vim
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"               <URL:http://github.com/LucHermitte>
" License:      GPLv3 with exceptions
"               <URL:http://github.com/LucHermitte/lh-brackets/License.md>
" Version:	2.3.1
let s:version = '2.3.1'
" Created:	06th Nov 2007
"------------------------------------------------------------------------
cd <sfile>:p:h
try
  let save_rtp = &rtp
  let &rtp = expand('<sfile>:p:h:h').','.&rtp
  exe '22,$MkVimball! lh-map-tools-'.s:version
  set modifiable
  set buftype=
finally
  let &rtp = save_rtp
endtry
finish
README.md
addon-info.txt
after/ftplugin/c/c_brackets.vim
after/ftplugin/html/html_brackets.vim
after/ftplugin/javascript_brackets.vim
after/ftplugin/markdown-brackets.vim
after/ftplugin/perl/perl_brackets.vim
after/ftplugin/ruby/ruby_brackets.vim
after/ftplugin/tex/tex_brackets.vim
after/ftplugin/vim/vim_brackets.vim
autoload/lh/brackets.vim
autoload/lh/cpp/brackets.vim
autoload/lh/html/brackets.vim
autoload/lh/map.vim
autoload/lh/markdown/brackets.vim
autoload/lh/marker.vim
autoload/lh/vim/brackets.vim
doc/default_brackets.md
doc/lh-map-tools.txt
ftplugin/python/python_snippets.vim
mkVba/mk-lh-map-tools.vim
plugin/bracketing.base.vim
plugin/common_brackets.vim
plugin/misc_map.vim
tests/lh/test-split.vim
