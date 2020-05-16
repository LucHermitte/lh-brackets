"=============================================================================
" File:         autoload/lh/html/brackets.vim                             {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"               <URL:http://github.com/LucHermitte>
" License:      GPLv3 with exceptions
"               <URL:http://github.com/LucHermitte/lh-brackets/License.md>
" Version:      3.6.0
let s:k_version = '360'
" Created:      24th Mar 2008
"------------------------------------------------------------------------
" Description:
"       Functions that tune how some bracket characters should expand in C&C++
" }}}1
"=============================================================================

let s:cpo_save=&cpo
set cpo&vim

" ## Misc Functions     {{{1
" # Version {{{2
function! lh#html#brackets#version()
  return s:k_version
endfunction

" # Debug   {{{2
let s:verbose = get(s:, 'verbose', 0)
function! lh#html#brackets#verbose(...)
  if a:0 > 0 | let s:verbose = a:1 | endif
  return s:verbose
endfunction

function! s:Log(expr, ...) abort
  call call('lh#log#this',[a:expr]+a:000)
endfunction

function! s:Verbose(expr, ...) abort
  if s:verbose
    call call('s:Log',[a:expr]+a:000)
  endif
endfunction

function! lh#html#brackets#debug(expr) abort
  return eval(a:expr)
endfunction

"------------------------------------------------------------------------
" ## Hooks {{{1
function! lh#html#brackets#lt() abort
  return s:Insert('<')
endfunction

function! lh#html#brackets#gt() abort
  return s:Insert('>')
endfunction

" '<' automatically inserts its counter part
" '>' reach the next '>'
" While '<'+'<' inserts '&lt;' and '<'+'>' inserts '&gt;'
"
" And '<' + '/' will insert the closing tag associated to the previous one
" not already closed.

" Which==0 <=> '<';
function! s:Insert(which) abort
  let column = col(".")
  let lig = getline(".")
  if lig[column-2] == '<'
    let ret = "\<BS>&". ((a:which == '<') ? 'lt;' : 'gt;')
    if lig[column-1] == '>'
      let ret = "\<del>" . ret
    endif
    let marker = lh#marker#txt()
    if strpart(lig, column) =~ '\V'.escape(marker, '\')
      let ret .= substitute(marker, '.', "\<del>", 'g')
    endif
    return ret
  else
    if     a:which == '<'       | return '<!cursorhere!>!mark!'
    elseif lig[column-1] == '>' | return lh#brackets#_jump()
    else                        | return '>'
    endif
  endif
endfunction

"
function! s:CloseTag() abort
  let ret = '/'
  let column = col(".")
  let lig = getline(line("."))
  if lig[column-2] == '<'
    " find the previous match ... perhaps thanks to matchit
    let ret = "\<BS>&lt;"
    if lig[column-1] == '>'
      let ret = "\<Right>\<BS>" . ret
    endif
  endif
  return ret;
endfunction

let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
