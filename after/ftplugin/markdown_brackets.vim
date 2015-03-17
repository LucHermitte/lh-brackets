"=============================================================================
" File:         ftplugin/markdown-brackets.vim                    {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"               <URL:http://github.com/LucHermitte>
" License:      GPLv3 with exceptions
"               <URL:http://github.com/LucHermitte/lh-brackets/License.md>
" Version:	2.2.2
let s:k_version = 222
" Created:      13th Mar 2014
"------------------------------------------------------------------------
" Description:
"       Mapping to insert markdown pairs:
"       - * -> *<cursor>* ; twice for **<cursor>** ;
"         <localleader>* for surrounding
"       - _ -> _<cursor>_ ; twice for __<cursor>__
"       - ` -> `<cursor>`
"       - ~ -> <del><cursor></del> ; <localleader>~ for surrounding
"       - <bs> -> delete empty pair
"
" }}}1
"=============================================================================

" Avoid local reinclusion {{{1
if &cp || (exists("b:loaded_ftplug_markdown_brackets")
      \ && (b:loaded_ftplug_markdown_brackets >= s:k_version)
      \ && !exists('g:force_reload_ftplug_markdown_brackets'))
  finish
endif
let b:loaded_ftplug_markdown_brackets = s:k_version
let s:cpo_save=&cpo
set cpo&vim
" Avoid local reinclusion }}}1

"------------------------------------------------------------------------
" Brackets & all {{{1
" ------------------------------------------------------------------------
if !exists(':Brackets')
  runtime plugin/common_brackets.vim
endif

if exists(':Brackets')
  let b:cb_jump_on_close = 1
  " Use the default definitions from plugin/common_brackets.vim

  " :Brackets /* */ -visual=0
  " :Brackets /** */ -visual=0 -trigger=/!
  "
  :Brackets _ _ -open=function('lh#markdown#brackets#underscore')
  :Brackets * * -open=function('lh#markdown#brackets#star') -visual=0
  :Brackets * * -insert=0 -trigger=<localleader>*
  " :Brackets * * -open=function('lh#markdown#brackets#star') -close=function('lh#markdown#brackets#star')
  :Brackets ` `
  :Brackets <\del> </del> -trigger=<localleader>~ -insert=0
  :Brackets ~ ~ -open=function('lh#markdown#brackets#strike') -visual=0
  "
  " Todo: add
  " *<space> remove the second '*'
  " ** -> '**<cursor>**'

  call lh#brackets#define_imap('<bs>',
        \ [{ 'condition': 'lh#markdown#brackets#match_pair()',
        \   'action': 'lh#brackets#_delete_empty_bracket_pair()'},
        \  { 'condition': 'lh#brackets#_match_any_bracket_pair()',
        \   'action': 'lh#brackets#_delete_empty_bracket_pair()'}],
        \ 1,
        \ '\<bs\>'
        \ )
endif
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
