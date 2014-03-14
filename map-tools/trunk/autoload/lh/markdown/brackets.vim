"=============================================================================
" $Id$
" File:         autoload/lh/markdown/brackets.vim                 {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://code.google.com/p/lh-vim/>
" License:      GPLv3 with exceptions
"               <URL:http://code.google.com/p/lh-vim/wiki/License>
" Version:	2.1.2
let s:k_version = 212
" Created:      14th Mar 2014
" Last Update:  $Date$
"------------------------------------------------------------------------
" Description:
"       Tweaking of lh-brackets functions for markdown
" }}}1
"=============================================================================

let s:cpo_save=&cpo
set cpo&vim
"------------------------------------------------------------------------
" ## Misc Functions     {{{1
" # Version {{{2
function! lh#markdown#brackets#version()
  return s:k_version
endfunction

" # Debug   {{{2
let s:verbose = 0
function! lh#markdown#brackets#verbose(...)
  if a:0 > 0 | let s:verbose = a:1 | endif
  return s:verbose
endfunction

function! s:Verbose(expr)
  if s:verbose
    echomsg a:expr
  endif
endfunction

function! lh#markdown#brackets#debug(expr)
  return eval(a:expr)
endfunction


"------------------------------------------------------------------------
" ## Exported functions {{{1

" # Pairs of markdown chars {{{2

" Function: lh#markdown#brackets#underscore() {{{3
function! lh#markdown#brackets#underscore()
  return s:Pair('_')
endfunction

" Function: lh#markdown#brackets#star() {{{3
function! lh#markdown#brackets#star()
  return s:Pair('*')
endfunction

" Function: s:Pair() {{{3
function! s:Pair(char)
  let col = col(".")
  let lig = getline(line("."))

  let result = a:char . '!cursorhere!' . a:char
  if lig[(col-2):(col-1)] == a:char . a:char
    return result
  elseif lig[col-1] == a:char
    let nb = matchend(lig[(col-1) :], escape(a:char, '*').'\+')
    return repeat("\<right>", nb).lh#brackets#_jump_text(lig[(col+nb-1) :])
  else
    return result.s:Mark()
  endif
endfunction

" Function: lh#markdown#brackets#strike() {{{3
function! lh#markdown#brackets#strike()
  let column = col(".")
  let lig = getline(line("."))
  let lig = lig[(column-1) :]
  if lig =~ '</del>'
    let length = len('</del>')
    let lig = lig[length : ]
    let res = repeat("\<right>", length)
    let res .= lh#brackets#_jump_text(lig)
    return res
  else
    return "<del>!cursorhere!</del>" . s:Mark()
  endif
endfunction

function! s:Mark()
  return exists("b:usemarks") && b:usemarks == 1
        \ ?  "!mark!"
        \ : ""
  endif
endfunction

" Function: lh#markdown#brackets#match_pair() {{{3
function! lh#markdown#brackets#match_pair()
  return getline(".")[col(".")-2:]=~'^\(\*\*\|__\|``\)'
endfunction

"------------------------------------------------------------------------
" ## Internal functions {{{1

"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
