"=============================================================================
" $Id$
" File:		ftplugin/js/js_brackets.vim                                {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"               <URL:http://code.google.com/p/lh-vim/>
" Version:	1.0.0
" Created:	26th May 2004
" Last Update:	$Date$
"------------------------------------------------------------------------
" Description:	
" 	js-ftplugin that defines the default preferences regarding the
" 	bracketing mappings we want to use.
" 
"------------------------------------------------------------------------
" Installation:	
" 	This particular file is meant to be into {rtp}/after/ftplugin/js/
" 	In order to overidde these default definitions, copy this file into a
" 	directory that comes before the {rtp}/after/ftplugin/js/ you choosed --
" 	typically $HOME/.vim/ftplugin/js/ (:h 'rtp').
" 	Then, replace the calls to :Brackets
"
" 	Requires Vim7+, lh-map-tools, and {rtp}/autoload/lh/cpp/brackets.vim
"
" History:	
"	v1.0.0	28th Jul 2009
"		Adapted from ftplugin/c/c_brackets.vim
" TODO:		
" }}}1
"=============================================================================


"=============================================================================
" Avoid buffer reinclusion {{{1
if exists('b:loaded_ftplug_js_brackets') && !exists('g:force_reload_ftplug_js_brackets')
  finish
endif
let b:loaded_ftplug_js_brackets = '100'
 
let s:cpo_save=&cpo
set cpo&vim
" }}}1
"------------------------------------------------------------------------
" Brackets & all {{{
" ------------------------------------------------------------------------
if !exists(':Brackets')
  runtime plugin/common_brackets.vim
endif

if exists(':Brackets')
  let b:usemarks         = 1
  let b:cb_jump_on_close = 1
  " Re-run brackets() in order to update the mappings regarding the different
  " options.
  :Brackets { } -visual=0 -nl
  :Brackets { } -visual=0 -trigger=#{ 
  :Brackets { } -visual=1 -insert=0 -nl -trigger=<localleader>{
  :Brackets { } -visual=1 -insert=0

  :Brackets ( )
  :Brackets [ ] -visual=0
  :Brackets [ ] -insert=0 -trigger=<localleader>[
  :Brackets " " -visual=0 -insert=1
  :Brackets " " -visual=1 -insert=0 -trigger=""
  :Brackets ' ' -visual=0 -insert=1
  :Brackets ' ' -visual=1 -insert=0 -trigger=''

  " :Brackets /* */ -visual=0
  " :Brackets /** */ -visual=0 -trigger=/!
  "
endif

"=============================================================================

" }}}
"=============================================================================
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
