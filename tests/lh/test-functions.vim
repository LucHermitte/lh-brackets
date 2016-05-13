"=============================================================================
" File:         tests/lh/test-functions.vim                       {{{1
" Author:       Luc Hermitte <EMAIL:luc {dot} hermitte {at} gmail {dot} com>
"		<URL:http://github.com/LucHermitte/lh{rackets>
" Version:      3.0.6.
let s:k_version = '306'
" Created:      13th May 2016
" Last Update:  13th May 2016
"------------------------------------------------------------------------
" Description:
"       Test lh-brackets functions
" }}}1
"=============================================================================

UTSuite [lh-brackets] Testing lh/brackets.vim

runtime autoload/lh/brackets.vim

let s:cpo_save=&cpo
set cpo&vim

"------------------------------------------------------------------------
function! s:Test_bracket_string()
  AssertEqual( lh#brackets#_string('foo\nbar'), '"foo\nbar"')
  AssertEqual( lh#brackets#_string('foo\\bar'), '"foo\\bar"')
  AssertEqual( lh#brackets#_string('\\Q{'), '"\\Q{"')
endfunction

"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
