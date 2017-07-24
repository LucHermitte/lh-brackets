"===========================================================================
" File:         plugin/misc_map.vim
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"               <URL:http://github.com/LucHermitte>
" License:      GPLv3 with exceptions
"               <URL:http://github.com/LucHermitte/lh-brackets/License.md>
" Version:	3.2.0
"
" Purpose:      API plugin: Several mapping-oriented functions
"
" Todo:         Use the version of EatChar() from Benji Fisher's foo.vim
"---------------------------------------------------------------------------
" Function:     MapNoContext( key, sequence)                            {{{
" Purpose:      Regarding the context of the current position of the
"               cursor, it returns either the value of key or the
"               interpreted value of sequence.
" Parameters:   <key> - returned while whithin comments, strings or characters
"               <sequence> - returned otherwise. In order to enable the
"                       interpretation of escaped caracters, <sequence>
"                       must be a double-quoted string. A backslash must be
"                       inserted before every '<' and '>' sign. Actually,
"                       the '<' after the second one (included) must be
"                       backslashed twice.
" Example:      A mapping of 'if' for C programmation :
"   inoremap if<space> <C-R>=MapNoContext("if ",
"   \                           '\<c-f\>if () {\<cr\>}\<esc\>?)\<cr\>i')<CR>
" }}}
"---------------------------------------------------------------------------
" Function:     MapNoContext2( key, sequence)                           {{{
" Purpose:      Exactly the same purpose than MapNoContext(). There is a
"               slight difference, the previous function is really annoying
"               when we want to use variables like 'tarif' in the code.
"               So this function also returns <key> when the character
"               before the current cursor position is not a keyword
"               character ('h: iskeyword' for more info).
" Hint:         Use MapNoContext2() for mapping keywords like 'if', etc.
"               and MapNoContext() for other mappings like parenthesis,
"               punctuations signs, and so on.
" }}}
"---------------------------------------------------------------------------
" Function:     MapContext( key, syn1, seq1, ...[, default-seq])        {{{
" Purpose:      Exactly the same purpose than MapNoContext(), but more precise.
"               Returns:
"               - {key} within string, character or comment context,
"               - interpreted {seq_i} within {syn_i} context,
"               - interpreted {default-seq} otherwise ; default value: {key}
" }}}
"---------------------------------------------------------------------------
" Function:     Map4TheseContexts( key, syn1, seq1, ...[, default-seq]) {{{
" Purpose:      Exactly the same purpose than MapContext(), but even more
"               precise. It does not make any assumption for strings-,
"               comments-, characters- and doxygen-context.
"               Returns:
"               - interpreted {seq_i} within {syn_i} context,
"               - interpreted {default-seq} otherwise ; default value: {key}
" }}}
"---------------------------------------------------------------------------
" Function:     BuildMapSeq( sequence )                                 {{{
" Purpose:      This function is to be used to generate the sequences used
"               by the «MapNoContext» functions. It considers that every
"               «!.\{-}!» pattern is associated to an INSERT-mode mapping and
"               expands it.
"               It is used to define marked mappings ; cf <c_set.vim>
" }}}
"---------------------------------------------------------------------------
" Function:     InsertAroundVisual(begin,end,isLine,isIndented) range {{{
" Old Name:     MapAroundVisualLines(begin,end,isLine,isIndented) range
" Purpose:      Ease the definition of visual mappings that add text
"               around the selected one.
" Examples:
"   (*) LaTeX-like stuff
"       if &ft=="tex"
"         vnoremap ;; :call InsertAroundVisual(
"                     \ '\begin{center}','\end{center}',1,1)<cr>
"   (*) C like stuff
"       elseif &ft=="c" || &ft=="cpp"
"         vnoremap ;; :call InsertAroundVisual('else {','}',1,1)<cr>
"   (*) VIM-like stuff
"       elseif &ft=="vim"
"         vnoremap ;; :call InsertAroundVisual('if','endif',1,1)<cr>
"       endif

