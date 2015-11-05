"=============================================================================
" File:         autoload/lh/map.vim                               {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} gmail {dot} com>
"		<URL:http://github.com/LucHermitte>
" License:      GPLv3 with exceptions
"               <URL:http://github.com/LucHermitte/lh-brackets/License.md>
" Version:      2.3.0
let s:k_version = '230'
" Created:      03rd Nov 2015
" Last Update:
"------------------------------------------------------------------------
" Description:
"       API plugin: Several mapping-oriented functions
"
"------------------------------------------------------------------------
" History:
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
function! lh#map#build_map_seq(seq) abort
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
  let rhs = escape(a:expr, '\')
  " Strip marks (/placeholders) if they are not wanted
  if ! lh#brackets#usemarks()
    let rhs = substitute(rhs, '!mark!\|<+\k*+>', '', 'g')
  endif
  " Interpret the sequence if it is meant to
  if rhs =~ '\m!\(mark\%(here\)\=\|movecursor\)!'
    " may be, the regex should be '\m!\S\{-}!'
    let rhs = lh#map#build_map_seq(escape(rhs, '\'))
  elseif rhs =~ '<+.\{-}+>'
    " @todo: add a move to cursor + jump/select
    let rhs = substitute(rhs, '<+\(.\{-}\)+>', "!cursorhere!&", '')
    let rhs = substitute(rhs, '<+\(.\{-}\)+>', "\<c-r>=lh#marker#txt(".string('\1').")\<cr>", 'g')
    let rhs .= "!movecursor!"
    let rhs = lh#map#build_map_seq(escape(rhs, '\'))."\<c-\>\<c-n>@=Marker_Jump(1)\<cr>"
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
    let g:repos = "Repos (".a:1.") at: ". s:goto_lin_{a:1} . 'normal! ' . s:goto_col_{a:1} . '|'
  else
    let s:goto_lin = line('.')
    let s:goto_col = virtcol('.')
    let g:repos = "Repos at: ". s:goto_lin . 'normal! ' . s:goto_col . '|'
  endif
  let s:old_indent = indent(line('.'))
  let g:repos .= "   indent=".s:old_indent
  return ''
endfunction

" Function: lh#map#_goto_mark() {{{3
function! lh#map#_goto_mark() abort
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
  if s:goto_lin == line('.')
    " Same line -> eligible for moving the cursor
    " TODO: handle reindentation changes
    let delta = s:goto_col - virtcol('.')
    return lh#map#_move_cursor_on_the_current_line(delta)
  else
    " " uses {lig}'normal! {col}|' because of the possible reindent
    " execute s:goto_lin . 'normal! ' . (s:goto_col) . '|'
    call cursor(s:goto_lin, s:goto_col)
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
  return repeat(s:k_move_prefix.move, abs(a:offset))
endfunction

"------------------------------------------------------------------------

" }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
