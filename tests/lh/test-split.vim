"=============================================================================
" File:         tests/lh/test-split.vim                           {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} gmail {dot} com>
"		<URL:http://github.com/LucHermitte/lh-brackets>
" Version:      2.2.5.
let s:k_version = '225'
" Created:      02nd Nov 2015
" Last Update:
"------------------------------------------------------------------------
" Description:
"       UT for lh-brackets's _split_line function
" }}}1
"=============================================================================

UTSuite [lh-brackets] Testing _split_line

runtime autoload/lh/brackets.vim

let s:cpo_save=&cpo
set cpo&vim

"------------------------------------------------------------------------
function! s:Test_split()
  let line1 = 'toooooooooooooooooooooooooooooooooo oooooooooooooooooooooooooo *ttvvabcdefghijklmnopqrstuvwxtttt tttt'
  let line2 = 'toooooooooooooooooooooooooooooooooo oooooooooooooooooooooooooo *ttvvabcdefg hijklmnopqrstuvwxtttttttt'

  let tw = 78
  let head = 'toooooooooooooooooooooooooooooooooo oooooooooooooooooooooooooo'
  let before = '*ttvvabcdefg'
  let after1 = 'hijklmnopqrstuvwxtttt tttt'
  let after2 = ' hijklmnopqrstuvwxtttttttt'

  AssertEquals(lh#brackets#_split_line(line1, 76, tw), [head, before, after1])
  AssertEquals(lh#brackets#_split_line(line2, 76, tw), [head, before, after2])
endfunction

"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
