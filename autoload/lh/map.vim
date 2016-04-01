"=============================================================================
" File:         autoload/lh/map.vim                               {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} gmail {dot} com>
"		<URL:http://github.com/LucHermitte>
" License:      GPLv3 with exceptions
"               <URL:http://github.com/LucHermitte/lh-brackets/tree/master/License.md>
" Version:      3.0.4
let s:k_version = '303'
" Created:      03rd Nov 2015
" Last Update:  01st Apr 2016
"------------------------------------------------------------------------
" Description:
"       API plugin: Several mapping-oriented functions
"
"------------------------------------------------------------------------
" History:
"       v3.0.4 Support definitions like ":Bracket \Q{ } -trigger=µ"
"              Some olther mappings may not work anymore. Alas I have no tests
"              for them ^^'
"       v3.0.1 Support older versions of vim, thanks to Troy Curtis Jr
"       v3.0.0 !mark! & co have been deprecated as mappings
"       v2.3.0 functions moved from plugin/misc_map.vim
" TODO:
" * Simplify the way mappings are defined, hopefully to get rid of
" lh#dev#reinterpret_escaped_char()
" }}}1
"=============================================================================

let s:cpo_save=&cpo
set cpo&vim

" Does vim supports the new way to support redo/undo?
let s:k_vim_supports_redo = has('patch-7.4.849')
let s:k_move_prefix = s:k_vim_supports_redo ? "\<C-G>U" : ""

"------------------------------------------------------------------------
" ## Misc Functions     {{{1
" # Version {{{2
function! lh#map#version()
  return s:k_version
endfunction

" # Debug   {{{2
if !exists('s:verbose')
  let s:verbose = 0
endif
function! lh#map#verbose(...)
  if a:0 > 0 | let s:verbose = a:1 | endif
  return s:verbose
endfunction

function! s:Verbose(expr)
  if s:verbose
    echomsg a:expr
  endif
endfunction

function! lh#map#debug(expr)
  return eval(a:expr)
endfunction


"------------------------------------------------------------------------
" ## Exported functions {{{1

" # Misc functions {{{2

" Function: lh#map#eat_char(pat) {{{3
" Thanks to the VIM Mailing list ;
" Note: In it's foo.vim, Benji Fisher maintains a more robust version of this
" function; see: http://www.vim.org/script.php?script_id=72
" NB: To make it work with VIM 5.x, replace the '? :' operator with an 'if
" then' test.
" This version does not support multi-bytes characters.
" Todo: add support for <buffer>
function! lh#map#eat_char(pat) abort
  let c = nr2char(getchar())
  return (c =~ a:pat) ? '' : c
endfunction

" # Sequence functions {{{2

" Function: lh#map#4_these_contexts(key, ...) {{{3
" Exactly the same purpose than lh#map#context(), but even more precise. It does
" not make any assumption for strings-, comments-, characters- and
" doxygen-context.
" Returns:
" - interpreted {seq_i} within {syn_i} context,
" - interpreted {default-seq} otherwise ; default value: {key}
function! lh#map#4_these_contexts(key, ...) abort
  let syn = synIDattr(synID(line('.'),col('.')-1,1),'name')
  let i = 1
  while i < a:0
    if (a:{i} =~ '^\(\k\|\\|\)\+$') && (syn =~? a:{i})
      return lh#dev#reinterpret_escaped_char(a:{i+1})
    endif
    let i += 2
  endwhile
  " Else: default case
  if i == a:0
    return lh#dev#reinterpret_escaped_char(a:{a:0})
  else
    return a:key
  endif
endfunction

" Function: lh#map#context(key, ...) {{{3
" Exactly the same purpose than lh#map#no_context(), but more precise.
" Returns:
" - {key} within string, character or comment context,
" - interpreted {seq_i} within {syn_i} context,
" - interpreted {default-seq} otherwise ; default value: {key}
function! lh#map#context(key, ...) abort
  let syn = synIDattr(synID(line('.'),col('.')-1,1),'name')
  if syn =~? 'comment\|string\|character\|doxygen'
    return a:key
  else
    return call('lh#map#4_these_contexts', [a:key]+a:000)
  endif
endfunction

" Function: lh#map#no_context(key, seq) {{{3
" Purpose:
" Regarding the context of the current position of the cursor, it returns
" either the value of key or the interpreted value of sequence.
" Parameters:
" <key>      - returned while whithin comments, strings or characters
" <sequence> - returned otherwise. In order to enable the interpretation of
"              escaped caracters, <sequence> must be a double-quoted string. A
"              backslash must be inserted before every '<' and '>' sign.
"              Actually, the '<' after the second one (included) must be
"              backslashed twice.
" Example:
" A mapping of 'if' for C programmation:
"   Iabbr if <C-R>=lh#map#no_context("if ",
"   \ '\<c-f\>if () {\<cr\>}\<esc\>?)\<cr\>i')<CR>
function! lh#map#no_context(key, seq) abort
  let syn = synIDattr(synID(line('.'),col('.')-1,1),'name')
  if syn =~? 'comment\|string\|character\|doxygen'
    return a:key
  else
    return lh#dev#reinterpret_escaped_char(a:seq)
  endif
