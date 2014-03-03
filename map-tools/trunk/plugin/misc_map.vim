"===========================================================================
" $Id$
" File:		plugin/misc_map.vim
" Author:	Luc Hermitte <MAIL:hermitte {at} free {dot} fr>
"               <URL:http://code.google.com/p/lh-vim/>
" Last Update:	$Date$
" License:      GPLv3 with exceptions
"               <URL:http://code.google.com/p/lh-vim/wiki/License>
" Version:	2.1.1
"
" Purpose:	API plugin: Several mapping-oriented functions
"
" Todo:		Use the version of EatChar() from Benji Fisher's foo.vim
"---------------------------------------------------------------------------
" Function:	MapNoContext( key, sequence)				{{{
" Purpose:	Regarding the context of the current position of the
" 		cursor, it returns either the value of key or the
" 		interpreted value of sequence.
" Parameters:	<key> - returned while whithin comments, strings or characters 
" 		<sequence> - returned otherwise. In order to enable the
" 			interpretation of escaped caracters, <sequence>
" 			must be a double-quoted string. A backslash must be
" 			inserted before every '<' and '>' sign. Actually,
" 			the '<' after the second one (included) must be
" 			backslashed twice.
" Example:	A mapping of 'if' for C programmation :
"   inoremap if<space> <C-R>=MapNoContext("if ",
"   \				'\<c-f\>if () {\<cr\>}\<esc\>?)\<cr\>i')<CR>
" }}}
"---------------------------------------------------------------------------
" Function:	MapNoContext2( key, sequence)				{{{
" Purpose:	Exactly the same purpose than MapNoContext(). There is a
"		slight difference, the previous function is really boring
"		when we want to use variables like 'tarif' in the code.
"		So this function also returns <key> when the character
"		before the current cursor position is not a keyword
"		character ('h: iskeyword' for more info). 
" Hint:		Use MapNoContext2() for mapping keywords like 'if', etc.
"		and MapNoContext() for other mappings like parenthesis,
"		punctuations signs, and so on.
" }}}
"---------------------------------------------------------------------------
" Function:	MapContext( key, syn1, seq1, ...[, default-seq])	{{{
" Purpose:	Exactly the same purpose than MapNoContext(), but more precise.
"               Returns:
"               - {key} within string, character or comment context,
"               - interpreted {seq_i} within {syn_i} context,
"               - interpreted {default-seq} otherwise ; default value: {key}
" }}}
"---------------------------------------------------------------------------
" Function:	Map4TheseContexts( key, syn1, seq1, ...[, default-seq])	{{{
" Purpose:	Exactly the same purpose than MapContext(), but even more
"               precise. It does not make any assumption for strings-,
"               comments-, characters- and doxygen-context.
"               Returns:
"               - interpreted {seq_i} within {syn_i} context,
"               - interpreted {default-seq} otherwise ; default value: {key}
" }}}
"---------------------------------------------------------------------------
" Function:	BuildMapSeq( sequence )					{{{
" Purpose:	This fonction is to be used to generate the sequences used
" 		by the «MapNoContext» functions. It considers that every
" 		«!.\{-}!» pattern is associated to an INSERT-mode mapping and
" 		expands it.
" 		It is used to define marked mappings ; cf <c_set.vim>
" }}}
"---------------------------------------------------------------------------
" Function:	InsertAroundVisual(begin,end,isLine,isIndented) range {{{
" Old Name:	MapAroundVisualLines(begin,end,isLine,isIndented) range 
" Purpose:	Ease the definition of visual mappings that add text
" 		around the selected one.
" Examples:
"   (*) LaTeX-like stuff
"       if &ft=="tex"
"         vnoremap ;; :call InsertAroundVisual(
"		      \ '\begin{center}','\end{center}',1,1)<cr>
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
" Function:	ReinterpretEscapedChar(sequence)  {{{
" Purpose:	This function transforms '\<cr\>', '\<esc\>', ... '\<{keys}\>'
" 		into the interpreted sequences "\<cr>", "\<esc>", ...
" 		"\<{keys}>".
" 		It is meant to be used by fonctions like MapNoContext(),
" 		InsertSeq(), ... as we can not define mappings (/abbreviations)
" 		that contain "\<{keys}>" into the sequence to insert.
" Note:		It accepts sequences containing double-quotes.
" Deprecated:   Use lh#dev#reinterpret_escaped_char
" }}}
"---------------------------------------------------------------------------
" Function: 	InsertSeq(key, sequence, [context]) {{{
" Purpose:	This function is meant to return the {sequence} to insert when
" 		the {key} is typed. The result will be function of several
" 		things:
" 		- the {sequence} will be interpreted:
" 		  - special characters can be used: '\<cr\>', '\<esc\>', ...
" 		    (see ReinterpretEscapedChar()) ; '\n'
" 		  - we can embed insert-mode mappings whose keybindings match
" 		    '!.\{-}!' (see BuildMapSeq())
" 		    A special treatment is applied on:
" 		    - !mark! : according to b:usemarks, it is replaced by
" 		      Marker_Txt() or nothing
" 		    - !cursorhere! : will move the cursor to that position in
" 		      the sequence once it have been expanded.
" 		- the context ; by default, it returns the interpreted sequence
" 		  when we are not within string, character or comment context.
" 		  (see MapNoContext())
" 		  Thanks to the optional parameter {context}, we can ask to
" 		  expand and interpret the {sequence} only within some
" 		  particular {context}.
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
" Function:	Surround(begin,end,isLine,isIndented,goback,mustInterpret [, im_seq]) range {{{
" Purpose:	This function is a smart wrapper around InsertAroundVisual().
" 		It permit to interpret {begin} and {end} and it also recognizes
" 		whether what we must surround is a marker or not.
"
" 		The point is that there is no :smap command in VimL, and that
" 		insert-mode mappings (imm) should have the precedence over
" 		visual-mode mappings (vmm) when we deals with selected markers
" 		(select-mode) ; unfortunatelly, it is the contrary: vim gives
" 		the priority to vmm over imm.
"
" Parameters:
" {begin}, {end}	strings
" 	The visual selection is surrounded by {begin} and {end}, unless what is
" 	selected is one (and only one) marker. In that latter case, the
" 	function returns a sequence that will replace the selection by {begin}
" 	; if {begin} matches the keybinding of an insert-mode mapping, it will
" 	be expanded.
" {goback}		string
" 	This is the normal-mode sequence to execute after the selected text has
" 	been surrounded; it is meant to place the cursor at the end of {end}
"       Typical values are '%' for true-brackets (), {}, []
"       or '`>ll' when strlen(a:end) == 1.
" 	Note: This sequence will be expanded if it contains mappings or
" 	abbreviations -- this is a feature. see {rtp}/ftplugin/vim_set.vim
" {mustInterpret}	boolean
" 	Indicates whether we must try to find and expand mappings of the form
" 	"!.\{-1,}!" within {begin} and {end}
" 	When true:
" 	- b:usemarks is taken into account: when false, {begin} and {end} will
" 	  be cleared from every occurence of "!mark!".
" 	- if {begin} or {end} contain "!cursorhere!", {goback} will be ignored
" 	  and replaced by a more appropriate value.
" [{a:1}=={im_seq}]	string
" 	Insert-mode sequence that must be returned instead of {begin} if we try
" 	to surround a marker.
" 	Note: This sequence will be expanded if it contains mappings or
" 	abbreviations -- this is a feature. see {rtp}/ftplugin/vim_set.vim
"
" Usage:
" 	:vnoremap <buffer> {key} <c-\><c-n>@=Surround({parameters})<cr>
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
  let g:misc_map_loaded = 200
  let cpop = &cpoptions
  set cpoptions-=C
  scriptencoding latin1