" Fixed Problem:
" * if a word from 'begin' or 'end' is used as a terminaison of an
" abbreviation, this function yields to an incorrect behaviour.
" Problems:
" * Smartindent is not properly managed. [Vim 5.xx]
" Todo:
" * Add a positionning feature -> ?{<cr>a
"   => Use Surround()
" }}}
"---------------------------------------------------------------------------
" Function:     ReinterpretEscapedChar(sequence)  {{{
" Purpose:      This function transforms '\<cr\>', '\<esc\>', ... '\<{keys}\>'
"               into the interpreted sequences "\<cr>", "\<esc>", ...
"               "\<{keys}>".
"               It is meant to be used by fonctions like MapNoContext(),
"               InsertSeq(), ... as we can not define mappings (/abbreviations)
"               that contain "\<{keys}>" into the sequence to insert.
" Note:         It accepts sequences containing double-quotes.
" Deprecated:   Use lh#mapping#reinterpret_escaped_char
" }}}
"---------------------------------------------------------------------------
" Function:     InsertSeq(key, sequence, [context]) {{{
" Purpose:      This function is meant to return the {sequence} to insert when
"               the {key} is typed. The result will be function of several
"               things:
"               - the {sequence} will be interpreted:
"                 - special characters can be used: '\<cr\>', '\<esc\>', ...
"                   (see lh#mapping#reinterpret_escaped_char()) ; '\n'
"                 - we can embed insert-mode mappings whose keybindings match
"                   '!.\{-}!' (see BuildMapSeq())
"                   A special treatment is applied on:
"                   - !mark! : according to [bg]:usemarks, it is replaced by
"                     lh#marker#txt() or nothing
"                   - !cursorhere! : will move the cursor to that position in
"                     the sequence once it have been expanded.
"               - the context ; by default, it returns the interpreted sequence
"                 when we are not within string, character or comment context.
"                 (see MapNoContext())
"                 Thanks to the optional parameter {context}, we can ask to
"                 expand and interpret the {sequence} only within some
"                 particular {context}.
"
" Examples:
"  (*) Excerpt for my vim-ftplugin
"    inoremap  <buffer> <silent> <M-c>
"     \ <c-r>=InsertSeq('<m-c>', ':call !cursorhere!(!mark!)!mark!')<cr>
"    inoreab  <buffer> <silent>  fun
"     \ <C-R>=InsertSeq('fun',
"     \ 'function!!cursorhere!(!mark!)\n!mark!\nendfunction!mark!')<CR>
" }}}
"---------------------------------------------------------------------------
" Function:     Surround(begin,end,isLine,isIndented,goback,mustInterpret [, im_seq]) range {{{
" Purpose:      This function is a smart wrapper around InsertAroundVisual().
"               It permit to interpret {begin} and {end} and it also recognizes
"               whether what we must surround is a marker or not.
"
"               The point is that there is no :smap command in VimL, and that
"               insert-mode mappings (imm) should have the precedence over
"               visual-mode mappings (vmm) when we deals with selected markers
"               (select-mode) ; unfortunatelly, it is the contrary: vim gives
"               the priority to vmm over imm.
"
" Parameters:
" {begin}, {end}        strings
"       The visual selection is surrounded by {begin} and {end}, unless what is
"       selected is one (and only one) marker. In that latter case, the
"       function returns a sequence that will replace the selection by {begin}
"       ; if {begin} matches the keybinding of an insert-mode mapping, it will
"       be expanded.
" {goback}              string
"       This is the normal-mode sequence to execute after the selected text has
"       been surrounded; it is meant to place the cursor at the end of {end}
"       Typical values are '%' for true-brackets (), {}, []
"       or '`>ll' when strlen(a:end) == 1.
"       Note: This sequence will be expanded if it contains mappings or
"       abbreviations -- this is a feature. see {rtp}/ftplugin/vim_set.vim
" {mustInterpret}       boolean
"       Indicates whether we must try to find and expand mappings of the form
"       "!.\{-1,}!" within {begin} and {end}
"       When true:
"       - [bg]:usemarks is taken into account: when false, {begin} and {end} will
"         be cleared from every occurence of "!mark!".
"       - if {begin} or {end} contain "!cursorhere!", {goback} will be ignored
"         and replaced by a more appropriate value.
" [{a:1}=={im_seq}]     string
"       Insert-mode sequence that must be returned instead of {begin} if we try
"       to surround a marker.
"       Note: This sequence will be expanded if it contains mappings or
"       abbreviations -- this is a feature. see {rtp}/ftplugin/vim_set.vim
"
" Usage:
"       :vnoremap <buffer> {key} <c-\><c-n>@=Surround({parameters})<cr>
"
" Examples:
"  (*) Excerpt from common_brackets.vim
"    :vnoremap <buffer> [ <c-\><c-n>@=Surround('[', ']', 0, 0, '%', 0)<cr>
"  (*) Excerpt from my vim-ftplugin
"    :vnoremap <buffer> <silent> <m-f>
"     \ <c-\><c-n>@=Surround('function! !cursorhere!(!mark!)', 'endfunction',
"     \ 1, 1, '', 1, 'fun ')<cr>
"  (*) Excerpt from my c-ftplugin
"    :vnoremap <buffer> <silent> <localleader>for
"     \ <c-\><c-n>@=Surround('for (!cursorhere!;!mark!;!mark!) {', '}!mark!',
"     \ 1, 1, '', 1, 'for ')<cr>
"
" }}}
"===========================================================================
"
"---------------------------------------------------------------------------
" Avoid reinclusion
if !exists('g:misc_map_loaded') || exists('g:force_reload_misc_map')
  let g:misc_map_loaded = 230
  let cpop = &cpoptions
  set cpoptions-=C
  scriptencoding latin1
