"=============================================================================
" File:         ftplugin/help.vim                                 {{{1
" Author:       Luc Hermitte <EMAIL:luc {dot} hermitte {at} gmail {dot} com>
"		<URL:http://github.com/LucHermitte/lh-brackets>
" Version:      3.5.4
let s:k_version = 354
" Created:      14th Dec 2015
" Last Update:  30th Apr 2019
"------------------------------------------------------------------------
" Description:
"       Mappings to insert help pairs
"       - | -> |<cursor>|
"       - ` -> `<cursor>`
"       - * -> *<cursor>* in INSERT-MODE,
"       - <localleader>*  in VISUAL and NORMAL modes
"
"------------------------------------------------------------------------
" History:      «history»
" TODO:         «missing features»
" }}}1
"=============================================================================

" Buffer-local Definitions {{{1
" Avoid local reinclusion {{{2
if &cp || (exists("b:loaded_ftplug_help_brackets")
      \ && (b:loaded_ftplug_help_brackets >= s:k_version)
      \ && !exists('g:force_reload_ftplug_help_brackets'))
  finish
endif
let b:loaded_ftplug_help_brackets = s:k_version
let s:cpo_save=&cpo
set cpo&vim
" Avoid local reinclusion }}}2

"------------------------------------------------------------------------
" Brackets & all {{{2
" ------------------------------------------------------------------------
if ! lh#option#get('cb_no_default_brackets', 0)
  let b:cb_jump_on_close = 1

  :Brackets * * -default -visual=0
  :Brackets * * -default -insert=0 -trigger=<localleader>*
  :Brackets ` ` -default
  :Brackets | | -default
endif

" }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
