"=============================================================================
" File:		ftplugin/html/html_brackets.vim                          {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"               <URL:http://github.com/LucHermitte>
" License:      GPLv3 with exceptions
"               <URL:http://github.com/LucHermitte/lh-brackets/License.md>
" Version:	3.5.4
" Created:	24th Mar 2008
"------------------------------------------------------------------------
" Description:
" 	html-ftplugin that defines the default preferences regarding the
" 	bracketing mappings we want to use.
"
"------------------------------------------------------------------------
" Note:
" 	In order to override these default definitions, copy this file into a
" 	directory that comes before the {rtp}/after/ftplugin/html/ you choosed --
" 	typically $HOME/.vim/ftplugin/html/ (:h 'rtp').
" 	Then, replace the calls to :Brackets, without the `-default` flag
"
" TODO:
" }}}1
"=============================================================================

" Buffer-local Definitions {{{1
" Avoid local reinclusion {{{2
if &ft == 'markdown'
  " We don't want these mappings in markdown
  finish
endif

if exists("b:loaded_ftplug_html_brackets") && !exists('g:force_reload_ftplug_html_brackets')
  finish
endif
let s:cpo_save=&cpo
set cpo&vim
let b:loaded_ftplug_html_brackets = 354
" Avoid local reinclusion }}}2

"------------------------------------------------------------------------
" Brackets & all {{{2
" It seems that function() does not load anything with some versions of vim
if !exists('lh#html#brackets#lt')
  runtime autoload/lh/html/brackets.vim
endif

let b:cb_jump_on_close = 1

if ! lh#option#get('cb_no_default_brackets', 0)
  Brackets < > -default
        \      -visual=0
        \      -open=function('lh#html#brackets#lt')
        \      -clos=function('lh#html#brackets#gt')
  Brackets < > -default -visual=1 -insert=0 -trigger=<localleader><
endif

" }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
