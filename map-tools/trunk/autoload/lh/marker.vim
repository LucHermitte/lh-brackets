"=============================================================================
" $Id$
" File:         map-tools::lh#marker.vim                            {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://code.google.com/p/lh-vim/>
" License:      GPLv3 with exceptions
"               <URL:http://code.google.com/p/lh-vim/wiki/License>
" Version:      2.0.2
" Created:      27th Nov 2013
" Last Update:  $Date$
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
let s:k_version = 202
function! lh#marker#version()
  return s:k_version
endfunction

" # Debug   {{{2
let s:verbose = 0
function! lh#marker#verbose(...)
  if a:0 > 0 | let s:verbose = a:1 | endif
  return s:verbose
endfunction

function! s:Verbose(expr)
  if s:verbose
    echomsg a:expr
  endif
endfunction

function! lh#marker#debug(expr)
  return eval(a:expr)
endfunction


"------------------------------------------------------------------------
" ## Exported functions {{{1

" Function: lh#marker#open() {{{2
function! lh#marker#open()
  " call Dfunc('Marker_Open()')
  if s:Option('use_place_holders', 0) && exists('*IMAP_GetPlaceHolderStart')
    let m = IMAP_GetPlaceHolderStart()
    if "" != m 
      " call Dret('Marker_Open '.m.'  using IMAP placeholder characters')
      return m 
    endif
  endif
  if !exists("b:marker_open") 
    " :call Decho( "b:marker_open is not set")
    " Note: \xab <=> <C-K><<
    call s:SetMarker("\xab", '')
    " :call Decho( "b:last_encoding_used is set to ".&enc)
    let b:last_encoding_used = &enc
  else
    if !exists('s:last_encoding_used')
      " :call Decho( "s:last_encoding_used is not set")
      call s:SetMarker(b:marker_open, b:marker_close, &enc)
      " :call Decho( "b:last_encoding_used is set to ".&enc)
      let b:last_encoding_used = &enc
    elseif &enc != b:last_encoding_used
      call s:SetMarker(b:marker_open, b:marker_close, b:last_encoding_used)
      " :call Decho( "b:last_encoding_used is changed to ".&enc)
      let b:last_encoding_used = &enc
    endif
  endif
  " call Dret('Marker_Open '.b:marker_open)
  return b:marker_open
endfunction

" Function: lh#marker#close() {{{2
function! lh#marker#close()
  if s:Option('use_place_holders', 0) && exists('*IMAP_GetPlaceHolderEnd')
    let m = IMAP_GetPlaceHolderEnd()
    if "" != m 
      " call Dret('Marker_Close '.m.'  using IMAP placeholder characters')
      return m 
    endif
  endif
  if !exists("b:marker_close") 
    " :call Decho( "b:marker_close is not set")
    " Note: \xbb <=> <C-K>>>
    call s:SetMarker('', "\xbb")
    " :call Decho( "b:last_encoding_used is set to ".&enc)
    let b:last_encoding_used = &enc
  else " if exists('s:last_encoding_used')
    if &enc != b:last_encoding_used
      " :call Decho( "b:last_encoding_used is different from current")
      call s:SetMarker(b:marker_open, b:marker_close, b:last_encoding_used)
      " :call Decho( "b:last_encoding_used is changed from ".b:last_encoding_used." to ".&enc)
      let b:last_encoding_used = &enc
    endif
  endif
  return b:marker_close
endfunction

" Function: lh#marker#txt({text}) {{{2
function! lh#marker#txt(...)
  return lh#marker#open() . ((a:0>0) ? a:1 : '') . lh#marker#close()
endfunction

"------------------------------------------------------------------------
" ## Internal functions {{{1
function! s:Option(name, default) " {{{2
  if     exists('b:'.a:name) | return b:{a:name}
  elseif exists('g:'.a:name) | return g:{a:name}
  else                       | return a:default
  endif
endfunction

function! s:SetMarker(open, close, ...) " {{{2
  if a:close != '' && a:close == &enc
    throw ":SetMarker: two arguments expected"
  endif
  let from = (a:0!=0) ? a:1 : 'latin1'
  " :call Dfunc('s:SetMarker('.a:open.','.a:close.','.from.')')

  " let ret = ''
  if '' != a:open
    let b:marker_open  = lh#encoding#iconv(a:open, from, &enc)
    " let ret = ret. "  b:open=".b:marker_open
  endif
  if '' != a:close
    let b:marker_close = lh#encoding#iconv(a:close, from, &enc)
    " let ret = ret . "  b:close=".b:marker_close
  endif
  " :call Dret("s:SetMarker".ret) 

  " Exploits Tom Link Stakeholders plugin if installed
  " http://www.vim.org/scripts/script.php?script_id=3326
  if exists(':StakeholdersEnable') && exists('b:marker_open') && exists('b:marker_close') 
    let g:stakeholders#def = {'rx': b:marker_open.'\(..\{-}\)'.b:marker_close}
    " Seems to be required to update g:stakeholders#def.Replace(text)
    runtime autoload/stakeholders.vim
  endif
endfunction
command! -nargs=+ SetMarker :call <sid>SetMarker(<f-args>, &enc)<bar>:call <sid>UpdateHighlight()


"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
