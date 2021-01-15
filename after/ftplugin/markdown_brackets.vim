"=============================================================================
" File:         ftplugin/markdown-brackets.vim                    {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"               <URL:http://github.com/LucHermitte>
" License:      GPLv3 with exceptions
"               <URL:http://github.com/LucHermitte/lh-brackets/License.md>
" Version:	3.6.0
let s:k_version = 360
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
if ! lh#option#get('cb_no_default_brackets', 0)
  let b:cb_jump_on_close = 1
  " Use the default definitions from plugin/common_brackets.vim

  " :Brackets /* */ -default -visual=0
  " :Brackets /** */ -default -visual=0 -trigger=/!
  "
  :Brackets _ _           -default -open=function('lh#markdown#brackets#underscore')
  :Brackets * *           -default -open=function('lh#markdown#brackets#star') -visual=0
  :Brackets * *           -default -insert=0 -trigger=<localleader>*
  " :Brackets * *         -default -open=function('lh#markdown#brackets#star') -close=function('lh#markdown#brackets#star')
  :Brackets ` `           -default -open=function('lh#markdown#brackets#backtick')
  :Brackets <\del> </del> -default -trigger=<localleader>~ -insert=0
  :Brackets ~ ~           -default -open=function('lh#markdown#brackets#strike') -visual=0 -pair=,<del>,</del>
  "
  " Todo: add
  " *<space> remove the second '*'
  " ** -> '**<cursor>**'

  call lh#brackets#define_imap('$',
        \ [{'condition': "getline('.')[col('.')-2:] =~ '^`\\$'",
        \   'action': 'lh#markdown#brackets#close_math()'}],
        \ 1, '$')
endif

" }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