"
if !exists(':Silent') " {{{
  if version < 600
    command! -nargs=+ -bang Silent exe "<args>"
  else
    command! -nargs=+                -bang Silent silent<bang> <args>
  endif
endif
" }}}
"---------------------------------------------------------------------------
function! Map4TheseContexts(key, ...) " {{{
  " Note: requires Vim 6.x
  let syn = synIDattr(synID(line('.'),col('.')-1,1),'name') 
  let i = 1
  while i < a:0
    if (a:{i} =~ '^\(\k\|\\|\)\+$') && (syn =~? a:{i})
      return ReinterpretEscapedChar(a:{i+1})
      " exe 'return "' . 
	    " \   substitute( a:{i+1}, '\\<\(.\{-}\)\\>', '"."\\<\1>"."', 'g' ) .  '"'
    endif
    let i += 2
  endwhile
  " Else: default case
  if i == a:0
    return ReinterpretEscapedChar(a:{a:0})
    " exe 'return "' . 
	  " \   substitute( a:{a:0}, '\\<\(.\{-}\)\\>', '"."\\<\1>"."', 'g' ) .  '"'
  else
    return a:key
  endif
endfunction
" }}}
"---------------------------------------------------------------------------
function! MapContext(key, ...) " {{{
  " Note: requires Vim 6.x
  let syn = synIDattr(synID(line('.'),col('.')-1,1),'name') 
  if syn =~? 'comment\|string\|character\|doxygen'
    return a:key
  else
    let i = 1
    while i < a:0
      if (a:{i} =~ '^\k\+$') && (syn =~? a:{i})
	return ReinterpretEscapedChar(a:{i+1})
	" exe 'return "' . 
	      " \   substitute( a:{i+1}, '\\<\(.\{-}\)\\>', '"."\\<\1>"."', 'g' ) .  '"'
      endif
      let i += 2
    endwhile
    " Else: default case
    if i == a:0
      return ReinterpretEscapedChar(a:{a:0})
      " exe 'return "' . 
	    " \   substitute( a:{a:0}, '\\<\(.\{-}\)\\>', '"."\\<\1>"."', 'g' ) .  '"'
    else
      return a:key
    endif
  endif 
