"=============================================================================
" $Id$
" File:		mk-lh-map-tools.vim
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://hermitte.free.fr/vim/>
" Version:	1.0.0
let s:version = '1.0.0.RC1'
" Created:	06th Nov 2007
" Last Update:	$Date$
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
doc/lh-map-tools.txt
plugin/bracketing.base.vim
plugin/common_brackets.vim
plugin/misc_map.vim
autoload/lh/brackets.vim
