"=============================================================================
" File:		ftplugin/tex/tex_brackets.vim                            {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"               <URL:http://github.com/LucHermitte>
" License:      GPLv3 with exceptions
"               <URL:http://github.com/LucHermitte/lh-brackets/License.md>
" Version:	3.5.4
" Created:	24th Mar 2008
"------------------------------------------------------------------------
" Description:
" 	tex-ftplugin that defines the default preferences regarding the
" 	bracketing mappings we want to use.
"
"------------------------------------------------------------------------
" Note:
" 	In order to override these default definitions, copy this file into a
" 	directory that comes before the {rtp}/after/ftplugin/tex/ you choosed --
" 	typically $HOME/.vim/ftplugin/tex/ (:h 'rtp').
" 	Then, replace the calls to :Brackets, without the `-default` flag
"
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
let b:loaded_ftplug_tex_brackets = 354
" Avoid local reinclusion }}}2

"------------------------------------------------------------------------
" Brackets & all {{{2
let b:marker_open      = '<+'
let b:marker_close     = '+>'

if ! lh#option#get('cb_no_default_brackets', 0)
  let b:cb_jump_on_close = 1
  Brackets ( ) -default -esc
  Brackets { } -default -esc
  Brackets [ ] -default -visual=0 -esc
  Brackets [ ] -default -insert=0 -trigger=<localleader>[
  Brackets $ $ -default -visual=0
  Brackets $ $ -default -insert=0 -trigger=<localleader>$
endif

" }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
