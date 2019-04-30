"=============================================================================
" File:		ftplugin/perl/perl_brackets.vim                                {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"               <URL:http://github.com/LucHermitte>
" License:      GPLv3 with exceptions
"               <URL:http://github.com/LucHermitte/lh-brackets/License.md>
" Version:	3.5.4
" Created:	26th May 2004
"------------------------------------------------------------------------
" Description:
" 	perl-ftplugin that defines the default preferences regarding the
" 	bracketing mappings we want to use.
"
"------------------------------------------------------------------------
" Note:
" 	In order to override these default definitions, copy this file into a
" 	directory that comes before the {rtp}/after/ftplugin/perl/ you choosed --
" 	typically $HOME/.vim/ftplugin/perl/ (:h 'rtp').
" 	Then, replace the calls to :Brackets, without the `-default` flag
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
let b:loaded_ftplug_perl_brackets = 353

let s:cpo_save=&cpo
set cpo&vim
" }}}1
"------------------------------------------------------------------------
" Brackets & all {{{1
" ------------------------------------------------------------------------
if ! lh#option#get('cb_no_default_brackets', 0)
  let b:cb_jump_on_close = 1
  " Use the default definitions from plugin/common_brackets.vim
  :Brackets < > -default -visual=1 -insert=0 -trigger=<localleader><
  :Brackets { } -default -visual=1 -insert=0 -nl -trigger=<localleader>{
  " }
endif

" }}}1
"=============================================================================
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
