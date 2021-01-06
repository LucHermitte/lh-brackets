"=============================================================================
" File:         tests/lh/html-brackets.vim                        {{{1
" Author:       Luc Hermitte <EMAIL:luc {dot} hermitte {at} gmail {dot} com>
"		<URL:http://github.com/LucHermitte/lh-brackets>
" License:      GPLv3 with exceptions
"               <URL:http://github.com/LucHermitte/lh-brackets/blob/master/License.md>
" Version:      3.6.0.
let s:k_version = '360'
" Created:      17th May 2020
" Last Update:  06th Jan 2021
"------------------------------------------------------------------------
" Description:
"       Tests of vim specific bracket mappings
" }}}1
"=============================================================================

UTSuite [lh#brackets] Testing html mappings

runtime plugin/bracketing.base.vim
runtime plugin/common_brackets.vim
runtime plugin/misc_map.vim
runtime autoload/lh/brackets.vim
runtime autoload/lh/html/brackets.vim

let s:cpo_save=&cpo
set cpo&vim

"------------------------------------------------------------------------
function! s:BeforeAll() abort
  call lh#window#create_window_with('sp vim-test-buffer.html')
endfunction

function! s:AfterAll() abort
  silent bw! vim-test-buffer.html
endfunction

function! s:Setup() abort
  let s:cleanup = lh#on#exit()
        \.restore('b:usemarks')
endfunction

function! s:Teardown() abort
  call s:cleanup.finalize()
endfunction

"------------------------------------------------------------------------
function! s:Test_lt_gt_with_usemark()
  %d_

  let b:usemarks = 1
  Comment "imap < ---> ".strtrans(maparg('<', 'i'))
  AssertMatches! (maparg('<', 'i'), "lh#brackets#opener")
  " call feedkeys('a<', 'x')
  " redraw
  " call feedkeys('o<<', 'x')
  " call feedkeys('o<>', 'x')
  " call feedkeys('o<toto', 'x')
  " call feedkeys("o<toto\<esc>a>ti", 'x')
  " redraw
  normal a<
  normal o<<
  normal o<>
  normal o<toto
  " normal o<toto>ti
  exe "normal o<toto\<esc>a>ti"

  AssertBufferMatches trim << EOF
  <>«»
  &lt;
  &gt;
  <toto>«»
  <toto>ti
  EOF
endfunction

function! s:Test_lt_gt_without_usemark()
  %d_

  let b:usemarks = 0
  normal a<
  normal o<<
  normal o<>
  normal o<toto
  " normal o<toto>ti
  exe "normal o<toto\<esc>a>ti"
  " call feedkeys("o<toto\<esc>a>ti", 'x')

  AssertBufferMatches trim << EOF
  <>
  &lt;
  &gt;
  <toto>
  <toto>ti
  EOF
endfunction

"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
