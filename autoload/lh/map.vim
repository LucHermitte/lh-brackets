"=============================================================================
" File:         autoload/lh/map.vim                               {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} gmail {dot} com>
"		<URL:http://github.com/LucHermitte>
" License:      GPLv3 with exceptions
"               <URL:http://github.com/LucHermitte/lh-brackets/tree/master/License.md>
" Version:      3.2.1
let s:k_version = '321'
" Created:      03rd Nov 2015
" Last Update:  13th Sep 2017
"------------------------------------------------------------------------
" Description:
"       API plugin: Several mapping-oriented functions
"
"------------------------------------------------------------------------
" History:
"       v3.2.1 Fix regression with `set et`
"       v3.2.0 Add `lh#map#4_this_context()`
"              Fix tw issue, again
"              Deprecates lh#dev#reinterpret_escaped_char()
"       v3.1.2 Fix Issue 9 (when g:usemarks is false)
"       v3.0.8 Fix Indenting issue when surrounding
"       v3.0.6 Fix Indenting regression
"       v3.0.5 Use lh#log() framework
"              Fix Indenting issue when indentation changes between opening and
"              closing brackets
"       v3.0.4 Support definitions like ":Bracket \Q{ } -trigger=µ"
"              Some olther mappings may not work anymore. Alas I have no tests
"              for them ^^'
"       v3.0.1 Support older versions of vim, thanks to Troy Curtis Jr
"       v3.0.0 !mark! & co have been deprecated as mappings
"       v2.3.0 functions moved from plugin/misc_map.vim
" TODO:
" * Simplify the way mappings are defined, hopefully to get rid of
" lh#mapping#reinterpret_escaped_char()
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
let s:verbose = get(s:, 'verbose', 0)
function! lh#map#verbose(...)
  if a:0 > 0 | let s:verbose = a:1 | endif
  return s:verbose
endfunction

function! s:Log(...)
  call call('lh#log#this', a:000)
endfunction

function! s:Verbose(...)
  if s:verbose
    call call('s:Log', a:000)
  endif
endfunction

function! lh#map#debug(expr)
  return eval(a:expr)
endfunction

" # Helpers  {{{2
" s:getSNR([func_name]) {{{3
function! s:getSNR(...)
  if !exists("s:SNR")
    let s:SNR=matchstr(expand('<sfile>'), '<SNR>\d\+_\zegetSNR$')
  endif
  return s:SNR . (a:0>0 ? (a:1) : '')
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

" Function: lh#map#4_this_context(key, rule, sequence[, default]) {{{3
function! s:match(syn) dict
  return a:syn =~? self.context
endfunction
function! s:dont_match(syn) dict
  return a:syn !~? self.context
endfunction
function! s:new_matcher(context) abort
  let matcher = lh#object#make_top_type({})
  if type(a:context) == type('')
    let matcher.recognizes = function(s:getSNR('match'))
    let matcher.context    = a:context
  elseif has_key(a:context, 'is')
    let matcher.recognizes = function(s:getSNR('match'))
    let matcher.context    = a:context.is
  elseif has_key(a:context, "isn't")
    let matcher.recognizes = function(s:getSNR('dont_match'))
    let matcher.context    = a:context["isn't"]
  else
    throw "Unexpected argument ".string(a:context)
  endif
  return matcher
endfunction

function! lh#map#4_this_context(key, rule, sequence, ...) abort
  let syn = synIDattr(synID(line('.'),col('.')-1,1),'name')
  let context = s:new_matcher(a:rule)
  if context.recognizes(syn)
    return lh#mapping#reinterpret_escaped_char(a:sequence)
  elseif a:0 > 0
    return lh#mapping#reinterpret_escaped_char(a:1)
  else
    return a:key
  endif