endfunction

" Function: lh#map#no_context2(key, sequence) {{{3
" Purpose:
" Exactly the same purpose than lh#map#no_context().
" There is a slight difference, the previous function is really annoying when we
" want to use variables like 'tarif' in the code.
" So this function also returns <key> when the character before the current
" cursor position is not a keyword character ('h: iskeyword' for more info).
" Hint:
" Use lh#map#no_context2() for mapping keywords like 'if', etc.  and lh#map#no_context()
" for other mappings like parenthesis, punctuations signs, and so on.
function! lh#map#no_context2(key, sequence) abort
  let c = col('.')-1
  let l = line('.')
  let syn = synIDattr(synID(l,c,1), 'name')
  if syn =~? 'comment\|string\|character\|doxygen'
    return a:key
  elseif getline(l)[c-1] =~ '\k'
    return a:key
  else
    return lh#dev#reinterpret_escaped_char(a:seq)
  endif
endfunction

" Function: lh#map#build_map_seq(seq) {{{3
" Purpose:
" This function is to be used to generate the sequences used by the
" «lh#map#no_context» functions.
" It considers that every «!.\{-}!» pattern is associated to an INSERT-mode
" mapping and expands it.
" It is used to define marked mappings ; cf <ftplugin/c/c_snippets.vim>
let s:k_mappings_translation = {
      \ '!mark!'         : '<Plug>MarkersInsertMark',
      \ '!jump!'         : '<Plug>MarkersJumpF',
      \ '!jumpB!'        : '<Plug>MarkersJumpB',
      \ '!jump-and-del!' : '<Plug>MarkersJumpAndDelF',
      \ '!bjump-and-del!': '<Plug>MarkersJumpAndDelB'
      \ }

function! lh#map#build_map_seq(seq) abort
  let r = ''
  let s = a:seq
  while strlen(s) != 0 " For every '!.*!' pattern, extract it
    let r .= substitute(s,'\v^(.{-})((!\k{-1,}!)(.*))=$', '\1', '')
    let c =  substitute(s,'\v^(.{-})((!\k{-1,}!)(.*))=$', '\3', '')
    let s =  substitute(s,'\v^(.{-})((!\k{-1,}!)(.*))=$', '\4', '')
    " !mark! & cie need translation now
    let c = get(s:k_mappings_translation, c, c)
    let m = maparg(c,'i')
    if strlen(m) != 0
      silent exe 'let m="' . substitute(m, '<\(.\{-1,}\)>', '"."\\<\1>"."', 'g') . '"'
      if has('iconv') " small workaround for !imappings! in UTF-8 on linux
        let m = iconv(m, "latin1", &encoding)
      endif
      let r .= m
    else
      let r .= c
    endif
  endwhile
  return lh#dev#reinterpret_escaped_char(r)
endfunction

" Function: lh#map#smart_insert_seq1(key, expr1, expr2) {{{3
function! lh#map#smart_insert_seq1(key, expr1, expr2) abort
  if lh#brackets#usemarks()
    return lh#map#no_context(a:key,lh#map#build_map_seq(a:expr2))
  else
    return lh#map#no_context(a:key,a:expr1)
  endif
endfunction

" Function: lh#map#smart_insert_seq2(key, expr, ...) {{{3
function! lh#map#smart_insert_seq2(key, expr, ...) abort
  " let rhs = escape(a:expr, '\')
  let rhs = a:expr

  " Strip marks (/placeholders) if they are not wanted
  if ! lh#brackets#usemarks()
    let rhs = substitute(rhs, '\v!mark!|\<+\k*+\>', '', 'g')
  endif
  " Interpret the sequence if it is meant to
  if rhs =~ '\m!\(mark\%(here\)\=\|movecursor\)!'
    " may be, the regex should be '\m!\S\{-}!'
    " let rhs = lh#map#build_map_seq(escape(rhs, '\'))
    let rhs = lh#map#build_map_seq(rhs)
  elseif rhs =~ '<+.\{-}+>'
    " @todo: add a move to cursor + jump/select
    let rhs = substitute(rhs, '<+\(.\{-}\)+>', "!cursorhere!&", '')
    let rhs = substitute(rhs, '<+\(.\{-}\)+>', "\<c-r>=lh#marker#txt(".string('\1').")\<cr>", 'g')
    let rhs .= "!movecursor!"
    " let rhs = lh#map#build_map_seq(escape(rhs, '\'))."\<c-\>\<c-n>@=Marker_Jump({'direction':1, 'mode':'n'})\<cr>"
    let rhs = lh#map#build_map_seq(rhs."\<c-\>\<c-n>@=Marker_Jump({'direction':1, 'mode':'n'})\<cr>"
  endif
  " Build & return the context dependent sequence to insert
  if a:0 > 0
    return lh#map#4_these_contexts(a:key, a:1, rhs)
  else
    return lh#map#no_context(a:key,rhs)
  endif
endfunction

