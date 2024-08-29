"=============================================================================
" File:         tests/lh/vim-brackets.vim                         {{{1
" Author:       Luc Hermitte <EMAIL:luc {dot} hermitte {at} gmail {dot} com>
"		<URL:http://github.com/LucHermitte/lh-brackets>
" License:      GPLv3 with exceptions
"               <URL:http://github.com/LucHermitte/lh-brackets/blob/master/License.md>
" Version:      3.6.0.
let s:k_version = '360'
" Created:      16th May 2020
" Last Update:  29th Aug 2024
"------------------------------------------------------------------------
" Description:
"       Tests of vim specific bracket mappings
" }}}1
"=============================================================================

UTSuite [lh#brackets] Testing vim mappings

runtime plugin/bracketing.base.vim
runtime plugin/common_brackets.vim
runtime plugin/misc_map.vim
runtime autoload/lh/brackets.vim
runtime autoload/lh/vim/brackets.vim

let s:cpo_save=&cpo
set cpo&vim

"------------------------------------------------------------------------
function! s:BeforeAll() abort
  " Vim tests need "syntax on", they cannot succeed without them
  Assert! has('syntax')
  let s:syn = get(g:, 'syntax_on', 0)
  syntax on
  call lh#window#create_window_with('sp vim-test-buffer.vim')
endfunction

function! s:AfterAll() abort
  silent bw! vim-test-buffer.vim
  if !s:syn
    syntax off
  endif
endfunction

"------------------------------------------------------------------------
function! s:Test_dquote_comment_on_empty_line()
  SetBufferContent trim << EOF
  EOF

  exe 'normal a"toto'."\<cr>\<esc>"
  normal S   " titi

  AssertBufferMatches trim << EOF
  "toto
     " titi
  EOF
endfunction

"------------------------------------------------------------------------
function! s:Test_dquote_comment_after_parent()
  SetBufferContent trim << EOF
  call foobar()
  EOF

  normal A " toto

  AssertBufferMatches trim << EOF
  call foobar() " toto
  EOF
endfunction

"------------------------------------------------------------------------
" Function: s:Test_dquote_new_string() {{{3
function! s:Test_dquote_new_string() abort
  SetBufferContent trim << EOF
  EOF

  " Just the insertion of the pair
  exe "normal alet toto = \<esc>a\"titi"
  " Check closing of empty string
  normal olet toto = ""bli
  " Check closing
  normal olet toto = "titi"bli
  " check redoable
  normal! .

  AssertBufferMatches trim << EOF
  let toto = "titi"«»
  let toto = ""bli
  let toto = "titi"bli
  let toto = "titi"bli
  EOF
endfunction

"------------------------------------------------------------------------
" Function: s:Test_dquote_before_string() {{{3
function! s:Test_dquote_before_string() abort
  SetBufferContent trim << EOF
  let toto = "titi"
  EOF

  normal ^f"i"foo

  AssertBufferMatches trim << EOF
  let toto = "foo"«»."titi"
  EOF
endfunction
"------------------------------------------------------------------------
" Function: s:Test_dquote_within_string() {{{3
function! s:Test_dquote_within_string() abort
  SetBufferContent trim << EOF
  let toto = "toto"
  let titi = 'titi'
  EOF

  call setpos('.', [0, 1, 14, 0])
  normal a"|

  call setpos('.', [0, 2, 14, 0])
  normal a"|


  AssertBufferMatches trim << EOF
  let toto = "to"|"«»to"
  let titi = 'ti"|"«»ti'
  EOF
endfunction

" }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
