"=============================================================================
" File:         autoload/lh/markdown/brackets.vim                 {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"               <URL:http://github.com/LucHermitte>
" License:      GPLv3 with exceptions
"               <URL:http://github.com/LucHermitte/lh-brackets/License.md>
" Version:	2.3.0
let s:k_version = 230
" Created:      14th Mar 2014
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
  if getline('.')[:col('.')-1] =~ '\s\+$'
    " Enumerations
    return '* '
  else
    return s:Pair('*')
  endif
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
    return lh#map#_move_cursor_on_the_current_line(nb).lh#brackets#_jump_text(lig[(col+nb-1) :])
  elseif     lh#syntax#name_at(line('.'), col-1) =~ 'markdownCode'
        \ && lh#syntax#name_at(line('.'), col)   =~ 'markdownCode'
    return a:char
  else
    return result.s:Mark()
  endif
endfunction

" Function: lh#markdown#brackets#strike() {{{3
function! lh#markdown#brackets#strike()
  let col = col(".")
  let lig = getline(line("."))
  let lig = lig[(col-1) :]
  if lig =~ '</del>'
    let length = len('</del>')
    let lig = lig[length : ]
    let res = repeat("\<right>", length)
    let res .= lh#brackets#_jump_text(lig)
    return res
  elseif     lh#syntax#name_at(line('.'), col-1) =~ 'markdownCode'
        \ && lh#syntax#name_at(line('.'), col)   =~ 'markdownCode'
    return '~'
  else
    return "<del>!cursorhere!</del>" . s:Mark()
  endif
endfunction

function! s:Mark()
  return lh#brackets#usemarks()
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
