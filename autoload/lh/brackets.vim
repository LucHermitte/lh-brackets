"=============================================================================
" File:         map-tools::lh#brackets.vim                             {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"               <URL:http://github.com/LucHermitte/lh-brackets>
" License:      GPLv3 with exceptions
"               <URL:http://github.com/LucHermitte/lh-brackets/tree/master/License.md>
" Version:      3.6.0
" Created:      28th Feb 2008
" Last Update:  15th Jan 2021
"------------------------------------------------------------------------
" Description:
"               This autoload plugin defines the functions behind the command
"               :Brackets that simplifies the definition of mappings that
"               insert pairs of caracters when the first one is typed. Typical
"               examples are the parenthesis, brackets, <,>, etc.
"               The definitions can be buffer-relative or global.
"
"               This :Bracket command is used by different ftplugins:
"               <vim_brackets.vim>, <c_brackets.vim> <ML_brackets.vim>,
"               <html_brackets.vim>, <php_brackets.vim> and <tex_brackets.vim>
"               -- available on my github respos.
"
"               BTW, they can be activated or desactivated by pressing <F9>
"
"------------------------------------------------------------------------
" History:
" Version 3.6.0:  26th Nov 2019
"               * Fix When -close is provided but not -open
"               * Export s:Jump() as lh#brackets#_jump()
"               * Fix g:cb_disable_default/g:cb_enable_default
"               * Support enriching non-<expr> imaps
"               * Moving `s:DefineMap()` function to lh-vim-lib
"               * Move bracket manipulation functions to autoload plugin
"               * Use registered brackets in bracket manipulation functions
"               * Improve pair registration for deleting, replacing...
" Version 3.5.3:  21st Jan 2019
"               * Fix <BS> when cb_no_default_brackets is true
" Version 3.5.2:  12th Sep 2018
"               * lh#brackets#close_all_and_jump_to_last_on_line() was
"                 keeping closing chars instead of markers...
" Version 3.5.1:  24th May 2018
"               * lh#brackets#close_all_and_jump_to_last_on_line() uses the
"                 complete and dynamic list of closing characters
"               * Fix `v_<Plug>MarkersCloseAllAndJumpToLast`
" Version 3.5.0:  16th May 2018
"               * Require lh-vim-lib 4.4.0
"               * Merge s:JumpOverAllClose into
"                 lh#brackets#close_all_and_jump_to_last_on_line
"               * Add parameter in
"                 lh#brackets#close_all_and_jump_to_last_on_line() to merge
"                 only with the first next lexeme
"               * Default :Brackets definitions can be disabled with
"                 g:cb_disable_default/g:cb_enable_default
"
" Version 3.4.2:  28th Mar 2018
"               * Require lh-vim-lib 4.3.0
"               * Move _switch functions to lh-vim-lib
"               * enrich_imap will reuse a previous existing mapping
" Version 3.3.0:  02nd Oct 2017
"	        `;` jumps over `]`
"	        Fix merging of trailling characters in JumpOverAllClose
" Version 3.2.1:
"               * Fix regression with `set et`
" Version 3.2.0:
"               * Add `lh#brackets#jump_outside()`
"               * Fix `Brackets -list`
"               * Add `Brackets -context!=`
"               * Fix `<BS>` to clear any bracket pair
"               * Fix portability issue (type changes)
" Version 3.1.3:
"               * Fix syntax error in `lh#brackets#_string`
" Version 3.1.0:
"               * New option to `:Bracket` -> `-context`
" Version 3.0.8:
"               * Fix issue8, regression introduced in v3.0.7 with double-quotes
" Version 3.0.7:
"               * Refactoring: simplify lh#brackets#define() debugging
"               * Fix lh#brackets#_string() to have <localleader>1 works in
"               C&C++
"               * Revert v3.0.4 changes, the mapping shall be done with:
"                 ":Bracket \\\\Q{ } -trigger=µ"
"                 This is related to command mode handling of backslash:
"                 - Odd number backslashes are an oddity that are sometimes
"                   interpreted by the command line (e.g. "\ ", "\|"),
"                   sometimes not (most other cases like "\n", "\Q", ...)
"                 - Even number of backslashes are reduced by half when passed
"                   to the function behind the command (i.e. "\\n" becomes
"                   "\n", "\\Q" becomes "\Q"). All in all, there is no way to
"                   distinguish "\n" from '\n' except by using twice the number
"                   of backslahes again, i.e. 2 (real backslash) x 2 (command
"                   line) to write things like '\n'.
"                 Hence
"                 ":Bracket \\\\Q{ } -trigger=µ"
"               TODO: Add an entry into the documentation.
"
" Version 3.0.5:
"               * Use lh#log() framework
" Version 3.0.4:
"               * Support definitions like ":Bracket \Q{ } -trigger=µ"
"                 Some olther mappings may not work anymore. Alas I have no tests
"                 for them ^^'
" Version 3.0.3:
"               * Fix JumpOverAllClose when marker characters contains active
"                 characters in very-magic regex ':h /\v'
" Version 3.0.2:
"               * Fix regression introduced by the support of older versions
" Version 3.0.1:
"               * Support older versions of vim, thanks to Troy Curtis Jr
" Version 3.0.0:
"               * Support for closing all markers and jumping to the last one
" Version 2.3.5:
"               * Fix regression on
"                 :Brackets #if\ 0 #else!mark!\n#endif -insert=0 -nl -trigger=,1
" Version 2.3.4:
"               * Fix surrounding and -newline
" Version 2.3.0:
"               * Support for redo-able brackets
" Version 2.2.5:
"               * Better fix for the bug about line breaks when &tw is
"               exceeded.
" Version 2.2.4:
"               * Fix Issue#1 (Line inserted above current line with typing '(')
" Version 2.2.3:
"               * Fix a bug when the bracket pair inserted would trigger a line
"               break because of 'tw' exceeded.
"               * Correctly handle escaped brackets on <BS>
" Version 2.2.0:
"               * b:usemarks -> [bg]:usemarks through lh#brackets#usemarks()
" Version 2.1.2:
"               * New internal function to remove markers:
"               lh#brackets#_jump_text()
" Version 2.1.1:
"               * Bug fixed regarding the mapping of special keys like <cr>,
"               <bs>, ... while IMAP is active
" Version 2.1.0:
"               * Features from lh-cpp moved to lh-brackets:
"                 - <cr> within empty brackets;
"                 - <del> within empty brackets ;
"               * New option -but to !Brackets to exclude patterns
" Version 2.0.2:
"               * JumpOverAllClose fixed to support other things than ';' when
"               jumping
" Version 2.0.1:
"               * ambiguity between Brackets-close and -Brackets-clear
" Version 2.0.0:
"               * GPLv3
" Version 1.1.1:
"               * Issue#10 refinements: use a stricter placeholder regex to not
"               delete everything in ").lh#marker#txt('.\{-}').'\)\+')"
" Version 1.0.0:
"               * Vim 7 required!
"               * New way to configure the desired brackets, the previous
"               approach has been deprecated
" TODO:
" * Update doc
" * -surround=function('xxx') option
" * Try to use it to insert stuff like "while() {}" ?
" * have :Brackets -insert=1 automatically exclude visual and normal modes
" }}}1
"=============================================================================

