"=============================================================================
" File:		autoload/lh/brackets.vim                               {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"               <URL:http://github.com/LucHermitte>
" License:      GPLv3 with exceptions
"               <URL:http://github.com/LucHermitte/lh-brackets/License.md>
" Version:	3.6.0
" Created:	20th Mar 2008
"------------------------------------------------------------------------
" Description:
" 	Functions that tune how some bracket characters should expand in VimL
" }}}1
"=============================================================================

"------------------------------------------------------------------------
let s:cpo_save=&cpo
set cpo&vim
"------------------------------------------------------------------------
" ## Misc Functions     {{{1
" # Version {{{2
function! lh#vim#brackets#version()
  return s:k_version
endfunction

" # Debug   {{{2
let s:verbose = get(s:, 'verbose', 0)
function! lh#vim#brackets#verbose(...)
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

function! lh#vim#brackets#debug(expr) abort
  return eval(a:expr)
endfunction

"------------------------------------------------------------------------
" ## API {{{1
" Inserts '<>' on '<', except after an if or within comment. {{{2
" This rule knows an exception : within a string, or after a '\', '<' is
" always converted to '<>'.
" Does not handle special characters like ''<' and ''>'
" Updated on 08th May 2004
function! lh#vim#brackets#lt() abort
  let l = getline('.')
  let c = col('.') - 1
  let syn = synIDattr(synID(line('.'),c,1),'name')
  if (l[c-1] != '\') && (syn !~? '\(string\)\|\(character\)')
    if (syn =~? 'comment') || (l =~ '\v.*<(if|elseif|while|let\s+\S+|AssertBuf|SetBuf)\s*.*')
      return '<'
    endif
  endif
  if lh#brackets#usemarks()
    return '<!cursorhere!>!mark!'
  else
    return '<!cursorhere!>'
  endif
endfunction

" Inserts '""' on '"', except for comments {{{2
" (supposed equivalent to empty lines)
" Heuristic used:
" - before a '"',
"   - within a vimString => likely a string to close => move
"   - insert "|"
" - after ')', it can not be a string => comment
" - in the beginning of a line ('^\s*$') => comment
" - otherwise => string
function! lh#vim#brackets#dquotes() abort
  " TEST: OK sans imaps.vim
  let line = getline(line('.'))
  let col = col('.')-1
  let l = strpart(line, 0, col)
  if  line[col] == '"'
    call s:Verbose('match_at(%1, %2) : %3', line('.'), col, map(synstack(line('.'), col), 'synIDattr(v:val, "name")'))
    if lh#syntax#match_at('vimString', line('.'), col)
      return lh#brackets#_jump()
    else
      " Insert a string before another string
      return '"!cursorhere!"!mark!.'
    endif
  elseif l =~ '\m)\s*$\|^\s*$'
    return '"'
  elseif lh#brackets#usemarks()
    return '"!cursorhere!"!mark!'
  else
    return '""'.  lh#map#_move_cursor_on_the_current_line(-1)
  endif
endfunction
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