endfunction
" }}}
"---------------------------------------------------------------------------
function! MapNoContext(key, seq) " {{{
  let syn = synIDattr(synID(line('.'),col('.')-1,1),'name') 
  if syn =~? 'comment\|string\|character\|doxygen'
    return a:key
  else
    return ReinterpretEscapedChar(a:seq)
    " exe 'return "' . 
      " \   substitute( a:seq, '\\<\(.\{-}\)\\>', '"."\\<\1>"."', 'g' ) .  '"'
  endif 
endfunction
" }}}
"---------------------------------------------------------------------------
function! MapNoContext2(key, seq) " {{{
  let c = col('.')-1
  let l = line('.')
  let syn = synIDattr(synID(l,c,1), 'name') 
  if syn =~? 'comment\|string\|character\|doxygen'
    return a:key
  elseif getline(l)[c-1] =~ '\k'
    return a:key
  else
    return ReinterpretEscapedChar(a:seq)
    " exe 'return "' . 
      " \   substitute( a:seq, '\\<\(.\{-}\)\\>', '"."\\<\1>"."', 'g' ) .  '"'
  endif 
endfunction
" }}}
"---------------------------------------------------------------------------
function! BuildMapSeq(seq) " {{{
  let r = ''
  let s = a:seq
  while strlen(s) != 0 " For every '!.*!' pattern, extract it
    let r .= substitute(s,'^\(.\{-}\)\(\(!\k\{-1,}!\)\(.*\)\)\=$', '\1', '')
    let c =  substitute(s,'^\(.\{-}\)\(\(!\k\{-1,}!\)\(.*\)\)\=$', '\3', '')
    let s =  substitute(s,'^\(.\{-}\)\(\(!\k\{-1,}!\)\(.*\)\)\=$', '\4', '')
    let m = maparg(c,'i')
    if strlen(m) != 0
      silent exe 'let m="' . substitute(m, '<\(.\{-1,}\)>', '"."\\<\1>"."', 'g') . '"'
      if has('iconv') " small workaround for !imappings! in UTF-8 on linux
	let m = iconv(m, "latin1", &encoding)
      endif
      " let m = ReinterpretEscapedChar(m)
      let r .= m
    else
      let r .= c
    endif
  endwhile
  return ReinterpretEscapedChar(r)
  " silent exe 'return "' . 
    " \   substitute( r, '\\<\(.\{-}\)\\>', '"."\\<\1>"."', 'g' ) .  '"'
endfunction
" }}}
"---------------------------------------------------------------------------
function! ReinterpretEscapedChar(seq) " {{{
  let seq = escape(a:seq, '"')
  exe 'return "' . 
    \   substitute( seq, '\\<\(.\{-}\)\\>', '"."\\<\1>"."', 'g' ) .  '"'
