"=============================================================================
" File:         map-tools::lh#marker.vim                            {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"               <URL:http://github.com/LucHermitte>
" License:      GPLv3 with exceptions
"               <URL:http://github.com/LucHermitte/lh-brackets/License.md>
" Version:      3.1.1
let s:k_version = 311
" Created:      27th Nov 2013
"------------------------------------------------------------------------
" Description:
"       Functions to generate and handle |markers|
"
"------------------------------------------------------------------------
" History:
" Version 2.0.2
"       * Moves Marker_txt() to lh#marker#txt()
" TODO:         «missing features»
" }}}1
"=============================================================================

let s:cpo_save=&cpo
set cpo&vim
"------------------------------------------------------------------------
" ## Misc Functions     {{{1
" # Version {{{2
function! lh#marker#version()
  return s:k_version
endfunction

" # Debug   {{{2
let s:verbose = get(s:, 'verbose', 0)
function! lh#marker#verbose(...)
  if a:0 > 0 | let s:verbose = a:1 | endif
  return s:verbose
endfunction

function! s:Log(expr, ...)
  call call('lh#log#this',[a:expr]+a:000)
endfunction

function! s:Verbose(expr, ...)
  if s:verbose
    call call('s:Log',[a:expr]+a:000)
  endif
endfunction

function! lh#marker#debug(expr) abort
  return eval(a:expr)
endfunction

"------------------------------------------------------------------------
" ## Exported functions {{{1

" Function: lh#marker#open() {{{2
function! lh#marker#open() abort
  " ::call s:Verbose('lh#marker#open()')
  if s:Option('use_place_holders', 0) && exists('*IMAP_GetPlaceHolderStart')
    let m = IMAP_GetPlaceHolderStart()
    if !empty(m)
      ::call s:Verbose('lh#marker#open '.m.'  using IMAP placeholder characters')
      return m
    endif
  endif
  if !exists("b:marker_open")
    call s:Verbose( "b:marker_open is not set")
    " Note: \xab <=> <C-K><<
    call lh#marker#_set("\xab", '')
    ::call s:Verbose( "b:last_encoding_used is set to ".&enc)
    let b:last_encoding_used = &enc
  else
    if !exists('b:last_encoding_used')
      ::call s:Verbose( "b:last_encoding_used is not set")
      call lh#marker#_set(b:marker_open, b:marker_close, &enc)
      ::call s:Verbose( "b:last_encoding_used is set to ".&enc)
      let b:last_encoding_used = &enc
    elseif &enc != b:last_encoding_used
      call lh#marker#_set(b:marker_open, b:marker_close, b:last_encoding_used)
      ::call s:Verbose( "b:last_encoding_used is changed to ".&enc)
      let b:last_encoding_used = &enc
    endif
  endif
  ::call s:Verbose('lh#marker#open '.b:marker_open)
  return b:marker_open
endfunction

" Function: lh#marker#close() {{{2
function! lh#marker#close() abort
  if s:Option('use_place_holders', 0) && exists('*IMAP_GetPlaceHolderEnd')
    let m = IMAP_GetPlaceHolderEnd()
    if !empty(m)
      ::call s:Verbose('lh#marker#close '.m.'  using IMAP placeholder characters')
      return m
    endif
  endif
  if !exists("b:marker_close")
    ::call s:Verbose( "b:marker_close is not set")
    " Note: \xbb <=> <C-K>>>
    call lh#marker#_set('', "\xbb")
    ::call s:Verbose( "b:last_encoding_used is set to ".&enc)
    let b:last_encoding_used = &enc
  else " if exists('b:last_encoding_used')
    if &enc != b:last_encoding_used
      ::call s:Verbose( "b:last_encoding_used is different from current")
      call lh#marker#_set(b:marker_open, b:marker_close, b:last_encoding_used)
      ::call s:Verbose( "b:last_encoding_used is changed from ".b:last_encoding_used." to ".&enc)
      let b:last_encoding_used = &enc
    endif
  endif
  ::call s:Verbose('lh#marker#close '.b:marker_close)
  return b:marker_close
endfunction

" Function: lh#marker#txt({text}) {{{2
function! lh#marker#txt(...) abort
  return lh#marker#open() . ((a:0>0) ? a:1 : '') . lh#marker#close()
endfunction

" Function: lh#marker#very_magic(...) {{{3
function! s:EscapeVeryMagic(text)
  return escape(a:text, '$.*~()|\.{}<+>')
endfunction
function! lh#marker#very_magic(...) abort
  return s:EscapeVeryMagic(lh#marker#open()) . ((a:0>0) ? a:1 : '') . s:EscapeVeryMagic(lh#marker#close())
endfunction

" Function: lh#marker#is_a_marker(...) {{{3
" Returns whether the text currently selected matches a marker and only one.
function! lh#marker#is_a_marker(...) abort
  if a:0 > 0
    " Check whether the selected text matches a marker (and only one)
    return (a:1 =~ '^'.lh#marker#txt('.\{-}').'$')
          \ && (a:1 !~ '\%(.*'.lh#marker#close().'\)\{2}')
  else
    if line("'<") == line("'>") " I suppose markers don't spread over several lines
      " Extract the selected text
      let a = lh#visual#selection()

      " Check whether the selected text matches a marker (and only one)
      return lh#marker#is_a_marker(a)
    endif
    return 0
  endif
endfunction

"------------------------------------------------------------------------
" ## Internal functions {{{1
function! s:Option(name, default) " {{{2
  if     exists('b:'.a:name) | return b:{a:name}
  elseif exists('g:'.a:name) | return g:{a:name}
  else                       | return a:default
  endif
endfunction

function! lh#marker#_set(open, close, ...) abort " {{{2
  if !empty(a:close) && a:close == &enc
    throw ":SetMarker: two arguments expected"
  endif
  let from = (a:0!=0) ? a:1 : 'latin1'
  " :call Dfunc('lh#marker#_set('.a:open.','.a:close.','.from.')')

  " let ret = ''
  if !empty(a:open)
    let b:marker_open  = lh#encoding#iconv(a:open, from, &enc)
    " let ret = ret. "  b:open=".b:marker_open
  endif
  if !empty(a:close)
    let b:marker_close = lh#encoding#iconv(a:close, from, &enc)
    " let ret = ret . "  b:close=".b:marker_close
  endif
  " :call Dret("lh#marker#_set".ret)

  " Exploits Tom Link Stakeholders plugin if installed
  " http://www.vim.org/scripts/script.php?script_id=3326
  if exists(':StakeholdersEnable') && exists('b:marker_open') && exists('b:marker_close')
    let g:stakeholders#def = {'rx': b:marker_open.'\v(..{-})'.b:marker_close}
    " Seems to be required to update g:stakeholders#def.Replace(text)
    runtime autoload/stakeholders.vim
  endif
endfunction


"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