endfunction

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
      return lh#mapping#reinterpret_escaped_char(a:{i+1})
    endif
    let i += 2
  endwhile
  " Else: default case
  if i == a:0
    return lh#mapping#reinterpret_escaped_char(a:{a:0})
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
    return lh#mapping#reinterpret_escaped_char(a:seq)
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
    return lh#mapping#reinterpret_escaped_char(a:seq)
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
  return lh#mapping#reinterpret_escaped_char(r)
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
    let rhs = substitute(rhs, '\v!mark!|\<+\k+\>', '', 'g')
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
    let rhs = lh#map#build_map_seq(rhs."\<c-\>\<c-n>@=Marker_Jump({'direction':1, 'mode':'n'})\<cr>")
  endif
  " Build & return the context dependent sequence to insert
  if a:0 > 0
    return lh#map#4_this_context(a:key, a:1, rhs)
  else
    return lh#map#no_context(a:key,rhs)
  endif
endfunction

" Function: lh#map#insert_seq(key, seq[, context]) {{{3
function! lh#map#insert_seq(key, seq, ...) abort
  " TODO: if no escape nor newline -> use s:k_move_prefix
  let mark = a:seq =~ '!cursorhere!'
  let s:gotomark = ''
  let seq  = lh#mapping#reinterpret_escaped_char(a:seq)
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
  call s:Verbose(strtrans(res))
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
  let g:goback =goback
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
  " Changing 'paste' changes many settings => we record them
  let cleanup = lh#on#exit()
        \.restore('&paste')
        \.restore('&autoindent')
        \.restore('&expandtab')
        \.restore('&formatoptions')
        \.restore('&revins')
        \.restore('&ruler')
        \.restore('&showmatch')
        \.restore('&smartindent')
        \.restore('&smarttab')
        \.restore('&softtabstop')
        \.restore('&tw')
        \.restore('&wrapmargin')
  let crt_expandtab = &expandtab
  try
    set paste
    let &expandtab = crt_expandtab
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
    call s:Verbose(strtrans("normal! gv". BL.substitute(a:end,'>',"\<c-v>>",'').BR.HL.a:begin.HR))
    if s:verbose >= 2
      debug exe "normal! gv". BL.substitute(a:end,'>',"\<c-v>>",'').BR.HL.a:begin.HR
    else
      silent exe "normal! gv". BL.substitute(a:end,'>',"\<c-v>>",'').BR.HL.a:begin.HR
    endif
    " 'gv' is used to refocus on the current visual zone
    "  call confirm(strtrans( "normal! gv". BL.a:end.BR.HL.a:begin.HR), "&Ok")
  finally
    call cleanup.finalize()
  endtry
endfunction

"------------------------------------------------------------------------
" ## Internal functions {{{1

" # Cursor moving {{{2
" Function: s:find_unused_mark() {{{3
function! s:find_unused_mark() abort
  let mark = lh#mark#find_first_unused()
  if mark == -1
    " TODO: return the first mark found which is before the cursor
    let mark = get(g:, 'lh#map#default_mark', "'M")
  endif
  return [mark, getpos(mark)]
endfunction

" Mark where the cursor should be at the end of the insertion

" Function: lh#map#_cursor_here(...) {{{3
function! lh#map#_cursor_here(...) abort
  let s:old_indent = indent(line('.'))
  let mark = s:find_unused_mark()
  call setpos(mark[0], getpos('.'))
  call s:Verbose('Using mark %1', mark)
  if a:0 > 0
    let s:goto_mark_{a:1} = mark
  else
    let s:goto_mark = mark
  endif
  call s:Verbose("Record cursor %1 with mark %2: |   indent=%3", get(a:, 1, ''), mark[0], s:old_indent)
  return ''
endfunction

