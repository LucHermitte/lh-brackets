"=============================================================================
" File:         ftplugin/help.vim                                 {{{1
" Author:       Luc Hermitte <EMAIL:luc {dot} hermitte {at} gmail {dot} com>
"		<URL:http://github.com/LucHermitte/lh-brackets>
" Version:      3.2.0
let s:k_version = 320
" Created:      14th Dec 2015
" Last Update:  24th Nov 2016
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
if !exists(':Brackets')
  runtime plugin/common_brackets.vim
endif

if exists(':Brackets')
  let b:cb_jump_on_close = 1

  :Brackets * * -visual=0
  :Brackets * * -insert=0 -trigger=<localleader>*
  :Brackets ` `
  :Brackets | |
endif

"=============================================================================
" Global Definitions {{{1
" Avoid global reinclusion {{{2
if &cp || (exists("g:loaded_ftplug_help_brackets")
      \ && (g:loaded_ftplug_help_brackets >= s:k_version)
      \ && !exists('g:force_reload_ftplug_help_brackets'))
  let &cpo=s:cpo_save
  finish
endif
let g:loaded_ftplug_help_brackets = s:k_version
" Avoid global reinclusion }}}2
"------------------------------------------------------------------------
" Functions {{{2
" Note: most filetype-global functions are best placed into
" autoload/«your-initials»/help/«help».vim
" Keep here only the functions are are required when the ftplugin is
" loaded, like functions that help building a vim-menu for this
" ftplugin.
" Functions }}}2
" }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