let s:cpo_save=&cpo
set cpo&vim

" ## Debug {{{1
let s:verbose = get(s:, 'verbose', 0)
function! lh#brackets#verbose(...) abort
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

function! lh#brackets#debug(expr) abort
  return eval(a:expr)
endfunction


" ## Options {{{1
" Defines the surrounding mappings:
" - for both VISUAL and select mode -> "v"
" - for both VISUAL mode only -> "x"
" NB: can be defined in the .vimrc only
" todo: find people using the select mode and never the visual mode
let s:k_vmap_type = lh#option#get('bracket_surround_in', 'x', 'g')

" Does vim supports the new way to support redo/undo?
let s:k_vim_supports_redo = has('patch-7.4.849')
let s:k_move_prefix = s:k_vim_supports_redo ? "\<C-G>U" : ""

" Function: lh#brackets#usemarks()                                                                           {{{2
function! lh#brackets#usemarks() abort
  return lh#option#get('usemarks', 1)
endfunction

"------------------------------------------------------------------------
" ## Mappings Toggling {{{1
"
"# Globals                                                                                                   {{{2
"# Definitions {{{3
if !exists('s:pairs') || exists('brackets_clear_definitions')
  "" let s:definitions = {}
  let s:pairs       = {}
endif
if !exists('s:toggable_mappings')
  let s:toggable_mappings = lh#mapping#create_toggable_group('Brackets ')
endif

"# Functions                                                                                                 {{{2

" Function: s:GetPairs(isLocal) {{{3
" Fetch the brackets defined for the current buffer.
function! s:GetPairs(isLocal) abort
  let bid = a:isLocal ? bufnr('%') : -1
  if !has_key(s:pairs, bid)
    let s:pairs[bid] = []
  endif
  let crt_pairs = s:pairs[bid]
  return crt_pairs
endfunction

" Function: s:GetAllPairs() {{{3
function! s:GetAllPairs() abort
  let crt_pairs = copy(s:GetPairs(0))
  call extend(crt_pairs, s:GetPairs(1))
  return crt_pairs
endfunction

" Function: s:AddPair(isLocal, open, close) {{{3
function! s:AddPair(isLocal, open, close) abort
  let crt_pairs = s:GetPairs(a:isLocal)
  let new_pair = [a:open, a:close]
  call lh#list#push_if_new(crt_pairs, new_pair)
endfunction


" Function: Main function called to toggle bracket mappings. {{{3
function! lh#brackets#toggle() abort
  call s:toggable_mappings.toggle_mappings()
endfunction

" Function: lh#brackets#toggle_usemarks() {{{3
function! lh#brackets#toggle_usemarks() abort
  if exists('b:usemarks')
    let b:usemarks = 1 - b:usemarks
    call lh#common#warning_msg('b:usemarks <-'.b:usemarks)
  elseif exists('g:usemarks')
    let g:usemarks = 1 - g:usemarks
    call lh#common#warning_msg('g:usemarks <-'.g:usemarks)
  else
    let g:usemarks = 0
    call lh#common#warning_msg('g:usemarks <-'.g:usemarks)
  endif
endfunction

"------------------------------------------------------------------------

" ## Brackets definition functions {{{1
"------------------------------------------------------------------------

" Function: lh#brackets#_string(s)                                                                           {{{2
function! lh#brackets#_string(s) abort
  if type(a:s) == type(function('has'))
    return string(a:s)
  endif
  " See Version 3.0.7 comment note.
  " return '"'.substitute(a:s, '\v(\\\\|\\[a-z]\@!)', '&&', 'g').'"'
  " return '"'.escape(a:s, '"\').'"'  " version that works with most keys, like \\
  return '"'.escape(a:s, '|"').'"'  " version that works with double quote and \n
  " return '"'.a:s.'"'                " version that works with \n
  " return string(a:s) " version that doesn't work: need to return something enclosed in double quotes
endfunction

"------------------------------------------------------------------------
" Function: s:thereIsAnException(Ft_exceptions)                                                              {{{2
function! s:thereIsAnException(Ft_exceptions) abort
  if empty(a:Ft_exceptions)
    return 0
  elseif type(a:Ft_exceptions) == type(function('has'))
    return a:Ft_exceptions()
  else
    return &ft =~ a:Ft_exceptions
  endif
endfunction

"------------------------------------------------------------------------
" Function: lh#brackets#opener(trigger, escapable, nl, Open, close, areSameTriggers,Ft_exception [,context]) {{{2
" NB: this function is made public because IMAPs.vim need it to not be private
" (s:)
" Remarks:
" - a:Close shall always be a string. Indeed:
"   - When a:Open is a function, a:Close is ignored
"   - Otherwise, a:Close is handled as if it was a string.
function! lh#brackets#opener(trigger, escapable, nl, Open, close, areSameTriggers, Ft_exceptions, ...) abort
  if s:thereIsAnException(a:Ft_exceptions)
    return a:trigger
  endif
  let line = getline('.')
  let escaped = line[col('.')-2] == '\'
  if type(a:Open) == type(function('has'))
    let res = call('lh#map#insert_seq',[a:trigger, a:Open()]+a:000)
    return res
  elseif has('*IMAP')
    return s:ImapBrackets(a:trigger)
  elseif a:escapable
    let e = (escaped ? '\' : "")
    " todo: support \%(\) with vim
    " let open = '\<c-v\>'.a:Open
    " let close = e.'\<c-v\>'.a:close
    let open = a:Open
    let close = e.a:close
  elseif escaped
    return a:trigger
  elseif a:areSameTriggers && lh#option#get('cb_jump_on_close',1) && lh#position#char_at_mark('.') == a:trigger
    return lh#brackets#_jump()
  else
    let open = a:Open
    let close = a:close
  endif

  if ! empty(a:nl)
    " Cannot use the following generic line because &inckey does not always
    " work and !cursorhere! does not provokes a reindentation
    "  :return lh#map#insert_seq(a:trigger, a:Open.a:nl.'!cursorhere!'.a:nl.a:close.'!mark!')
    " hence the following solution
    return call('lh#map#insert_seq', [a:trigger, open.a:nl.close.'!mark!\<esc\>O']+a:000)
  else
    let c = virtcol('.')
    let c = col('.')
    " call s:Verbose(c)
    let current = matchstr(line, '.*\%'.(c).'c\S*')
    if 0 && &tw > 0 && lh#encoding#strlen(current.open.close.lh#marker#txt()) > &tw
      " v2.3.0 update:
      " This situation (that should take &fo and &wrapmargin into account as
      " well) could only occur when the cursor is moved on the same line (from
      " after the closing bracket to in between the brackets). This case is now
      " handled in lh#map#_goto_mark() that just applies a relative move that
      " is compatible with any setting of &fo/&wm/&tw


      " ---< deprecated >---
      " Problems occurs when the inserted text is near &tw
      " => need to cut only in this case
      "
      " Inserted text will go on the next line => force the newline before!
      " But don't forget to take the text that has to come right before
      let [head, before, after] = lh#brackets#_split_line(line, c, &tw)
      " Now the mapping is a :map-<expr>, we cannot break the line with a
      " :setline(), we'll have to move the cursor
      if 0
        call setline(line('.'), head)
        " An undo break is added here. I'll have to investigate that someday
        let before = "\<cr>".substitute(before, '^\s\+', '', '')
        return call('lh#map#insert_seq', [a:trigger, before.open.'!cursorhere!'.close.'!mark!'.after]+a:000)
      endif
      let delta_to_line_cut = lh#encoding#strlen(before)
      let delta_to_insertion = lh#encoding#strlen(substitute(before, '^\s\+', '', ''))
      let prepare = lh#map#_move_cursor_on_the_current_line(- delta_to_line_cut)
            \ . "\<cr>"
            \ . lh#map#_move_cursor_on_the_current_line(delta_to_insertion)

      " echomsg "--> ".strtrans(prepare)

      return call('lh#map#insert_seq',[a:trigger, prepare.open.'!cursorhere!'.close.'!mark!']+a:000)
    endif
    return call('lh#map#insert_seq',[a:trigger, open.'!cursorhere!'.close.'!mark!']+a:000)
endfunction

"------------------------------------------------------------------------
" Function: lh#brackets#closer(trigger, Action, Ft_exceptions)                                               {{{2
function! lh#brackets#closer(trigger, Action, Ft_exceptions) abort
  if s:thereIsAnException(a:Ft_exceptions)
    return a:trigger
  endif
  if type(a:Action) == type(function('has'))
    return lh#map#insert_seq(a:trigger,a:Action())
  elseif has('*IMAP')
    return s:ImapBrackets(a:trigger)
  else
    return s:JumpOrClose(a:trigger)
  endif
endfunction

"------------------------------------------------------------------------
" Function: s:JumpOrClose(trigger)                                                                           {{{2
function! s:JumpOrClose(trigger) abort
  if lh#option#get('cb_jump_on_close',1) && lh#position#char_at_mark('.') == a:trigger
    " todo: detect even if there is a newline in between
    return lh#brackets#_jump()
  else
    return a:trigger
  endif
endfunction

"------------------------------------------------------------------------
" Function: lh#brackets#closing_chars()                                                                      {{{2
function! lh#brackets#closing_chars() abort
  let closings = map(s:GetPairs(0) + s:GetPairs(1), 'v:val[1]')
  call lh#list#unique_sort(closings)
  let res = join(filter(closings, 'lh#encoding#strlen(v:val)==1'), '')
  return res
endfunction

"------------------------------------------------------------------------
" Function: lh#brackets#close_all_and_jump_to_last_on_line(chars, opts)                                       {{{2
" - {a:1} optional terminal mark to merge/append
" - {a:2} to limit the number of matches -- valid values: "*", "+", "=", "?", "{42}"...
function! lh#brackets#close_all_and_jump_to_last_on_line(chars, opts) abort
  let mode = get(a:opts, 'mode', '')
  let chars = escape(a:chars, ']')
  let del_mark = ''
  let ll = ''
  if mode == 'v'
    let selection = lh#visual#selection()
    if lh#marker#is_a_marker(selection)
      let del_mark = s:k_move_prefix."\<left>"
      let ll = lh#encoding#strpart(selection, 0, 1)
    elseif col('.') != col("'>")
      " In visual mode, we can move around violently, redoing actions isn't
      " possible anyway... => we don't care!
      normal! `>
    endif
  endif
  let p = col('.')
  let ll .= matchstr(getline('.'), '\%>'.p.'c.*') " ignore char under cursor, look after (MB: compatible)
  let re_v_marker = lh#marker#very_magic('.{-}')
  let m   = matchstr(ll, '\v^(['.chars.']|'.re_v_marker.')'.get(a:opts, 'repeat', '+'))
  let len_match = lh#encoding#strlen(m)
  let nb_bytes_match = strlen(m)
  call s:Verbose("In ##%1##  %3 characters/%4 bytes match: ##%2##", ll, m, len_match, nb_bytes_match)
  if len_match
    let del_mark .= repeat("\<del>", len_match)
    let del_mark .= substitute(m, '\v'.re_v_marker, '', 'g')
  endif
  " Is there an optional terminal mark to check and merge/add (like: «»;«») ?
  let to_merge = get(a:opts, 'to_merge', lh#option#unset())
  if lh#option#is_set(to_merge)
    let nb_bytes_match = strlen(m)
    let remaining = ll[nb_bytes_match : ]
    call s:Verbose("rem: ##%1## VS %2", remaining, to_merge)
    let placeholder = lh#marker#txt('.\{-}')
    let match_rem = matchstr(remaining, '^\('.placeholder.'\)*'.to_merge.'\('.placeholder.'\)*')
    let len_match_rem = lh#encoding#strlen(match_rem)
    if len_match_rem
      let del_mark = repeat("\<del>", len_match_rem).del_mark
    endif
    let del_mark .= to_merge
  endif
  call s:Verbose("-> %1", strtrans(del_mark))

  return s:k_move_prefix."\<right>".del_mark
endfunction

"------------------------------------------------------------------------
" Function: lh#brackets#_jump()                                                                              {{{2
function! lh#brackets#_jump() abort
  " todo: get rid of the marker as well
  let p = col('.')

  let ll = getline('.')[p : ]
  " echomsg ll
  let m = matchstr(ll, '^'.lh#marker#txt('.\{-}'))
  let lm = lh#encoding#strlen(m)
  let del_mark = repeat("\<del>", lm)
  return s:k_move_prefix."\<right>".del_mark
endfunction

"------------------------------------------------------------------------
" Function: s:outer_blocks()                                                                                 {{{2
function! s:outer_blocks() abort
  let crt_pairs = s:GetAllPairs()
  let matches = {}
  for p in crt_pairs
    if p[0] != p[1] " searchpos doesn't work in that case
      let pos = searchpairpos(p[0], '', p[1], 'cWn', "lh#syntax#is_a_comment('.')")
      call s:Verbose('Testing searchpos(%1) -> %2', p, pos)
    elseif p[0] =~ '["'']'
      " Stuff which can be checked with vi', vi"
      let crt_pos = getpos('.')
      let cleanup = lh#on#exit()
            \.restore('@a')
            \.register('call setpos(".", '.string(crt_pos).')')
      try
        let @a = ''
        silent! exe 'normal! "aya'.p[0]
        " 2 chars are to be expected for open and close
        if lh#encoding#strlen(@a) >= lh#encoding#strlen(p[0].p[1])
          " In two steps because it may fail
          " -- it shouldn't though thanks to len(@a) >= 2 * len(open)
          exe 'normal! v'
          silent! exe 'normal! a'.p[0]
          silent! exe "normal! \<esc>"
          let pos = getpos('.')[1:2]
        else
          let pos = [0,0]
        endif
        if 0
          " getpos doesn't seem to work...
          let pos = getpos('`>')[1:2]
          if getpos('`<')[1:2] == pos
            let pos = [0,0]
          endif
        endif
        call s:Verbose('Testing va%1 -> %2 - %3', p[0], pos, @a)
      finally
        call cleanup.finalize()
      endtry
    else
      let pos = searchpos(p[0], 'cWnb', 'lh#syntax#is_a_comment(".")')
      if  pos != [0,0]
        let pos = searchpos(p[1], 'cWn', 'lh#syntax#is_a_comment(".")')
      endif
      call s:Verbose('Testing /%1 -> %2', p[0], pos)
    endif
    if pos != [0,0]
      let matches[p[0]] = pos
    endif
  endfor
  call s:Verbose('Containing bracket pairs: %1', matches)
  return matches
endfunction

"------------------------------------------------------------------------
" Function: lh#brackets#jump_outside(param)                                                                  {{{2
" In this flavour, we don't expect to be just before the current closing
" character. Instead, search for the next character that closes the current
" scope.
function! lh#brackets#jump_outside(param) abort
  let mode      = get(a:param, 'mode')

  let matches = s:outer_blocks()
  if empty(matches)
    call s:Verbose('The cursor doesn''t belong to any block')
    return ''
  endif
  let m2 = map(values(matches), '[0]+v:val')
  call sort(m2, 'lh#position#compare')
  let crt_pos = getpos('.')
  let dest = m2[0]+[0]
  " call assert_true(lh#position#is_before(crt_pos, dest))
  " Insert mode, :map-<expr>
  if mode =~ '[is]' && crt_pos[1] == dest[1] " same-line
    " Need to know how many characters does this really represent, not the
    " number of bytes!
    let text = lh#position#extract(crt_pos, dest)
    let offset = lh#encoding#strlen(text)+1
    return lh#map#_move_cursor_on_the_current_line(offset)
  else
    call setpos('.', dest)
    return mode == 'i' ? "\<Right>" : "a"
  endif
endfunction

"------------------------------------------------------------------------
" Function: s:ImapBrackets(obrkt, cbrkt, esc, nl)                                                            {{{2
" Internal function.
" {obrkt}:      open bracket
" {cbrkt}:      close bracket
" {esc}:        escaped version 0:none, 1:\, 2:\%
" {nm}:         new line between {obrkt} and {cbrkt}
function! s:ImapBrackets(obrkt, cbrkt, esc, nl) abort
  " Generic function used by the others
  if     a:esc == 0 | let open = ''   | let close = ''
  elseif a:esc == 1 | let open = '\'  | let close = '\'
  elseif a:esc == 2 | let open = '\%' | let close = '\'
  else
    echoerr "Case not handled (yet)!"
  endif
  let key = open . a:obrkt
  let middle = a:nl ? "\<cr><++>\<cr>" : '<++>'
  let expr = key . middle . close . a:cbrkt .'!mark!'
  if &ft == "vim" && a:esc " expand only within strings
    return IMAP_PutTextWithMovement(Smart_insert_seq2(key,expr, 'string\|PatSep'))
  else
    return IMAP_PutTextWithMovement(Smart_insert_seq2(key,expr))
  endif
endfunction
"------------------------------------------------------------------------

"------------------------------------------------------------------------
"------------------------------------------------------------------------
"------------------------------------------------------------------------
" Function: lh#brackets#_switch(trigger, cases)                                                              {{{2
function! lh#brackets#_switch_int(trigger, cases) abort
  call lh#notify#deprecated('lh#brackets#_switch_int', 'lh#mapping#_switch_int')
  return lh#mapping#_switch_int(a:trigger, a:cases)
endfunction

function! lh#brackets#_switch(trigger, cases) abort
  call lh#notify#deprecated('lh#brackets#_switch', 'lh#mapping#_switch')
  return lh#mapping#_switch(a:trigger, a:cases)
endfunction

" Function: lh#brackets#define_imap(trigger, cases, isLocal [,default=trigger])                              {{{2
" TODO: see how it can be moved to lh#mapping
function! lh#brackets#define_imap(trigger, cases, isLocal, ...) abort
  " - Some keys, like '<bs>', cannot be used to code the default.
  " - Double "string(" because those chars are correctly interpreted with
  " lh#mapping#reinterpret_escaped_char(eval()), which requires nested strings...
  let default = (a:0>0) ? (a:1) : (a:trigger)
  if type(a:cases) == type([])
    let sCases='lh#mapping#_switch('.string(string(default)).', '.string(a:cases).')'
  else
    call lh#assert#type(a:cases).is('')
    let sCases = a:cases
  endif
  call s:toggable_mappings.define_imap(a:trigger, sCases, a:isLocal)
endfunction

" Function: lh#brackets#enrich_imap(trigger, case, isLocal [,default=trigger])                               {{{2
" TODO: see how it can be moved to lh#mapping
function! lh#brackets#enrich_imap(trigger, case, isLocal, ...) abort
  " - Some keys, like '<bs>', cannot be used to code the default.
  " - Double "string(" because those chars are correctly interpreted with
  " lh#mapping#reinterpret_escaped_char(eval()), which requires nested strings...
  call s:Verbose('Enriching imaping on %1', strtrans(a:trigger))
  call s:Verbose('...previously %1', strtrans(join(lh#askvim#execute('verbose imap <cr>'), "\n")))
  let nore = 1
  if a:0 == 0
    let previous = maparg(a:trigger, 'i', 0, 1)
    if empty(previous)
      let default = string(a:trigger)
    elseif previous.expr
      let default = lh#mapping#_build_rhs(previous)
      let nore    = previous.noremap
    else
      let default = string(previous.rhs)
      let nore    = previous.noremap
      " call s:Verbose('%1 ==> %2', previous.rhs, default)
    endif
  else
    let default = string(a:1)
  endif
  let sCase='lh#mapping#_switch('.string(default).', '.string([a:case]).')'
  call s:toggable_mappings.define_imap(a:trigger, sCase, a:isLocal, nore)
  call s:Verbose('New i-mapping on %1 is %2', strtrans(a:trigger), strtrans(join(lh#askvim#execute('verbose imap <cr>'), "\n")))
endfunction

"------------------------------------------------------------------------
" Function: s:ShallKeepDefaultMapping(trigger, mode) abort {{{2
function! s:ShallKeepDefaultMapping(trigger, mode) abort
  if exists('g:cb_enable_default') && exists('g:cb_disable_default')
    call lh#notify#once('lh_brackets_no_defaults', 'Warning: Both g:cb_enable_default and g:cb_disable_default are defined, g:cb_disable_default will be ignored')
  endif
  if exists('g:cb_enable_default')
    return stridx(get(g:cb_enable_default, a:trigger, 'inv'), a:mode) >= 0
  elseif exists('g:cb_disable_default')
    return stridx(get(g:cb_disable_default, a:trigger, ''), a:mode) == -1
  else
    return 1
  endif
endfunction

"------------------------------------------------------------------------
" Function: s:DecodeDefineOptions(isLocal, a000)                                                             {{{2
function! s:IsFalse(value) abort
  if type(a:value) == type(0)
    return ! a:value
  else
    call lh#assert#type(a:value).is('string')
    if a:value =~ '^\d\+$'
      return ! eval(a:value)
    else " case like "default=X"
      return 0
    endif
  endif
endfunction

function! s:DecodeDefineOptions(isLocal, a000) abort
  let nl         = ''
  let insert     = 1
  let visual     = 1
  let normal     = 'default=1'
  let escapable  = 0
  let context    = {}
  let options    = []
  let default    = 0
  let pair       = []
  for p in a:a000
    if     p =~ '-l\%[list]'        | call s:toggable_mappings.list_mappings(a:isLocal)  | return []
    elseif p =~ '-cle\%[ar]'        | call s:toggable_mappings.clear_mappings(a:isLocal) | return []
    elseif p =~ '-nl\|-ne\%[wline]' | let nl        = '\n'
    elseif p =~ '-e\%[scapable]'    | let escapable = 1
    elseif p =~ '-p\%[air]='        | let pair      = matchstr(p, '-p\%[air]=\zs.*')
    elseif p =~ '-t\%[rigger]'      | let trigger   = matchstr(p, '-t\%[rigger]=\zs.*')
    elseif p =~ '-i\%[nsert]'       | let insert    = matchstr(p, '-i\%[nsert]=\zs.*')
    elseif p =~ '-v\%[isual]'       | let visual    = matchstr(p, '-v\%[isual]=\zs.*')
    elseif p =~ '-no\%[rmal]'       | let normal    = matchstr(p, '-n\%[ormal]=\zs.*')
    elseif p =~ '-co\%[ntext]='     | let context   = {'is'   : matchstr(p, '-co\%[ntext]=\zs.*')}
    elseif p =~ '-co\%[ntext]!='    | let context   = {"isn't": matchstr(p, '-co\%[ntext]!=\zs.*')}
    elseif p =~ '-default'          | let default   = 1
    elseif p =~ '-b\%[ut]'
      let exceptions= matchstr(p, '-b\%[ut]=\zs.*')
      if exceptions =~ "^function"
        exe 'let l:Exceptions='.exceptions
      else
        let l:Exceptions = exceptions
      endif
    elseif p =~ '-o\%[open]'
      let open = matchstr(p, '-o\%[pen]=\zs.*')
      if open =~ "^function"
        exe 'let l:Open =' . open
      else
        let   l:Open = open
      endif
      " let   l:Open = open =~ "^function" ? {open} : open   ## don't work with function()
    elseif p =~ '-clo\%[se]'
      let close = matchstr(p, '-clo\%[se]=\zs.*')
      if close =~ "^function"
        exe 'let l:Close =' . close
      else
        let l:Close = close
      endif
      " let l:Close = close =~ "^function" ? {close} : close   ## don't work with function()
    else
      " <f-args> double backslash characters other than "\ " or "\\" => we
      " need to reinterpret them correctly to what they should have been
      " Let's just fix '\' followed by a letter
      " exe 'let p = "'.p.'"'

      call add(options, p)
    endif
  endfor
  if len(options) != 2
    throw ":Brackets: incorrect number of arguments"
  endif

  if !exists('trigger')      | let trigger      = options[0] | endif
  if !exists('l:Open')       | let l:Open       = options[0] | endif
  if !exists('l:Close')      | let l:Close      = options[1] | endif
  if !exists('l:Exceptions') | let l:Exceptions = ''         | endif
  if empty(pair)
    let pair_list = options
  else
    let sep = pair[0]
    let pair_list = split(pair[1:], sep)
  endif

  if default
    let insert = insert && s:ShallKeepDefaultMapping(trigger, 'i')
    let visual = visual && s:ShallKeepDefaultMapping(trigger, 'v')
    let normal = !s:IsFalse(normal) && s:ShallKeepDefaultMapping(trigger, 'n') ? normal : 0
  endif

  return [nl, insert, visual, normal, options, trigger, l:Open, l:Close, l:Exceptions, escapable, context, pair_list]
endfunction

" Function: lh#brackets#define(bang, ...)                                                                    {{{2
function! lh#brackets#define(bang, ...) abort
  " Parse Options {{{3
  let isLocal    = a:bang != "!"
  let res = s:DecodeDefineOptions(isLocal, a:000)
  if empty(res) | return | endif
  let [nl, insert, visual, normal, options, trigger, l:Open, l:Close, l:Exceptions, escapable, context, pair]
        \ = res

  if len(pair) == 2
    " if type(l:Open) != type(function('has')) &&  type(l:Close) != type(function('has'))
    call s:AddPair(isLocal, pair[0], pair[1])
    if escapable
      call s:AddPair(isLocal, '\\'.pair[0], '\\'.pair[1])
    endif
  endif

  " INSERT-mode open {{{3
  if insert
    " INSERT-mode close
    let areSameTriggers = options[0] == options[1]
    let map_ctx = empty(context) ? '' : ','.string(context)
    let inserter = 'lh#brackets#opener('.lh#brackets#_string(trigger).','. escapable.',"'.(nl).
          \'",'. lh#brackets#_string(l:Open).','.lh#brackets#_string(options[1]).','.string(areSameTriggers).','.string(l:Exceptions).map_ctx.')'
    call s:toggable_mappings.define_imap(trigger, inserter, isLocal)
    if ! areSameTriggers
      let inserter = 'lh#brackets#closer('.lh#brackets#_string(options[1]).','.lh#brackets#_string (l:Close).','.lh#brackets#_string(l:Exceptions).map_ctx.')'
      call s:toggable_mappings.define_imap(options[1], inserter, isLocal)
      if len(options[1])
        " TODO: enrich <bs> & <del> imaps for the close triggers
      endif
    endif
  endif

  " VISUAL-mode surrounding {{{3
  if visual
    if !empty(nl)
      let action = ' <c-\><c-n>@=lh#map#surround('.
            \ lh#brackets#_string(options[0].'!cursorhere!').', '.
            \ lh#brackets#_string(options[1].'!mark!').", 1, 1, '', 1, ".lh#brackets#_string(trigger).")\<cr>"
    else
      let action = ' <c-\><c-n>@=lh#map#surround('.
            \ lh#brackets#_string(options[0]).', '.lh#brackets#_string(options[1]).", 0, 0, '`>ll', 1)\<cr>"
    endif
    call s:toggable_mappings.define_map(s:k_vmap_type.'nore', trigger, action, isLocal, 0)

    if type(normal)==type('string') && normal=="default=1"
      let normal = 1
    endif
  elseif type(normal)==type('string') && normal=="default=1"
    let normal = 0
  endif

  " NORMAL-mode surrounding {{{3
  " NB: it looks like "'1' == 1" and "'0' == 1" behave correctly, but I'm not
  " sure it does with every version of vim...
  if type(normal)==type('string') && normal =~ '\v^\d+$'
    let normal = eval(normal)
  endif
  if lh#type#is_number(normal) && normal
    let normal = empty(nl) ? 'viw' : 'V'
  endif
  if lh#type#is_string(normal)
    call s:toggable_mappings.define_map('n', trigger, normal.escape(trigger, '|'), isLocal, 0)
  endif
endfunction

"------------------------------------------------------------------------
" Function: lh#brackets#_match_any_bracket_pair()                                                            {{{2
function! lh#brackets#_match_any_bracket_pair() abort
  let crt_pairs = s:GetAllPairs()
  if empty(crt_pairs)
    return 0
  endif
  " let regex = '\V\('.join(map(copy(crt_pairs), 'escape(join(v:val,"\\%'.col('.').'c"), "\\")'), '\|').'\)'
  let regex = '\V\('.join(map(crt_pairs, 'join(v:val,"\\%'.col('.').'c")'), '\|').'\)'
  return getline(".")=~ regex
endfunction

"------------------------------------------------------------------------
" Function: lh#brackets#_delete_empty_bracket_pair()                                                         {{{2
function! lh#brackets#_delete_empty_bracket_pair() abort
  let crt_pairs = s:GetAllPairs()
  let regex = '\V\('.join(map(crt_pairs, 'join(v:val,"\\%'.col('.').'c")'), '\|').'\)'
        \ . '\('.lh#marker#txt('\.\{-}').'\)\='
  let line = getline('.')

  if exists('*matchstrpos') " Since v 7.4-1685...
    let m = matchstrpos(line, regex)
  else " innefficient
    let m = [matchstr(line, regex), match(line, regex), matchend(line, regex)]
  endif
  " move right with the prefix len
  let start = line[m[1] : col('.')-2]
  let lenstart = lh#encoding#strlen(start)
  " call s:Verbose('%1 in %2 -- len(%3)=%4', col('.'), m, start, lenstart)
  return repeat(s:k_move_prefix."\<left>", lenstart).repeat("\<del>", lh#encoding#strlen(m[0]))

  " Note: matchstrpos, col('.'), ... return byte offsets
  " \<left> and \<del> use number of characters => use lh#encoding#strlen() to
  " count the exact number of characters that match.
endfunction

"------------------------------------------------------------------------
" Function: lh#brackets#_add_newline_between_brackets()                                                      {{{2
" TODO: make this action redoable
function! lh#brackets#_add_newline_between_brackets() abort
  return "\<cr>\<esc>O"
endfunction

" Function: lh#brackets#_jump_text(marker)                                                                   {{{2
function! lh#brackets#_jump_text(marker) abort
  let m = matchstr(a:marker, '^'.lh#marker#txt('.\{-}'))
  let l = lh#encoding#strlen(m)
  return repeat("\<del>", l)
endfunction
"
"------------------------------------------------------------------------
" Function: lh#brackets#_split_line(line, c, tw)                                                             {{{2
function! lh#brackets#_split_line(line, c, tw) abort
  let line = a:line
  let c    = a:c

  let head = matchstr(line, '.\{-}\ze\(\s\+\S*\%'.(c).'c\|$\)')
  " assert(lh#encoding#strlen(head) <= &tw)
  " assert(lh#encoding#strlen(head) <= c)
  let head_length = lh#encoding#strlen(head)
  let trailling = matchstr(line, '.*', head_length+1)
  let before = lh#encoding#strpart(trailling, 0, c - head_length-2)
  let after = matchstr(trailling, '.*', c - head_length-2)
  return [head, before, after]
endfunction

"------------------------------------------------------------------------
" ## Brackets changing functions {{{1

" Function: lh#brackets#_delete_brackets() {{{2
function! lh#brackets#_delete_brackets() abort
  let line = getline(line("."))
  let off = col(".") - 1
  let b = line[off - 1]
  let c = line[off]
  if b == '\' && (c == '{' || c == '}')
    normal! X%X%
  endif
  let crt_pairs = filter(s:GetAllPairs(), 'strlen(v:val[0]) == 1')
  let iso_pairs = map(filter(copy(crt_pairs), 'v:val[0] == v:val[1]'), 'v:val[0]')
  if index(iso_pairs, c) >= 0
    " let's suppose everything is on the same line
    " let's ignore vim comments
    " let's ignore embedded stuff like "'"

    " need to detect to which pair the character belongs to
    let m = len(lh#string#matches(line[:off], c))
    let lline = split(line, '\zs')
    if m % 2 == 0
      let c2 = matchend(line[:off-1], '.*'.c)
      if c2 >= 0
        unlet lline[off]
        unlet lline[c2-1]
        let line = join(lline, '')
        call setline(line('.'), line)
      endif
    else
      let c2 = stridx(line, c, off+1 )
      if c2 >= 0
        unlet lline[c2]
        unlet lline[off]
        let line = join(lline, '')
        call setline(line('.'), line)
      endif
    endif

    return
  endif
  let cleanup = lh#on#exit()
        \.restore('&matchpairs')
  try
    call filter(crt_pairs, 'v:val[0] != v:val[1]')
    exe 'set matchpairs='.join(map(copy(crt_pairs), 'join(v:val,":")'),',')
    let openings = map(copy(crt_pairs), 'v:val[0]')
    let closings = map(copy(crt_pairs), 'v:val[1]')
    if     index(openings, c) >= 0 | normal! %x``x
    elseif index(closings, c) >= 0 | normal! %%x``x``
    endif
  finally
    call cleanup.finalize()
  endtry
endfunction

" Function: lh#brackets#_toggle_backslash() {{{2
" TODO: support identical characters for opening/closing
function! lh#brackets#_toggle_backslash() abort
  let b = getline(line("."))[col(".") - 2]
  let c = getline(line("."))[col(".") - 1]
  let cleanup = lh#on#exit()
        \.restore('&matchpairs')
  try
    let crt_pairs = filter(s:GetAllPairs(), '(strlen(v:val[0]) == 1) && (v:val[0] != v:val[1])')
    exe 'set matchpairs='.join(map(copy(crt_pairs), 'join(v:val,":")'),',')
    if b == '\'
      if     c =~ '[[({<$]' | normal! %X``X
      elseif c =~ '[\])}>$]' | normal! %%X``X%
      endif
    else
      if     c =~ '[[({<$]' | exe "normal! %i\\\<esc>``i\\\<esc>l"
      elseif c =~ '[\])}>$]' | exe "normal! %%i\\\<esc>``i\\\<esc>%"
      endif
    endif
  finally
    call cleanup.finalize()
  endtry
endfunction

" Function: lh#brackets#_change_to(open_close) {{{2
function! lh#brackets#_change_to(open_close) abort
  let crt_pairs = filter(s:GetAllPairs(), 'strlen(v:val[0]) == 1')
  let iso_pairs = map(filter(copy(crt_pairs), 'v:val[0] == v:val[1]'), 'v:val[0]')
  let line = getline(line("."))
  let off = col(".") - 1
  let c = line[off]
  " matchpairs only accept different pair characters
  if index(iso_pairs, c) >= 0
    " let's suppose everything is on the same line
    " let's ignore vim comments
    " let's ignore embedded stuff like "'"

    " need to detect to which pair the character belongs to
    let m = len(lh#string#matches(line[:off], c))
    let lline = split(line, '\zs')
    if m % 2 == 0
      let c2 = matchend(line[:off-1], '.*'.c)
      if c2 >= 0
        let lline[c2-1] = a:open_close[0]
        let lline[off]  = a:open_close[1]
        let line = join(lline, '')
        call setline(line('.'), line)
      endif
    else
      let c2 = stridx(line, c, off+1 )
      if c2 >= 0
        let lline[c2] = a:open_close[1]
        let lline[off]  = a:open_close[0]
        let line = join(lline, '')
        call setline(line('.'), line)
      endif
    endif

    return
  endif
  let cleanup = lh#on#exit()
        \.restore('&matchpairs')
  try
    call filter(crt_pairs, 'v:val[0] != v:val[1]')
    exe 'set matchpairs='.join(map(copy(crt_pairs), 'join(v:val,":")'),',')
    let openings = map(copy(crt_pairs), 'v:val[0]')
    let closings = map(copy(crt_pairs), 'v:val[1]')
    if     index(openings, c) >= 0 | exe 'normal! %r'.(a:open_close[1]).'``r'.(a:open_close[0])
    elseif index(closings, c) >= 0 | exe 'normal! %%r'.(a:open_close[1]).'``r'.(a:open_close[0])
    endif
  finally
    call cleanup.finalize()
  endtry
endfunction

" Function: lh#brackets#_manip_mode(starting_key) {{{3
function! lh#brackets#_manip_mode(starting_key) abort
  let crt_pairs    = filter(s:GetAllPairs(), 'strlen(v:val[0]) == 1')
  let openings     = map(copy(crt_pairs), 'v:val[0]')
  let openings_str = join(openings, '')
  let msg          = "\r-- brackets manipulation mode (x ".join(openings, ' ')." \\ <F1> q)"
  redraw! " clear the msg line
  while 1
    echohl StatusLineNC
    echo msg
    echohl None
    let key = getchar()
    let bracketsManip=nr2char(key)
    if (-1 != stridx("x".openings_str."\\q",bracketsManip)) ||
          \ (key =~ "\\(\<F1>\\|\<Del>\\)")
      if     bracketsManip == "x"      || key == "\<Del>"
        call lh#brackets#_delete_brackets() | redraw! | return ''
      elseif bracketsManip == "\\"          | call lh#brackets#_toggle_backslash()
      elseif stridx(openings_str, bracketsManip) >= 0
        let idx = stridx(openings_str, bracketsManip)
        call s:Verbose('Changing to #%1: %2', idx, openings[idx])
        call lh#brackets#_change_to(crt_pairs[idx])
        redraw!
        return
      elseif key == "\<F1>"
        redraw! " clear the msg line
        echo "\r *x* -- delete the current brackets pair\n"
        echo " *(* -- change the current brackets pair to round brackets ()\n"
        echo " *[* -- change the current brackets pair to square brackets []\n"
        echo " *{* -- change the current brackets pair to curly brackets {}\n"
        echo " *<* -- change the current brackets pair to angle brackets <>\n"
        echo " *'* -- change the current brackets pair to single quotes ''\n"
        echo " *\"* -- change the current brackets pair to double quotes \"\"\n"
        echo " *`* -- change the current brackets pair to back quotes ''\n"
        echo " *\\* -- toggle a backslash before the current brackets pair\n"
        echo " *q* -- quit the mode\n"
        continue
      elseif bracketsManip == "q"
        redraw! " clear the msg line
        return ''
        " else
      endif
      redraw! " clear the msg line
    else
      redraw! " clear the msg line
      return a:starting_key.bracketsManip
    endif
  endwhile
endfunction

"------------------------------------------------------------------------
" }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
