"=============================================================================
" File:		ftplugin/tex/tex_brackets.vim                            {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"               <URL:http://github.com/LucHermitte>
" License:      GPLv3 with exceptions
"               <URL:http://github.com/LucHermitte/lh-brackets/License.md>
" Version:	2.2.2
" Created:	24th Mar 2008
"------------------------------------------------------------------------
" Description:
" 	tex-ftplugin that defines the default preferences regarding the
" 	bracketing mappings we want to use.
"
"------------------------------------------------------------------------
" Installation:
" 	This particular file is meant to be into {rtp}/ftplugin/tex/
" 	In order to overidde these default definitions, copy this file into a
" 	directory that comes after the {rtp}/ftplugin/tex/ you choosed --
" 	typically $HOME/.vim/after/ftplugin/tex/ (:h 'rtp').
" 	Then, replace the calls to :Brackets
"
" 	Requires Vim7+, and lh-map-tools
" History:
" TODO:
" }}}1
"=============================================================================
" Buffer-local Definitions {{{1
" Avoid local reinclusion {{{2
if exists("b:loaded_ftplug_tex_brackets") && !exists('g:force_reload_ftplug_tex_brackets')
  finish
endif
let s:cpo_save=&cpo
set cpo&vim
let b:loaded_ftplug_tex_brackets = 222
" Avoid local reinclusion }}}2


"------------------------------------------------------------------------
" Brackets & all {{{2

if !exists(':Brackets')
  runtime plugin/common_brackets.vim
endif

let b:cb_jump_on_close = 1
let b:marker_open      = '<+'
let b:marker_close     = '+>'

Brackets ( ) -esc
Brackets { } -esc
Brackets [ ] -visual=0 -esc
Brackets [ ] -insert=0 -trigger=<localleader>[
Brackets $ $ -visual=0
Brackets $ $ -insert=0 -trigger=<localleader>$

"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
