"=============================================================================
" $Id$
" File:		ftplugin/perl/perl_brackets.vim                                {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://code.google.com/p/lh-vim/>
" License:      GPLv3 with exceptions
"               <URL:http://code.google.com/p/lh-vim/wiki/License>
" Version:	2.1.0
" Created:	26th May 2004
" Last Update:	$Date$
"------------------------------------------------------------------------
" Description:	
" 	perl-ftplugin that defines the default preferences regarding the
" 	bracketing mappings we want to use.
" 
"------------------------------------------------------------------------
" Installation:	
" 	This particular file is meant to be into {rtp}/after/ftplugin/perl/
" 	In order to overidde these default definitions, copy this file into a
" 	directory that comes before the {rtp}/after/ftplugin/perl/ you choosed --
" 	typically $HOME/.vim/ftplugin/perl/ (:h 'rtp').
" 	Then, replace the calls to :Brackets
"
" 	Requires Vim7+, lh-map-tools
"
" History:	
"	v1.0.0	07th Sep 2009
"		copy-paste of c_brackets.vim
"       v2.0.0  GPLv3
" TODO:		
" }}}1
"=============================================================================


"=============================================================================
" Avoid buffer reinclusion {{{1
if exists('b:loaded_ftplug_perl_brackets') && !exists('g:force_reload_ftplug_perl_brackets')
  finish
endif
let b:loaded_ftplug_perl_brackets = 1
 
let s:cpo_save=&cpo
set cpo&vim
" }}}1
"------------------------------------------------------------------------
" Brackets & all {{{
" ------------------------------------------------------------------------
if !exists(':Brackets')
  runtime plugin/common_brackets.vim
endif

runtime ftplugin/perl_localleader.vim

if exists(':Brackets')
  let b:usemarks         = 1
  let b:cb_jump_on_close = 1
  " Use the default definitions from plugin/common_brackets.vim
  :Brackets < > -visual=1 -insert=0 -trigger=<localleader><
  :Brackets { } -visual=1 -insert=0 -nl -trigger=<localleader>{
endif

"=============================================================================

" }}}
"=============================================================================
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