"
"---------------------------------------------------------------------------
function! Map4TheseContexts(key, ...) abort " {{{
  call lh#notify#deprecated('Map4TheseContexts', 'lh#map#4_these_contexts')
  return call('lh#map#4_these_contexts', [a:key] + a:000)
endfunction
" }}}
"---------------------------------------------------------------------------
function! MapContext(key, ...) abort " {{{
  call lh#notify#deprecated('MapContext', 'lh#map#context')
  return call('lh#map#context', [a:key] + a:000)
endfunction
" }}}
"---------------------------------------------------------------------------
function! MapNoContext(key, seq) abort " {{{
  call lh#notify#deprecated('MapNoContext', 'lh#map#no_context')
  return call('lh#map#no_context', [a:key, a:seq])
endfunction
" }}}
"---------------------------------------------------------------------------
function! MapNoContext2(key, seq) abort " {{{
  call lh#notify#deprecated('MapNoContext2', 'lh#map#no_context2')
  return call('lh#map#no_context2', [a:key, a:seq])
endfunction
" }}}
"---------------------------------------------------------------------------
function! BuildMapSeq(seq) abort " {{{
  call lh#notify#deprecated('BuildMapSeq', 'lh#map#build_map_seq')
  return lh#map#build_map_seq(a:seq)
endfunction
" }}}
"---------------------------------------------------------------------------
function! ReinterpretEscapedChar(seq) abort " {{{
  call lh#notify#deprecated('ReinterpretEscapedChar', 'lh#mapping#reinterpret_escaped_char')
  return lh#mapping#reinterpret_escaped_char(a:seq)
endfunction
" }}}
"---------------------------------------------------------------------------
function! MapAroundVisualLines(begin,end,isLine,isIndented) range abort " {{{
  :'<,'>call InsertAroundVisual(a:begin, a:end, a:isLine, a:isIndented)
endfunction " }}}

function! InsertAroundVisual(begin,end,isLine,isIndented) range abort " {{{
  call lh#notify#deprecated('InsertAroundVisual', 'lh#map#insert_around_visual')
  return call('lh#map#insert_around_visual', [a:begin,a:end,a:isLine,a:isIndented] + a:000)
