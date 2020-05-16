"=============================================================================
" File:		ftlugin/vim/vim_brackets.vim                             {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"               <URL:http://github.com/LucHermitte>
" License:      GPLv3 with exceptions
"               <URL:http://github.com/LucHermitte/lh-brackets/License.md>
" Version:	3.6.0
" Created:	24th Mar 2008
" Last Update:	17th May 2020
"------------------------------------------------------------------------
" Description:
" 	vim-ftplugin that defines the default preferences regarding the
" 	bracketing mappings we want to use.
"
"------------------------------------------------------------------------
" Note:
" 	In order to override these default definitions, copy this file into a
" 	directory that comes before the {rtp}/after/ftplugin/vim/ you choosed --
" 	typically $HOME/.vim/ftplugin/vim/ (:h 'rtp').
" 	Then, replace the calls to :Brackets, without the `-default` flag
"
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
let b:loaded_ftplug_vim_brackets = 360
" Avoid local reinclusion }}}2

"------------------------------------------------------------------------
" Brackets & all {{{2
"------------------------------------------------------------------------

" It seems that function() does not load anything with some versions of vim
if !exists('lh#vim#brackets#lt')
  runtime autoload/lh/vim/brackets.vim
endif

if ! lh#option#get('cb_no_default_brackets', 0)
  let b:cb_jump_on_close = 1

  Brackets ( ) -default -esc
  Brackets " " -default -visual=0 -open=function('lh#vim#brackets#dquotes') -context!=comment
  Brackets < > -default -visual=0 -open=function('lh#vim#brackets#lt')
  Brackets < > -default -visual=1 -insert=0 -trigger=<localleader><
endif

" }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