" Function: lh#map#_goto_mark([old_behaviour]) {{{3
function! lh#map#_goto_mark(...) abort
  " We fetch the updated mark position. This is important in case automated
  " line breaking occurs (i.e. when cursor column exceeds 'tw'). Indeed, in
  " that case, the mark is automatically moved, and we need to use it's last
  " know position.
  let markpos = getpos(s:goto_mark[0]) + [virtcol(s:goto_mark[0])]
  let goto_lin = markpos[1]
  let goto_vcol = markpos[4]
  call s:Verbose('Returning to mark %1 @ %2', markpos[0][0], markpos[0][1])
  " Bug: if line is empty, indent() value is 0 => expect old_indent to be the One
  let crt_indent = indent(goto_lin)
  let s:fix_indent = s:old_indent - crt_indent
  call s:Verbose('fix indent <- %1 (old_indent:%2 - crt_indent:%3)', s:fix_indent, s:old_indent, crt_indent)

  try
    if s:fix_indent != 0
      let goto_vcol -= s:fix_indent
      call s:Verbose('goto_vcol -= %1 (old_indent:%3 - crt_indent:%4) => %2', s:fix_indent, goto_vcol, s:old_indent, crt_indent)
    endif
    let new_behaviour = (a:0 > 0) ? (!a:1) : 1
    if new_behaviour && goto_lin == line('.')
      " Same line -> eligible for moving the cursor
      " TODO: handle reindentation changes
      let delta = goto_vcol - virtcol('.')
      let move = lh#map#_move_cursor_on_the_current_line(delta)
      return move
    else
      let goto_col = markpos[2]
      let goto_col -= s:fix_indent
      " " uses {lig}'normal! {col}|' because of the possible reindent
      call s:Verbose("Restore cursor to %1normal! %2|", goto_lin, goto_col)
      execute goto_lin . 'normal! ' . (goto_col) . '|'
      " call cursor(goto_lin, goto_col)
      return ''
    endif
  finally
    " Restore the mark to [0,0,0,0] or to what it was
    call setpos(s:goto_mark[0], s:goto_mark[1])
  endtry
endfunction

" Function: lh#map#_goto_end_mark() {{{3
function! lh#map#_goto_end_mark() abort
  " Bug: if line is empty, indent() value is 0 => expect old_indent to be the One
  let markpos   = getpos(s:goto_mark[0])
  let markpos_1 = getpos(s:goto_mark_1[0])
  let markpos_2 = getpos(s:goto_mark_2[0])
  let goto_lin   = markpos[1]
  let goto_lin_1 = markpos_1[1]
  let goto_lin_2 = markpos_2[1]
  let goto_col   = markpos[2]
  let goto_col_1 = markpos_1[2]
  let goto_col_2 = markpos_2[2]

  try
    let crt_indent = indent(goto_lin)
    if crt_indent < s:old_indent
      let s:fix_indent = s:old_indent - crt_indent
    else
      let s:old_indent = crt_indent - s:old_indent
      let s:fix_indent = 0
    endif
    if s:old_indent != 0
      let goto_col += s:old_indent
    endif
    if     goto_lin != goto_lin_2
      " TODO: !!
    else
      let goto_col += goto_col_2 - goto_col_1
    endif
    call cursor(goto_lin, goto_col)
    return ''
  finally
    " Restore the marks to [0,0,0,0] or to what they were
    call setpos(s:goto_mark[0], s:goto_mark[1])
    call setpos(s:goto_mark_1[0], s:goto_mark_1[1])
    call setpos(s:goto_mark_2[0], s:goto_mark_2[1])
  endtry
endfunction

" Function: lh#map#_fix_indent() {{{3
function! lh#map#_fix_indent() abort
  return ''
  " return repeat( ' ', s:fix_indent)
endfunction


" Function: lh#map#_move_cursor_on_the_current_line(offset) {{{3
" This function tries to move the cursor in order to maintain redo-ability of
" the text inserted.
" See vim patch 7.4.849
function! lh#map#_move_cursor_on_the_current_line(offset) abort
  let abs_offset = lh#math#abs(a:offset)
  call s:Verbose("Moving cursor %1 x %2", abs_offset, a:offset>0 ? "right" : "left")
  let move = a:offset > 0 ? "\<right>" : "\<left>"
  return repeat(s:k_move_prefix.move, abs_offset)
endfunction

"------------------------------------------------------------------------

" }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
