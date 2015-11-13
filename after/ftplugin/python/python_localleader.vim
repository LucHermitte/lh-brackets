"=============================================================================
" File:         ftplugin/python/python_localleader.vim            {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} gmail {dot} com>
"		<URL:http://github.com/LucHermitte/lh-brackets>
" Version:      2.3.3
let s:k_version = 233
" Created:      13th Nov 2015
" Last Update:  13th Nov 2015
"------------------------------------------------------------------------
" Description:
"       This file is a variation point.
"       It sets "," as default value to |maplocalleader| for python files.
"
"       It has to be sourced before any reference to <localleader> in Python
"       ftplugins:
"           :runtime! ftplugin/python/python_localleader.vim
"
"       As this exact file is put in the after/ sub-hierarchy (see
"       :h after-directory), it'll be loaded after other files with the same
"       name by |:runtime|.
"
"       So, if my default binding of |maplocalleader| to "," doesn't suit you,
"       define the file $HOME/.vim/python/python_localleader.vim (or the
"       equivalent under Windows) with for instance (let's say your prefer "_"
"       as a local leader):
"           :let g:maplocalleader = '_'
"------------------------------------------------------------------------
" TODO:
" - move this file from lh-brachets to lh-misc (or a future lh-python in case I
"   spend more time writing Python)
" }}}1
"=============================================================================

" Buffer-local Definitions {{{1
" Avoid local reinclusion {{{2
if &cp || (exists("b:loaded_ftplug_python_localleader")
      \ && (b:loaded_ftplug_python_localleader >= s:k_version)
      \ && !exists('g:force_reload_ftplug_python_localleader'))
  finish
endif
let b:loaded_ftplug_python_localleader = s:k_version
let s:cpo_save=&cpo
set cpo&vim
" Avoid local reinclusion }}}2

call lh#leader#set_local_if_unset(',')

"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