endfunction
" }}}
"---------------------------------------------------------------------------
function! MapAroundVisualLines(begin,end,isLine,isIndented) range " {{{
  :'<,'>call InsertAroundVisual(a:begin, a:end, a:isLine, a:isIndented)
endfunction " }}}

function! InsertAroundVisual(begin,end,isLine,isIndented) range " {{{
  " Note: to detect a marker before surrounding it, use Surround()
  let pp = &paste
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
  endif
  " If indentation is used
  if a:isIndented == 1
    if version < 600 " -----------Version 6.xx {{{
      if &cindent == 1	" C like sources -> <c-f> defined
	let HR="\<c-f>".HR
	let BR="\<c-t>".BR
      else		" Otherwise like LaTeX, VIM
	let HR .=":>\<cr>"
	let BR .=":<\<cr>"
      endif
      let BL='>'.BL  " }}}
    else " -----------------------Version 6.xx
      let HR .="gv``="
    endif
  endif
  " The substitute is here to compensate a little problem with HTML tags
  Silent exe "normal! gv". BL.substitute(a:end,'>',"\<c-v>>",'').BR.HL.a:begin.HR
  " 'gv' is used to refocus on the current visual zone
  "  call confirm(strtrans( "normal! gv". BL.a:end.BR.HL.a:begin.HR), "&Ok")
  let &paste=pp
endfunction
" }}}
"---------------------------------------------------------------------------
" Function: EatChar()	{{{
" Thanks to the VIM Mailing list ; 
" Note: In it's foo.vim, Benji Fisher maintains a more robust version of this
" function; see: http://www.vim.org/script.php?script_id=72
" NB: To make it work with VIM 5.x, replace the '? :' operator with an 'if
" then' test.
" This version does not support multi-bytes characters.
" Todo: add support for <buffer>
function! EatChar(pat)
  let c = nr2char(getchar())
  return (c =~ a:pat) ? '' : c
endfunction

command! -narg=+ Iabbr execute "iabbr " <q-args>."<C-R>=EatChar('\\s')<CR>"
command! -narg=+ Inoreabbr 
      \ execute "inoreabbr " <q-args>."<C-R>=EatChar('\\s')<CR>"

" }}}
"---------------------------------------------------------------------------
" In order to define things like '{'
function! Smart_insert_seq1(key,expr1,expr2) " {{{
  return s:Smart_insert_seq1(a:key, a:expr1, a:expr2)
endfunction " }}}
function! s:Smart_insert_seq1(key,expr1,expr2) " {{{
  if exists('b:usemarks') && b:usemarks
    return MapNoContext(a:key,BuildMapSeq(a:expr2))
    " return "\<c-r>=MapNoContext('".a:key."',BuildMapSeq('".a:expr2."'))\<cr>"
  else
    return MapNoContext(a:key,a:expr1)
    " return "\<c-r>=MapNoContext('".a:key."', '".a:expr1."')\<cr>"
  endif
endfunction " }}}

function! Smart_insert_seq2(key,expr,...) " {{{
  if a:0 > 0
    return s:Smart_insert_seq(a:key, a:expr, a:1)
  else
    return s:Smart_insert_seq(a:key, a:expr)
  endif
