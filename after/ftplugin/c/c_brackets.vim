"=============================================================================
" File:		ftplugin/c/c_brackets.vim                                {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"               <URL:http://github.com/LucHermitte/lh-brackets/>
" License:      GPLv3 with exceptions
"               <URL:http://github.com/LucHermitte/lh-brackets/tree/master/License.md>
" Version:	3.6.0
let s:k_version = 360
" Created:	26th May 2004
"------------------------------------------------------------------------
" Description:
" 	c-ftplugin that defines the default preferences regarding the
" 	bracketing mappings we want to use.
"
"------------------------------------------------------------------------
" Note:
" 	In order to override these default definitions, copy this file into a
" 	directory that comes before the {rtp}/after/ftplugin/c/ you choosed --
" 	typically $HOME/.vim/ftplugin/c/ (:h 'rtp').
" 	Then, replace the calls to :Brackets, without the `-default` flag
"
" History:
"       v3.6.0  16th Nov 2019
"               '}' will jump after the next non whitespace/newline that
"               is a curly-bracket or insert it.
"       v3.5.0  16th May 2018
"               Default :Brackets definitions can be disabled with
"               g:cb_disable_default/g:cb_enable_default
"	v3.3.0  02nd Oct 2017
"	        `;` jumps over `]`
"	v2.1.0  29th Jan 2014
"	        Mappings factorized into plugin/common_brackets.vim
"	v2.0.1  14th Aug 2013
"	        { now doesn't insert a new line anymore. but just "{}".
"	        Hitting <cr> while the cursor in between "{}", will add an
"	        extra line between the cursor and the closing bracket.
"	v2.0.0  11th Apr 2012
"	        License GPLv3 w/ extension
"	v1.0.0	19th Mar 2008
"		Exploit the new kernel from map-tools v1.0.0
"	v0.5    26th Sep 2007
"		No more jump on close
"	v0.4    25th May 2006
"	        Bug fix regarding the insertion of < in UTF-8
"	v0.3	31st Jan 2005
"		«<» expands into «<>!mark!» after: «#include», and after some
"		C++ keywords: «reinterpret_cast», «static_cast», «const_cast»,
"		«dynamic_cast», «lexical_cast» (from boost), «template» and
"		«typename[^<]*»
" TODO:
" }}}1
"=============================================================================


"=============================================================================
" Buffer-local Definitions {{{1
" Avoid buffer reinclusion {{{2
if exists('b:loaded_ftplug_c_brackets') && !exists('g:force_reload_ftplug_c_brackets')
  finish
endif
let b:loaded_ftplug_c_brackets = s:k_version

let s:cpo_save=&cpo
set cpo&vim
"------------------------------------------------------------------------
" Brackets & all {{{2
" ------------------------------------------------------------------------
" It seems that function() does not load anything with some versions of vim
if !exists('lh#cpp#brackets#lt')
  runtime autoload/lh/cpp/brackets.vim
endif

if ! lh#option#get('cb_no_default_brackets', 0)
  let b:cb_jump_on_close = 1

  " Re-run brackets() in order to update the mappings regarding the different
  " options.
  :Brackets < > -default -open=function('lh#cpp#brackets#lt') -visual=0
  :Brackets { } -default -visual=1 -insert=0 -nl -trigger=<localleader>{
  "}
  :Brackets { } -default -visual=0 -insert=1
        \ -open=function('lh#cpp#brackets#curly_open')
        \ -clos=function('lh#cpp#brackets#curly_close')

  " Support for C++11 [[attributes]]
  :Brackets [ ] -default -visual=0 -insert=1
        \ -open=function('lh#cpp#brackets#square_open')
        \ -clos=function('lh#cpp#brackets#square_close')

  " Doxygen surround action
  :Brackets <tt> </tt> -default -visual=1 -insert=0 -trigger=<localleader>tt
  " In insert mode, this needs to be expanded only in comment context
  "  - first \\ becomes \
  "  - last \ required before | to avoid confusion with :h :bar
  "  -> \\\|
  :Brackets ` ` -default -insert=1 -visual=0 -normal=0 -context=comment\\\|doxygen
  :Brackets ` ` -default -insert=0 -visual=1 -normal=0
  " :Brackets /* */ -default -visual=0
  " :Brackets /** */ -default -visual=0 -trigger=/!

  " eclipse (?) behaviour (placeholders are facultatives)
  " '(foo|«»)«»' + ';'     --> '("foo");|'
  " '("foo|"«»)«»' + ';'   --> '("foo");|'
  " '(((foo|)«»)«»)' + ';' --> '(((foo)));|'
  " '[foo|«»]«»' + ';'     --> '["foo"];|'
  " 'for(yoyo|;)'          --> 'for(yoyo|;)' # case ignored
  " 'if(yoyo|;)'           --> 'if(yoyo|;)'  # case ignored (C++17)
  if lh#ft#option#get('semicolon_closes_bracket', &ft, 1)
    call lh#brackets#define_imap(';', 'lh#cpp#brackets#semicolon()', 1, ';')

    " Override default definition from lh-brackets to take care of semi-colon
    call lh#brackets#define_imap('<bs>',
          \ [{ 'condition': 'getline(".")[:col(".")-2]=~".*\"\\s*)\\+;$"',
          \   'action': 'lh#cpp#brackets#move_semicolon_back_to_string_context()'},
          \  { 'condition': 'lh#brackets#_match_any_bracket_pair()',
          \   'action': 'lh#brackets#_delete_empty_bracket_pair()'}],
          \ 1,
          \ '\<bs\>'
          \ )
  endif
endif
" }}}1
"=============================================================================
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