" Function: lh#map#insert_seq(key, seq, ...) {{{3
function! lh#map#insert_seq(key, seq, ...) abort
  " TODO: if no escape nor newline -> use s:k_move_prefix
  let mark = a:seq =~ '!cursorhere!'
  let s:gotomark = ''
  let seq  = lh#dev#reinterpret_escaped_char(a:seq)
  let seq .= (mark ? '!movecursor!' : '')

  let cleanup = lh#on#exit()
        \.register('iunmap !cursorhere!')
        \.register('iunmap !movecursor!')
  try
    " dummy mappings used to move the cursor auround
    inoremap <silent> !cursorhere! <c-r>=lh#map#_cursor_here()<cr>
    inoremap <silent> !movecursor! <c-r>=lh#map#_goto_mark()<cr>
    " Build the sequence to insert
    let res = call('lh#map#smart_insert_seq2', [a:key, seq] + a:000)
  finally
    " purge the dummy mappings
    call cleanup.finalize()
  endtry
  return res
endfunction

" # Surrounding functions {{{2

" Function: lh#map#surround_by_substitute(begin, end, isLine, isIndented, goback, mustInterpret, ...) {{{3
" @Overload that does not rely on '>a + '<i, but on s
function! lh#map#surround_by_substitute(
      \  begin, end, isLine, isIndented, goback, mustInterpret, ...) range abort
  if lh#marker#is_a_marker()
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

" Function: lh#map#surround(begin, end, isLine, isIndented, goback, mustInterpret, ...) {{{3
function! lh#map#surround(begin, end, isLine, isIndented, goback, mustInterpret, ...) range abort
  if lh#marker#is_a_marker()
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
  :'<,'>call lh#map#insert_around_visual(begin, end, a:isLine, a:isIndented)
  " Return the nomal-mode sequence to execute at the end.
  " let g:goback =goback
  return goback
endfunction

" Function: lh#map#insert_around_visual(begin,end,isLine,isIndented) {{{3
function! lh#map#insert_around_visual(begin,end,isLine,isIndented) range abort
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

"------------------------------------------------------------------------
" ## Internal functions {{{1

" # Cursor moving {{{2
" Mark where the cursor should be at the end of the insertion

" Function: lh#map#_cursor_here(...) {{{3
function! lh#map#_cursor_here(...) abort
  " NB: ``|'' requires virtcol() but cursor() requires col()
  " let s:gotomark = line('.') . 'normal! '.virtcol('.')."|"
  " let s:gotomark = 'call cursor ('.line('.').','.col('.').')'
  if a:0 > 0
    let s:goto_lin_{a:1} = line('.')
    let s:goto_col_{a:1} = virtcol('.')
    " let g:repos = "Repos (".a:1.") at: ". s:goto_lin_{a:1} . 'normal! ' . s:goto_col_{a:1} . '|'
  else
    let s:goto_lin = line('.')
    let s:goto_col = virtcol('.')
    " let g:repos = "Repos at: ". s:goto_lin . 'normal! ' . s:goto_col . '|'
  endif
  let s:old_indent = indent(line('.'))
  " let g:repos .= "   indent=".s:old_indent
  return ''
endfunction

" Function: lh#map#_goto_mark([old_behaviour]) {{{3
function! lh#map#_goto_mark(...) abort
  " Bug: if line is empty, indent() value is 0 => expect old_indent to be the One
  let crt_indent = indent(s:goto_lin)
  if crt_indent < s:old_indent
    let s:fix_indent = s:old_indent - crt_indent
  else
    let s:old_indent = crt_indent - s:old_indent
    let s:fix_indent = 0
  endif
  " let g:fix_indent = s:fix_indent
  if s:old_indent != 0
    let s:goto_col += s:old_indent
  endif
  let new_behaviour = (a:0 > 0) ? (!a:1) : 1
  if new_behaviour && s:goto_lin == line('.')
    " Same line -> eligible for moving the cursor
    " TODO: handle reindentation changes
    let delta = s:goto_col - virtcol('.')
    let move = lh#map#_move_cursor_on_the_current_line(delta)
    return move
  else
    " " uses {lig}'normal! {col}|' because of the possible reindent
    execute s:goto_lin . 'normal! ' . (s:goto_col) . '|'
    " call cursor(s:goto_lin, s:goto_col)
    return ''
  endif
endfunction

" Function: lh#map#_goto_end_mark() {{{3
function! lh#map#_goto_end_mark() abort
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
  call cursor(s:goto_lin, s:goto_col)
  return ''
endfunction

" Function: lh#map#_fix_indent() {{{3
function! lh#map#_fix_indent() abort
  return repeat( ' ', s:fix_indent)
endfunction


" Function: lh#map#_move_cursor_on_the_current_line(offset) {{{3
" This function tries to move the cursor in order to maintain redo-ability of
" the text inserted.
" See vim patch 7.4.849
function! lh#map#_move_cursor_on_the_current_line(offset) abort
  let move = a:offset > 0 ? "\<right>" : "\<left>"
  return repeat(s:k_move_prefix.move, lh#math#abs(a:offset))
endfunction

"------------------------------------------------------------------------

" }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
