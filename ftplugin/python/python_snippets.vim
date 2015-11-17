"=============================================================================
" File:         ftplugin/python/python_snippets.vim               {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"               <URL:http://github.com/LucHermitte>
" License:      GPLv3 with exceptions
"               <URL:http://github.com/LucHermitte/lh-brackets/License.md>
" Version:	2.3.4
let s:k_version = '2.3.4'
" Created:      21st Jan 2015
"------------------------------------------------------------------------
" Description:
"       Snippets of python Control Statements
"
"------------------------------------------------------------------------
" TODO:
" - move this file from lh-brachets to lh-misc (or a future lh-python in case I
"   spend more time writing Python)
" }}}1
"=============================================================================

" Buffer-local Definitions {{{1
" Avoid local reinclusion {{{2
if &cp || (exists("b:loaded_ftplug_python_snippets")
      \ && (b:loaded_ftplug_python_snippets >= s:k_version)
      \ && !exists('g:force_reload_ftplug_python_snippets'))
  finish
endif
let b:loaded_ftplug_python_snippets = s:k_version
let s:cpo_save=&cpo
set cpo&vim
" Avoid local reinclusion }}}2

" This must be loaded before continuing
runtime! ftplugin/python/python_localleader.vim

"------------------------------------------------------------------------
" Local mappings {{{2

" Control statements {{{3
" --- if ---------------------------------------------------------{{{4
"--if    insert "if" statement                   {{{5
Inoreabbr <buffer> <silent> if <C-R>=PyMapOnSingleLine('if ',
      \ "\\<c-f\\>if !cursorhere!:\n!mark!")<cr>
"--,if    insert "if" statement
xnoremap <buffer> <silent> <localleader>if
      \ <c-\><c-n>@=lh#map#surround('if !cursorhere!:', '!mark!',
      \ 1, 1, '', 1, 'if ')<cr>
xnoremap <buffer> <silent> <LocalLeader><localleader>if
      \ <c-\><c-n>@=lh#map#surround('if ', "!cursorhere!:\n!mark!",
      \ 0, 1, '', 1, 'if ')<cr>
nmap <buffer> <LocalLeader>if V<LocalLeader>if
nmap <buffer> <LocalLeader><LocalLeader>if ^v$<LocalLeader><LocalLeader>if

"--elif  insert "elif" statement                 {{{5
Inoreabbr <buffer> <silent> elif <C-R>=PyMapOnSingleLine('elif ',
      \ "\\<c-f\\>elif !cursorhere!:\n!mark!")<cr>
"--,elif    insert "elif" statement
xnoremap <buffer> <silent> <localleader>elif
      \ <c-\><c-n>@=lh#map#surround('elif !cursorhere!:', '!mark!',
      \ 1, 1, '', 1, 'elif ')<cr>
xnoremap <buffer> <silent> <LocalLeader><localleader>elif
      \ <c-\><c-n>@=lh#map#surround('elif ', "!cursorhere!:\n!mark!",
      \ 0, 1, '', 1, 'elif ')<cr>
nmap <buffer> <LocalLeader>elif V<LocalLeader>elif
nmap <buffer> <LocalLeader><LocalLeader>elif ^v$<LocalLeader><LocalLeader>elif

"--elif  insert "elif" statement                 {{{5
Inoreabbr <buffer> <silent> else <C-R>=PyMapOnSingleLine('else ',
      \ "\\<c-f\\>else:\n")<cr>
"--,elif    insert "elif" statement
xnoremap <buffer> <silent> <localleader>else
      \ <c-\><c-n>@=lh#map#surround('else:!cursorhere!', '\<c-d>!mark!',
      \ 1, 1, '', 1, 'else ')<cr>
nmap <buffer> <LocalLeader>else V<LocalLeader>else

" --- for --------------------------------------------------------{{{4
"--for    insert "for" statement                  {{{5
Inoreabbr <buffer> <silent> for <C-R>=PyMapOnSingleLine('for ',
      \ "\\<c-f\\>for !cursorhere!:\n!mark!")<cr>
"--,for    insert "for" statement
xnoremap <buffer> <silent> <localleader>for
      \ <c-\><c-n>@=lh#map#surround('for !cursorhere!:', '!mark!',
      \ 1, 1, '', 1, 'for ')<cr>
xnoremap <buffer> <silent> <LocalLeader><localleader>for
      \ <c-\><c-n>@=lh#map#surround('for ', "!cursorhere!:\n!mark!",
      \ 0, 1, '', 1, 'for ')<cr>
nmap <buffer> <LocalLeader>for V<LocalLeader>for
nmap <buffer> <LocalLeader><LocalLeader>for ^v$<LocalLeader><LocalLeader>for

" --- while ------------------------------------------------------{{{4
"--while    insert "while" statement                {{{5
Inoreabbr <buffer> <silent> while <C-R>=PyMapOnSingleLine('while ',
      \ "\\<c-f\\>while !cursorhere!:\n!mark!")<cr>
"--,while    insert "while" statement
xnoremap <buffer> <silent> <localleader>while
      \ <c-\><c-n>@=lh#map#surround('while !cursorhere!:', '!mark!',
      \ 1, 1, '', 1, 'while ')<cr>
xnoremap <buffer> <silent> <LocalLeader><localleader>while
      \ <c-\><c-n>@=lh#map#surround('while ', "!cursorhere!:\n!mark!",
      \ 0, 1, '', 1, 'while ')<cr>
nmap <buffer> <LocalLeader>while V<LocalLeader>while
nmap <buffer> <LocalLeader><LocalLeader>while ^v$<LocalLeader><LocalLeader>while

"=============================================================================
" Global Definitions {{{1
" Avoid global reinclusion {{{2
if &cp || (exists("g:loaded_ftplug_python_snippets")
      \ && (g:loaded_ftplug_python_snippets >= s:k_version)
      \ && !exists('g:force_reload_ftplug_python_snippets'))
  let &cpo=s:cpo_save
  finish
endif
let g:loaded_ftplug_python_snippets = s:k_version
" Avoid global reinclusion }}}2
"------------------------------------------------------------------------
" Functions {{{2
" Note: most filetype-global functions are best placed into
" autoload/«your-initials»/python/«python_snippets».vim
" Keep here only the functions are are required when the ftplugin is
" loaded, like functions that help building a vim-menu for this
" ftplugin.

" Function: PyMapOnSingleLine(key, what) {{{3
function! PyMapOnSingleLine(key, what) abort
  let c = col('.') - 1
  let l = getline('.')
  let after = strpart(l, c)
  let before = strpart(l, 0, c)
  " let g:msg = c.' --> <' . before . '> ## <'.after . '>'
  " echomsg g:msg
  if before =~ '^\s*$'
    if after =~ '^\s*$'
      return lh#map#insert_seq(a:key, a:what)
    else " => surround condition
      let ll = lh#leader#get_local()
      exe "normal ".ll.ll.a:key
    return ""
    endif
  else
    return a:key
  endif
endfunction

" Functions }}}2
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
