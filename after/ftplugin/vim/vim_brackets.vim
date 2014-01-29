"=============================================================================
" $Id$
" File:		ftlugin/vim/vim_brackets.vim                             {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"               <URL:http://code.google.com/p/lh-vim/>
" License:      GPLv3 with exceptions
"               <URL:http://code.google.com/p/lh-vim/wiki/License>
" Version:	2.1.0
" Created:	24th Mar 2008
" Last Update:	$Date$
"------------------------------------------------------------------------
" Description:	
" 	vim-ftplugin that defines the default preferences regarding the
" 	bracketing mappings we want to use.
" 
"------------------------------------------------------------------------
" Installation:
" 	This particular file is meant to be into {rtp}/after/ftplugin/vim/
" 	In order to overidde these default definitions, copy this file into a
" 	directory that comes before the {rtp}/after/ftplugin/vim/ you choosed
" 	-- typically $HOME/.vim/ftplugin/vim/ (:h 'rtp').
" 	Then, replace the calls to :Brackets
"
" 	Requires Vim7+, lh-map-tools, and {rtp}/autoload/lh/vim/brackets.vim
" History:
" TODO:		
" * Escapable "()" must also work with \%(\)

"=============================================================================

" Buffer-local Definitions {{{1
" Avoid local reinclusion {{{2
if exists("b:loaded_ftplug_vim_brackets") && !exists('g:force_reload_ftplug_vim_brackets')
  finish
endif
let s:cpo_save=&cpo
set cpo&vim
let b:loaded_ftplug_vim_brackets = 210
" Avoid local reinclusion }}}2

"------------------------------------------------------------------------
" Brackets & all {{{2

if !exists(':Brackets')
  runtime plugin/common_brackets.vim
endif
" It seems that function() does not load anything ...
if !exists('lh#vim#brackets#lt')
  runtime autoload/lh/vim/brackets.vim
endif

let b:usemarks         = 1
let b:cb_jump_on_close = 1

Brackets ( ) -esc
Brackets " " -visual=0 -open=function('lh#vim#brackets#dquotes')
Brackets < > -visual=0 -open=function('lh#vim#brackets#lt')
Brackets < > -visual=1 -insert=0 -trigger=<localleader><


"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