endfunction
" }}}
"---------------------------------------------------------------------------
" Function: EatChar()   {{{
" Thanks to the VIM Mailing list ;
" Note: In it's foo.vim, Benji Fisher maintains a more robust version of this
" function; see: http://www.vim.org/script.php?script_id=72
" NB: To make it work with VIM 5.x, replace the '? :' operator with an 'if
" then' test.
" This version does not support multi-bytes characters.
" Todo: add support for <buffer>
" Deprecated: use lh#map#eat_char()
function! EatChar(pat)
  call lh#notify#deprecated('EatChar', 'lh#map#eat_char')
  return lh#map#eat_char(a:pat)
endfunction

command! -narg=+ Iabbr execute "iabbr " <q-args>."<C-R>=lh#map#eat_char('\\s')<CR>"
command! -narg=+ Inoreabbr
      \ execute "inoreabbr " <q-args>."<C-R>=lh#map#eat_char('\\s')<CR>"

" }}}
"---------------------------------------------------------------------------
" In order to define things like '{'
function! Smart_insert_seq1(key,expr1,expr2) abort " {{{
  call lh#notify#deprecated('Smart_insert_seq1', 'lh#map#smart_insert_seq1')
  return lh#map#smart_insert_seq1(a:key, a:expr1, a:expr2)
endfunction " }}}

function! Smart_insert_seq2(key,expr,...) abort " {{{
  call lh#notify#deprecated('Smart_insert_seq2', 'lh#map#smart_insert_seq2')
  return call('lh#map#smart_insert_seq2', [a:key, a:expr] + a:000)
endfunction " }}}
"---------------------------------------------------------------------------
" Mark where the cursor should be at the end of the insertion {{{
function! LHCursorHere(...) abort
  call lh#notify#deprecated('LHCursorHere', 'lh#map#_cursor_here')
  return call('lh#map#_cursor_here', a:000)
endfunction

function! LHGotoMark() abort
  call lh#notify#deprecated('LHGotoMark', 'lh#map#_goto_mark')
  call lh#map#_goto_mark()
endfunction

function! LHGotoEndMark() abort
  call lh#notify#deprecated('LHGotoEndMark', 'lh#map#_goto_end_mark')
  call lh#map#_goto_end_mark()
endfunction

function! LHFixIndent() abort
  call lh#notify#deprecated('LHFixIndent', 'lh#map#_fix_indent')
  return lh#map#_fix_indent()
endfunction
" }}}
"---------------------------------------------------------------------------
" Function: InsertSeq(key, seq, [context]) {{{
function! InsertSeq(key,seq, ...)
  call lh#notify#deprecated('InsertSeq', 'lh#map#insert_seq')
  return call('lh#map#insert_seq', [a:key, a:seq] + a:000)
endfunction
" }}}
"---------------------------------------------------------------------------
" Function: IsAMarker() {{{
" Returns whether the text currently selected matches a marker and only one.
" Deprecated: Use lh#marker#is_a_marker()
function! IsAMarker()
  call lh#notify#deprecated('IsAMarker', 'lh#marker#is_a_marker')
  return lh#marker#is_a_marker()
endfunction
"}}}

" Surround any visual selection but not a marker!
" Function: Surround(begin,end, isIndented, goback, mustInterpret [, imSeq] ) {{{
function! SurroundBySubstitute(
      \ begin, end, isLine, isIndented, goback, mustInterpret, ...) range abort
  call lh#notify#deprecated('SurroundBySubstitute', 'lh#map#surround_by_substitute')
  return call('lh#map#surround_by_substitute',
        \ [a:begin, a:end, a:isLine, a:isIndented, a:goback, a:mustInterpret] + a:000)
endfunction

function! Surround(
      \ begin, end, isLine, isIndented, goback, mustInterpret, ...) range abort
  call lh#notify#deprecated('Surround', 'lh#map#surround')
  return call('lh#map#surround',
        \ [a:begin, a:end, a:isLine, a:isIndented, a:goback, a:mustInterpret] + a:000)
endfunction
" }}}
"---------------------------------------------------------------------------

" Avoid reinclusion
  let &cpoptions = cpop
endif

"===========================================================================
" vim600: set fdm=marker:
