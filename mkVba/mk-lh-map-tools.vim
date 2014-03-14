"=============================================================================
" $Id$
" File:		mkvba/mk-lh-map-tools.vim
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"               <URL:http://code.google.com/p/lh-vim/>
" License:      GPLv3 with exceptions
"               <URL:http://code.google.com/p/lh-vim/wiki/License>
" Version:	2.1.2
let s:version = '2.1.2'
" Created:	06th Nov 2007
" Last Update:	$Date$
"------------------------------------------------------------------------
cd <sfile>:p:h
try 
  let save_rtp = &rtp
  let &rtp = expand('<sfile>:p:h:h').','.&rtp
  exe '24,$MkVimball! lh-map-tools-'.s:version
  set modifiable
  set buftype=
finally
  let &rtp = save_rtp
endtry
finish
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
autoload/lh/markdown
autoload/lh/markdown/brackets.vim
autoload/lh/marker.vim
autoload/lh/vim/brackets.vim
brackets-addon-info.txt
doc/lh-map-tools.txt
lh-map-tools.Changelog
lh-map-tools.README
mkVba/mk-lh-map-tools.vim
plugin/bracketing.base.vim
plugin/common_brackets.vim
plugin/misc_map.vim