endfunction " }}}
function! s:Smart_insert_seq(key,expr, ...) " {{{
  let rhs = escape(a:expr, '\')
  " Strip marks (/placeholders) if they are not wanted
  if !exists('b:usemarks') || !b:usemarks
    let rhs = substitute(rhs, '!mark!\|<+\k*+>', '', 'g')
  endif
  " Interpret the sequence if it is meant to
  if rhs =~ '\m!\(mark\%(here\)\=\|movecursor\)!'
    " may be, the regex should be '\m!\S\{-}!'
    let rhs = BuildMapSeq(escape(rhs, '\'))
  elseif rhs =~ '<+.\{-}+>'
    " @todo: add a move to cursor + jump/select
    let rhs = substitute(rhs, '<+\(.\{-}\)+>', "!cursorhere!&", '')
    let rhs = substitute(rhs, '<+\(.\{-}\)+>', "\<c-r>=Marker_Txt(".string('\1').")\<cr>", 'g')
    let rhs .= "!movecursor!"
    let rhs = BuildMapSeq(escape(rhs, '\'))."\<c-\>\<c-n>@=Marker_Jump(1)\<cr>"
  endif
  " Build & return the context dependent sequence to insert
  if a:0 > 0
    return Map4TheseContexts(a:key, a:1, rhs)
  else
    return MapNoContext(a:key,rhs)
  endif
endfunction " }}}
"---------------------------------------------------------------------------
" Mark where the cursor should be at the end of the insertion {{{
function! LHCursorHere(...)
  " NB: ``|'' requires virtcol() but cursor() requires col()
  " let s:gotomark = line('.') . 'normal! '.virtcol('.')."|"
  " let s:gotomark = 'call cursor ('.line('.').','.col('.').')'
  if a:0 > 0
    let s:goto_lin_{a:1} = line('.')
    let s:goto_col_{a:1} = virtcol('.')
    let g:repos = "Repos (".a:1.") at: ". s:goto_lin_{a:1} . 'normal! ' . s:goto_col_{a:1} . '|'
  else
    let s:goto_lin = line('.')
    let s:goto_col = virtcol('.')
    let g:repos = "Repos at: ". s:goto_lin . 'normal! ' . s:goto_col . '|'
  endif
  let s:old_indent = indent(line('.'))
  let g:repos .= "   indent=".s:old_indent
  " return ''
endfunction

function! LHGotoMark()
  " Bug: if line is empty, indent() value is 0 => expect old_indent to be the One
  let crt_indent = indent(s:goto_lin)
  if crt_indent < s:old_indent
    let s:fix_indent = s:old_indent - crt_indent
  else
    let s:old_indent = crt_indent - s:old_indent 
    let s:fix_indent = 0
  endif
  let g:fix_indent = s:fix_indent
  if s:old_indent != 0
    let s:goto_col += s:old_indent
  endif
  " uses {lig}'normal! {col}|' because of the possible reindent
  execute s:goto_lin . 'normal! ' . s:goto_col . '|'
  " return ''
endfunction
function! LHGotoEndMark()
  " Bug: if line is empty, indent() value is 0 => expect old_indent to be the One
  let crt_indent = indent(s:goto_lin)
  if crt_indent < s:old_indent
    let s:fix_indent = s:old_indent - crt_indent
  else
    let s:old_indent = crt_indent - s:old_indent 
    let s:fix_indent = 0
  endif
  if s:old_indent != 0
    let s:goto_col += s:old_indent
  endif
  if     s:goto_lin != s:goto_lin_2
    " TODO: !!
  else
    let s:goto_col += s:goto_col_2 - s:goto_col_1
  endif
  " uses {lig}'normal! {col}|' because of the possible reindent
  execute s:goto_lin . 'normal! ' . s:goto_col . '|'
  " return ''
endfunction
function! LHFixIndent()
  return repeat( ' ', s:fix_indent)
endfunction
" }}}
"---------------------------------------------------------------------------
" Function: InsertSeq(key, seq, [context]) {{{
function! InsertSeq(key,seq, ...)
  let s:gotomark = ''
  let mark = a:seq =~ '!cursorhere!'
  let seq = ReinterpretEscapedChar(a:seq)
  let seq .= (mark ? '!movecursor!' : '')
  " internal mappings
  inoremap <silent> !cursorhere! <c-\><c-n>:call LHCursorHere()<cr>a
  inoremap <silent> !movecursor! <c-\><c-n>:call LHGotoMark()<cr>a
  "inoremap !cursorhere! <c-\><c-n>:call <sid>CursorHere()<cr>a
  "inoremap !movecursor! <c-\><c-n>:call <sid>GotoMark()<cr>a
  " Build the sequence to insert
  if a:0 > 0
    let res = s:Smart_insert_seq(a:key, seq, a:1)
  else
    let res = s:Smart_insert_seq(a:key, seq)
  endif
  " purge the internal mappings
  iunmap !cursorhere!
  iunmap !movecursor!
  return res
endfunction
" }}}
"---------------------------------------------------------------------------
" Function: IsAMarker() {{{
" Returns whether the text currently selected matches a marker and only one.
function! IsAMarker()
  if line("'<") == line("'>") " I suppose markers don't spread over several lines
    " Extract the selected text
    let a_save = @a
    normal! gv"ay
    let a = @a
    let @a = a_save

    " Check whether the selected text matches a marker (and only one)
    if (a =~ '^'.Marker_Txt('.\{-}').'$') 
	  \ && (a !~ '\%(.*'.Marker_Close().'\)\{2}')
      " If so, return {a:begin}, or {im_seq} if provided
      " return 'gv"_c'.((a:0>0) ? (a:1) : (a:begin))
      return 1
    endif
  endif
  return 0
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
      let end   = "\n" . end
    endif
    " Hack to know what is selected without altering any register
    normal! gv"ay
    let seq = begin . @a . end
    let goback = ''

    if a:mustInterpret
      inoremap !cursorhere! <c-\><c-n>:call LHCursorHere()<cr>a
      " inoremap !movecursor! <c-\><c-n>:call LHGotoMark()<cr>a
      inoremap !movecursor! <c-\><c-n>:call LHGotoMark()<cr>a<c-r>=LHFixIndent()<cr>

      if (!exists('b:usemarks') || !b:usemarks)
	let seq = substitute(seq, '!mark!', '', 'g')
      endif
      if (begin =~ '!cursorhere!') 
	let goback = BuildMapSeq('!movecursor!')
      endif
      let seq = BuildMapSeq(seq)
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
      \ begin, end, isLine, isIndented, goback, mustInterpret, ...) range
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
    " inoremap !cursorhere! <c-o>:call <sid>CursorHere()<cr>
    if 0
      " inoremap !cursorhere! <c-\><c-n>:call <sid>CursorHere()<cr>a
      " inoremap !cursorpos1! <c-o>:call <sid>CursorHere(1)<cr>
      " inoremap !cursorpos2! <c-o>:call <sid>CursorHere(2)<cr>
      " inoremap !movecursor! <c-\><c-n>:call <sid>GotoMark()<cr>a
      " inoremap !movecursor2! <c-\><c-n>:call <sid>GotoEndMark()<cr>a
    endif
    inoremap !cursorhere! <c-\><c-n>:call LHCursorHere()<cr>a
    " Weird: cursorpos1 & 2 require <c-o> an not <c-\><c-n>
    inoremap !cursorpos1! <c-o>:call LHCursorHere(1)<cr>
    inoremap !cursorpos2! <c-o>:call LHCursorHere(2)<cr>
    " <c-\><c-n>....a is better for !movecursor! as it leaves the cursor `in'
    " insert-mode... <c-o> does not; that's odd.
    inoremap !movecursor! <c-\><c-n>:call LHGotoMark()<cr>a<c-r>=LHFixIndent()<cr>
    inoremap !movecursor2! <c-\><c-n>:call LHGotoEndMark()<cr>a<c-r>=LHFixIndent()<cr>
    " inoremap !movecursor! <sid>GotoMark().'a'

    " Check whether markers must be used
    if (!exists('b:usemarks') || !b:usemarks)
      let begin = substitute(begin, '!mark!', '', 'g')
      let end = substitute(end, '!mark!', '', 'g')
    endif
    " Override the value of {goback} if "!cursorhere!" is used.
    if (begin =~ '!cursorhere!') 
      let goback = BuildMapSeq('!movecursor!')
    endif
    if (end =~ '!cursorhere!')
      let begin = '!cursorpos1!'.begin.'!cursorpos2!'
      let goback = BuildMapSeq('!movecursor2!')
      if !a:isLine && (line("'>") == line("'<")) && ('V'==visualmode())
	    \ && (getline("'>")[0] =~ '\s') 
	:normal! 0"_dw
	" TODO: fix when &selection == exclusive
      endif
    endif
    " Transform {begin} and {end} (interpret the "inlined" mappings)
    let begin = BuildMapSeq(begin)
    let end = BuildMapSeq(end)

    " purge the internal mappings
    iunmap !cursorhere!
    iunmap !cursorpos1!
    iunmap !cursorpos2!
    iunmap !movecursor!
  endif
  " Call the function that really insert the text around the selection
  call InsertAroundVisual(begin, end, a:isLine, a:isIndented)
  " Return the nomal-mode sequence to execute at the end.
  return goback
endfunction
" }}}
"---------------------------------------------------------------------------

" Avoid reinclusion
  let &cpoptions = cpop
endif

"===========================================================================
" vim600: set fdm=marker:
