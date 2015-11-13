"===========================================================================
" File:         plugin/misc_map.vim
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"               <URL:http://github.com/LucHermitte>
" License:      GPLv3 with exceptions
"               <URL:http://github.com/LucHermitte/lh-brackets/License.md>
" Version:	2.3.0
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
" Deprecated:   Use lh#dev#reinterpret_escaped_char
" }}}
"---------------------------------------------------------------------------
" Function:     InsertSeq(key, sequence, [context]) {{{
" Purpose:      This function is meant to return the {sequence} to insert when
"               the {key} is typed. The result will be function of several
"               things:
"               - the {sequence} will be interpreted:
"                 - special characters can be used: '\<cr\>', '\<esc\>', ...
"                   (see lh#dev#reinterpret_escaped_char()) ; '\n'
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
  return call('lh#map#4_these_contexts', [a:key] + a:000)
endfunction
" }}}
"---------------------------------------------------------------------------
function! MapContext(key, ...) abort " {{{
  return call('lh#map#context', [a:key] + a:000)
endfunction
" }}}
"---------------------------------------------------------------------------
function! MapNoContext(key, seq) abort " {{{
  return call('lh#map#no_context', [a:key, a:seq])
endfunction
" }}}
"---------------------------------------------------------------------------
function! MapNoContext2(key, seq) abort " {{{
  return call('lh#map#no_context2', [a:key, a:seq])
endfunction
" }}}
"---------------------------------------------------------------------------
function! BuildMapSeq(seq) abort " {{{
  return lh#map#build_map_seq(a:seq)
endfunction
" }}}
"---------------------------------------------------------------------------
function! ReinterpretEscapedChar(seq) abort " {{{
  return lh#dev#reinterpret_escaped_char(a:seq)
endfunction
" }}}
"---------------------------------------------------------------------------
function! MapAroundVisualLines(begin,end,isLine,isIndented) range abort " {{{
  :'<,'>call InsertAroundVisual(a:begin, a:end, a:isLine, a:isIndented)
endfunction " }}}

function! InsertAroundVisual(begin,end,isLine,isIndented) range abort " {{{
  if &ft == 'python' && a:isIndented && a:isLine
    " let g:action= "normal! gv>`>o".a:end."\<esc>`<O\<c-d>".a:begin
    exe "normal! gv>`>o\<c-d>".a:end."\<esc>`<O\<c-d>".a:begin
    return
  endif

  " Note: to detect a marker before surrounding it, use Surround()
  let cleanup = lh#on#exit()
        \.restore('&paste')
  try
    set paste
    " 'H' stands for 'High' ; 'B' stands for 'Bottom'
    " 'L' stands for 'Left', 'R' for 'Right'
    let HL = "`<i"
    if &selection == 'exclusive'
      let BL = "\<esc>`>i"
    else
      let BL = "\<esc>`>a"
    endif
    let HR = "\<esc>"
    let BR = "\<esc>"
    " If visual-line mode macros -> jump between stuffs
    if a:isLine == 1
      let HR="\<cr>".HR
      let BL .="\<cr>"
    elseif a:isLine == 2
      let HL = "`<O"
      let BL = "\<esc>`>o"
    endif
    " If indentation is used
    if a:isIndented == 1
      if version < 600 " -----------Version 6.xx {{{
        if &cindent == 1  " C like sources -> <c-f> defined
          let HR="\<c-f>".HR
          let BR="\<c-t>".BR
        else              " Otherwise like LaTeX, VIM
          let HR .=":>\<cr>"
          let BR .=":<\<cr>"
        endif
        let BL='>'.BL  " }}}
      else " -----------------------Version 6.xx
        let HR .="gv``="
      endif
    elseif type(a:isIndented) == type('')
      let BL = a:isIndented . BL " move the previous lines
      let HR .="gv``=" " indent the new line inserted
    endif
    " The substitute is here to compensate a little problem with HTML tags
    " let g:action= "normal! gv". BL.substitute(a:end,'>',"\<c-v>>",'').BR.HL.a:begin.HR
    silent exe "normal! gv". BL.substitute(a:end,'>',"\<c-v>>",'').BR.HL.a:begin.HR
    " 'gv' is used to refocus on the current visual zone
    "  call confirm(strtrans( "normal! gv". BL.a:end.BR.HL.a:begin.HR), "&Ok")
  finally
    call cleanup.finalize()
  endtry
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
  return lh#map#eat_char(a:pat)
endfunction

command! -narg=+ Iabbr execute "iabbr " <q-args>."<C-R>=lh#map#eat_char('\\s')<CR>"
command! -narg=+ Inoreabbr
      \ execute "inoreabbr " <q-args>."<C-R>=lh#map#eat_char('\\s')<CR>"

" }}}
"---------------------------------------------------------------------------
" In order to define things like '{'
function! Smart_insert_seq1(key,expr1,expr2) abort " {{{
  return lh#map#smart_insert_seq1(a:key, a:expr1, a:expr2)
endfunction " }}}

function! Smart_insert_seq2(key,expr,...) abort " {{{
  return call('lh#map#smart_insert_seq2', [a:key, a:expr] + a:000)
endfunction " }}}
"---------------------------------------------------------------------------
" Mark where the cursor should be at the end of the insertion {{{
function! LHCursorHere(...) abort
  return call('lh#map#_cursor_here', a:000)
endfunction

function! LHGotoMark() abort
  call lh#map#_goto_mark()
endfunction

function! LHGotoEndMark() abort
  call lh#map#_goto_end_mark()
endfunction

function! LHFixIndent() abort
  return lh#map#_fix_indent()
endfunction
" }}}
"---------------------------------------------------------------------------
" Function: InsertSeq(key, seq, [context]) {{{
function! InsertSeq(key,seq, ...)
  return call('lh#map#insert_seq', [a:key, a:seq] + a:000)
endfunction
" }}}
"---------------------------------------------------------------------------
" Function: IsAMarker() {{{
" Returns whether the text currently selected matches a marker and only one.
" Deprecated: Use lh#marker#is_a_marker()
function! IsAMarker()
  return lh#marker#is_a_marker()
endfunction
"}}}

" Surround any visual selection but not a marker!
" Function: Surround(begin,end, isIndented, goback, mustInterpret [, imSeq] ) {{{
function! SurroundBySubstitute(
      \ begin, end, isLine, isIndented, goback, mustInterpret, ...) range
  " @Overload that does not rely on '>a + '<i, but on s
  if IsAMarker()
      return 'gv"_c'.((a:0>0) ? (a:1) : (a:begin))
  endif

  let save_a = @a
  try
    let begin = a:begin
    let end = a:end
    if a:isLine
      let begin .= "\n"
      let end    = "\n" . end
    endif
    " Hack to know what is selected without altering any register
    normal! gv"ay
    let seq = begin . @a . end
    let goback = ''

    if a:mustInterpret
      inoremap !cursorhere! <c-\><c-n>:call lh#map#_cursor_here()<cr>a
      " inoremap !movecursor! <c-\><c-n>:call lh#map#_goto_mark()<cr>a
      inoremap !movecursor! <c-\><c-n>:call lh#map#_goto_mark()<cr>a<c-r>=lh#map#_fix_indent()<cr>

      if ! lh#brackets#usemarks()
        let seq = substitute(seq, '!mark!', '', 'g')
      endif
      if (begin =~ '!cursorhere!')
        let goback = lh#map#build_map_seq('!movecursor!')
      endif
      let seq = lh#map#build_map_seq(seq)
    endif
    let res = 'gv"_c'.seq
    exe "normal! ".res
    return goback
  finally
    let @a = save_a
    " purge the internal mappings
    silent! iunmap !cursorhere!
    silent! iunmap !movecursor!
  endtry
endfunction

function! Surround(
      \ begin, end, isLine, isIndented, goback, mustInterpret, ...) range abort
  if IsAMarker()
      return 'gv"_c'.((a:0>0) ? (a:1) : (a:begin))
  endif

  " Prepare {a:begin} and {a:end} to be inserted around the visual selection
  let begin = a:begin
  let end = a:end
  let goback = a:goback
  if a:mustInterpret
    " internal mappings
    " <c-o> should be better for !cursorhere! as it does not move the cursor
    " But only <c-\><c-n> works correctly.
    inoremap !cursorhere! <c-\><c-n>:call lh#map#_cursor_here()<cr>a
    " Weird: cursorpos1 & 2 require <c-o> an not <c-\><c-n>
    inoremap !cursorpos1! <c-o>:call lh#map#_cursor_here(1)<cr>
    inoremap !cursorpos2! <c-o>:call lh#map#_cursor_here(2)<cr>
    " <c-\><c-n>....a is better for !movecursor! as it leaves the cursor `in'
    " insert-mode... <c-o> does not; that's odd.
    " inoremap !movecursor! a<c-r>=lh#map#_goto_mark().lh#map#_fix_indent()<cr>
    inoremap !movecursor! <c-\><c-n>:call lh#map#_goto_mark(1)<cr>a<c-r>=lh#map#_fix_indent()<cr>
    inoremap !movecursor2! <c-\><c-n>:call lh#map#_goto_end_mark()<cr>a<c-r>=lh#map#_fix_indent()<cr>

    " Check whether markers must be used
    if !lh#brackets#usemarks()
      let begin = substitute(begin, '!mark!', '', 'g')
      let end   = substitute(end,   '!mark!', '', 'g')
    endif
    " Override the value of {goback} if "!cursorhere!" is used.
    if (begin =~ '!cursorhere!')
      let goback = lh#map#build_map_seq('!movecursor!')
      " let goback = "a\<c-r>=".'lh#map#_goto_mark().lh#map#_fix_indent()'."\<cr>"
    endif
    if (end =~ '!cursorhere!')
      let begin = '!cursorpos1!'.begin.'!cursorpos2!'
      let goback = lh#map#build_map_seq('!movecursor2!')
      if !a:isLine && (line("'>") == line("'<")) && ('V'==visualmode())
            \ && (getline("'>")[0] =~ '\s')
        :normal! 0"_dw
        " TODO: fix when &selection == exclusive
      endif
    endif
    " Transform {begin} and {end} (interpret the "inlined" mappings)
    let begin = lh#map#build_map_seq(begin)
    let end   = lh#map#build_map_seq(end)

    " purge the internal mappings
    iunmap !cursorhere!
    iunmap !cursorpos1!
    iunmap !cursorpos2!
    iunmap !movecursor!
  endif
  " Call the function that really insert the text around the selection
  :'<,'>call InsertAroundVisual(begin, end, a:isLine, a:isIndented)
  " Return the nomal-mode sequence to execute at the end.
  " let g:goback =goback
  return goback
endfunction
" }}}
"---------------------------------------------------------------------------

" Avoid reinclusion
  let &cpoptions = cpop
endif

"===========================================================================
" vim600: set fdm=marker:
