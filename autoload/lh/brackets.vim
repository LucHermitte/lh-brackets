"=============================================================================
" File:         map-tools::lh#brackets.vim                             {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"               <URL:http://github.com/LucHermitte/lh-brackets>
" License:      GPLv3 with exceptions
"               <URL:http://github.com/LucHermitte/lh-brackets/tree/master/License.md>
" Version:      3.4.2
" Created:      28th Feb 2008
" Last Update:  28th Mar 2018
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

" Function: lh#brackets#usemarks() {{{2
function! lh#brackets#usemarks() abort
  return lh#option#get('usemarks', 1)
endfunction

"------------------------------------------------------------------------
" ## Mappings Toggling {{{1
"
"# Globals {{{2
"# Definitions {{{3
if !exists('s:definitions') || exists('brackets_clear_definitions')
  let s:definitions = {}
  let s:pairs       = {}
endif

"# Activation State {{{3
" let s:active = 1
let s:state = {
      \ 'isActive': 1,
      \ 'isActiveInBuffer': {},
      \}

function! s:state.toggle() dict abort
  let self.isActive = 1 - self.isActive
  let bid = bufnr('%')
  let self.isActiveInBuffer[bid] = self.isActive
endfunction

function! s:state.mustActivate() dict abort
  let bid = bufnr('%')
  if has_key(self.isActiveInBuffer, bid)
    let must = !self.isActiveInBuffer[bid]
    let why = must." <= has key, global=". (self.isActive) . ", local=".self.isActiveInBuffer[bid]
  else " first time in the buffer
    " throw "lh#Brackets#mustActivate() assertion failed: unknown local activation state"
    let must = 0
    let why = must." <= has not key, global=". (self.isActive)
  endif
  let self.isActiveInBuffer[bid] = self.isActive
  " echomsg "mustActivate[".bid."]: ".why
  return must
endfunction

function! s:state.mustDeactivate() dict abort
  let bid = bufnr('%')
  if has_key(self.isActiveInBuffer, bid)
    let must = self.isActiveInBuffer[bid]
    let why = must." <= has key, global=". (self.isActive) . ", local=".self.isActiveInBuffer[bid]
  else " first time in the buffer
    " throw "lh#Brackets#mustDeactivate() assertion failed: unknown local activation state"
    let must = 0
    let why = must." <= has not key, global=". (self.isActive)
  endif
  let self.isActiveInBuffer[bid] = self.isActive
  " echomsg "mustDeactivate[".bid."]: ".why
  return must
endfunction

"# Functions {{{2

" Function: s:GetDefinitions(isLocal) {{{3
" Fetch the brackets defined for the current buffer.
function! s:GetDefinitions(isLocal) abort
  let bid = a:isLocal ? bufnr('%') : -1
  if !has_key(s:definitions, bid)
    let s:definitions[bid] = []
  endif
  let crt_definitions = s:definitions[bid]
  return crt_definitions
endfunction

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

" Function: s:AddPair(isLocal, open, close) {{{3
function! s:AddPair(isLocal, open, close) abort
  let crt_pairs = s:GetPairs(a:isLocal)
  let new_pair = [a:open, a:close]
  call lh#list#push_if_new(crt_pairs, new_pair)
endfunction


" Function: Main function called to toggle bracket mappings. {{{3
function! lh#brackets#toggle() abort
  " TODO: when entering a buffer, update the mappings depending on whether it
  " has been toggled
  if exists('*IMAP')
    let g:Imap_FreezeImap = 1 - s:state.isActive
  else
    let crt_definitions = s:GetDefinitions(0) + s:GetDefinitions(1)
    if s:state.isActive " active -> inactive
      for m in crt_definitions
        call s:UnMap(m)
      endfor
      call lh#common#warning_msg("Brackets mappings deactivated")
    else " inactive -> active
      for m in crt_definitions
        call s:Map(m)
      endfor
      call lh#common#warning_msg("Brackets mappings (re)activated")
    endif
  endif " No imaps.vim
  call s:state.toggle()
endfunction

" Function: Activate or deactivate the mappings in the current buffer. {{{3
function! s:UpdateMappingsActivationE() abort
  if s:state.isActive
    if s:state.mustActivate()
      let crt_definitions = s:GetDefinitions(1)
      for m in crt_definitions
        call s:Map(m)
      endfor
    endif " active && must activate
  else " not active
    let crt_definitions = s:GetDefinitions(1)
    if s:state.mustDeactivate()
    for m in crt_definitions
        call s:UnMap(m)
      endfor
    endif
  endif
endfunction

function! s:UpdateMappingsActivationL() abort
  let bid = bufnr('%')
  let s:state.isActiveInBuffer[bid] = s:state.isActive
  " echomsg "updateL[".bid."]: <- ". s:state.isActive
  " call confirm( "updateL[".bid."]: <- ". s:state.isActive, '&Ok', 1)
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

"# Autocommands {{{2
augroup LHBrackets
  au!
  au BufEnter * call s:UpdateMappingsActivationE()
  au BufLeave * call s:UpdateMappingsActivationL()
augroup END

"------------------------------------------------------------------------

" ## Brackets definition functions {{{1
"------------------------------------------------------------------------

" Function: lh#brackets#_string(s) {{{2
function! lh#brackets#_string(s)
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

" Function: s:UnMap(m) {{{2
" TODO: move to lh#mapping
function! s:UnMap(m) abort
  try
    let cmd = a:m.mode[0].'unmap '. a:m.buffer . a:m.trigger
    call s:Verbose(cmd)
    exe cmd
  catch /E31/
    call s:Verbose("%1: %2", v:exception, cmd)
  endtry
endfunction

" Function: s:Map(m) {{{2
" TODO: move to lh#mapping
function! s:Map(m) abort
  let cmd = a:m.mode.'map <silent> ' . a:m.expr . a:m.buffer . a:m.trigger .' '.a:m.action
  call s:Verbose(cmd)
  exe cmd
endfunction

" Function: s:DefineMap(mode, trigger, action, isLocal, isExpr) {{{2
function! s:DefineMap(mode, trigger, action, isLocal, isExpr) abort
  let crt_definitions = s:GetDefinitions(a:isLocal)
  let crt_mapping = {}
  let crt_mapping.trigger = escape(a:trigger, '|') " need to escape bar
  let crt_mapping.mode    = a:mode
  let crt_mapping.action  = a:action
  let crt_mapping.buffer  = a:isLocal ? '<buffer> ' : ''
  let crt_mapping.expr    = a:isExpr  ? '<expr> '   : ''
  if s:state.isActive
    call s:Map(crt_mapping)
  endif
  let p = lh#list#Find_if(crt_definitions,
        \ 'v:val.mode==v:1_.mode && v:val.trigger==v:1_.trigger',
        \ [crt_mapping])
  if p == -1
    call add(crt_definitions, crt_mapping)
  else
    if crt_mapping.action != a:action
      call lh#common#warning_msg( "Overrriding ".a:mode."map ".a:trigger." ".crt_definitions[p].action."  with ".a:action)
    elseif &verbose >= 2
      call s:Log("(almost) Overrriding ".a:mode."map ".a:trigger." ".crt_definitions[p].action." with ".a:action)
    endif
    let crt_definitions[p] = crt_mapping
  endif
endfunction

" Function: s:DefineImap(trigger, inserter, isLocal) {{{2
function! s:DefineImap(trigger, inserter, isLocal) abort
  if exists('*IMAP') && a:trigger !~? '<bs>\|<cr>\|<up>\|<down>\|<left>\|<right>'
    if a:isLocal
      call IMAP(a:trigger,  "\<c-r>=".a:inserter."\<cr>", &ft)
    else
      call IMAP(a:trigger,  "\<c-r>=".a:inserter."\<cr>", '')
    endif
  else
    " call s:DefineMap('inore', a:trigger, " \<c-r>=".(a:inserter)."\<cr>", a:isLocal)
    call s:DefineMap('inore', a:trigger, (a:inserter), a:isLocal, 1)
  endif
endfunction

" Function: s:ListMappings(isLocal) {{{2
function! s:ListMappings(isLocal) abort
  let crt_definitions = s:GetDefinitions(a:isLocal)
  for m in crt_definitions
    let cmd = m.mode.'map <silent> ' . m.buffer . m.trigger .' '.m.action
    echomsg cmd
  endfor
endfunction

" Function: s:ClearMappings(isLocal) {{{2
function! s:ClearMappings(isLocal) abort
  let crt_definitions = s:GetDefinitions(a:isLocal)
  if s:state.isActive
    for m in crt_definitions
      call s:UnMap(m)
    endfor
  endif
  unlet crt_definitions[:]
endfunction

"------------------------------------------------------------------------
" Function: s:thereIsAnException(Ft_exceptions) {{{2
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
" Function: lh#brackets#opener(trigger, escapable, nl, Open, Close, areSameTriggers,Ft_exception [,context]) {{{2
" NB: this function is made public because IMAPs.vim need it to not be private
" (s:)
function! lh#brackets#opener(trigger, escapable, nl, Open, Close, areSameTriggers, Ft_exceptions, ...) abort
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
    " let close = e.'\<c-v\>'.a:Close
    let open = a:Open
    let close = e.a:Close
  elseif escaped
    return a:trigger
  elseif a:areSameTriggers && lh#option#get('cb_jump_on_close',1) && lh#position#char_at_mark('.') == a:trigger
    return s:Jump()
  else
    let open = a:Open
    let close = a:Close
  endif

  if ! empty(a:nl)
    " Cannot use the following generic line because &inckey does not always
    " work and !cursorhere! does not provokes a reindentation
    "  :return lh#map#insert_seq(a:trigger, a:Open.a:nl.'!cursorhere!'.a:nl.a:Close.'!mark!')
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
" Function: lh#brackets#closer(trigger, Action, Ft_exceptions) {{{2
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
" Function: s:JumpOrClose(trigger) {{{2
function! s:JumpOrClose(trigger) abort
  if lh#option#get('cb_jump_on_close',1) && lh#position#char_at_mark('.') == a:trigger
    " todo: detect even if there is a newline in between
    return s:Jump()
  else
    return a:trigger
  endif
endfunction

"------------------------------------------------------------------------
" Function: s:JumpOverAllClose(chars) {{{2
function! s:JumpOverAllClose(chars, ...) abort
  let chars = escape(a:chars, ']')
  let del_mark = ''
  let p = col('.')
  let ll = getline('.')[p : ] " ignore char under cursor, look after
  let m = matchstr(ll, '\v^(['.chars.']|'.lh#marker#very_magic('.{-}').')+')
  let len_match = lh#encoding#strlen(m)
  let nb_bytes_match = strlen(m)
  call s:Verbose("In ##%1##  %3 characters/%4 bytes match: ##%2##", ll, m, len_match, nb_bytes_match)
  if len_match
    let del_mark = repeat("\<del>", len_match)
    let del_mark .= substitute(m, '[^'.chars.']', '', 'g')
  endif
  " Is there an optional terminal mark to check and merge/add (like: «»;«») ?
  if a:0 > 0
    let nb_bytes_match = strlen(m)
    let remaining = ll[nb_bytes_match : ]
    call s:Verbose("rem: ##%1## VS %2", remaining, a:1)
    let match_rem = matchstr(remaining, '^\('.lh#marker#txt('.\{-}').'\)*'.a:1.'\('.lh#marker#txt('.\{-}').'\)*')
    let len_match_rem = lh#encoding#strlen(match_rem)
    if len_match_rem
      let del_mark = repeat("\<del>", len_match_rem).del_mark
    endif
    let del_mark .= a:1
  endif
  call s:Verbose("-> %1", strtrans(del_mark))

  return s:k_move_prefix."\<right>".del_mark
endfunction

"------------------------------------------------------------------------
" Function: lh#brackets#closing_chars() {{{3
function! lh#brackets#closing_chars() abort
  " TODO: compute from the mappings registered
  return ']})"'''
endfunction

"------------------------------------------------------------------------
" Function: lh#brackets#close_all_and_jump_to_last_on_line(chars, ...) {{{2
function! lh#brackets#close_all_and_jump_to_last_on_line(chars, ...) abort
  return call('s:JumpOverAllClose', [a:chars]+a:000)
endfunction

"------------------------------------------------------------------------
" Function: s:Jump() {{{2
function! s:Jump() abort
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
" Function: s:outer_blocks() {{{2
function! s:outer_blocks() abort
  let crt_pairs = copy(s:GetPairs(0))
  call extend(crt_pairs, s:GetPairs(1))
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
" Function: lh#brackets#jump_outside(param) {{{2
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
" Function: s:ImapBrackets(obrkt, cbrkt, esc, nl)  {{{2
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
" Function: lh#brackets#_switch(trigger, cases) {{{2
function! lh#brackets#_switch_int(trigger, cases) abort
  call lh#notify#deprecated('lh#brackets#_switch_int', 'lh#mapping#_switch_int')
  return lh#mapping#_switch_int(a:trigger, a:cases)
endfunction

function! lh#brackets#_switch(trigger, cases) abort
  call lh#notify#deprecated('lh#brackets#_switch', 'lh#mapping#_switch')
  return lh#mapping#_switch(a:trigger, a:cases)
endfunction

" Function: lh#brackets#define_imap(trigger, cases, isLocal [,default=trigger]) {{{2
" TODO: see how it can be move in lh#mapping
function! lh#brackets#define_imap(trigger, cases, isLocal, ...) abort
  " - Some keys, like '<bs>', cannot be used to code the default.
  " - Double "string(" because those chars are correctly interpreted with
  " lh#mapping#reinterpret_escaped_char(eval()), which requires nested strings...
  let default = (a:0>0) ? (a:1) : (a:trigger)
  let sCases='lh#mapping#_switch('.string(string(default)).', '.string(a:cases).')'
  call s:DefineImap(a:trigger, sCases, a:isLocal)
endfunction

" Function: lh#brackets#enrich_imap(trigger, case, isLocal [,default=trigger]) {{{2
" TODO: see how it can be move in lh#mapping
function! lh#brackets#enrich_imap(trigger, case, isLocal, ...) abort
  " - Some keys, like '<bs>', cannot be used to code the default.
  " - Double "string(" because those chars are correctly interpreted with
  " lh#mapping#reinterpret_escaped_char(eval()), which requires nested strings...
  if a:0 == 0
    let previous = maparg(a:trigger, 'i', 0, 1)
    if !empty(previous) && previous.expr
      " If not an expression, I do know yet how to forward a non expr mapping
      " from an expr mapping definition
      let default = lh#mapping#_build_rhs(previous)
    else
      let default = string(a:trigger)
    endif
  else
    let default = string(a:1)
  endif
  let sCase='lh#mapping#_switch('.string(default).', '.string([a:case]).')'
  call s:DefineImap(a:trigger, sCase, a:isLocal)
endfunction
"------------------------------------------------------------------------
" Function: s:DecodeDefineOptions(isLocal, a000)   {{{2
function! s:DecodeDefineOptions(isLocal, a000)
  let nl         = ''
  let insert     = 1
  let visual     = 1
  let normal     = 'default=1'
  let escapable  = 0
  let context    = {}
  let options    = []
  for p in a:a000
    if     p =~ '-l\%[list]'        | call s:ListMappings(a:isLocal)  | return []
    elseif p =~ '-cle\%[ar]'        | call s:ClearMappings(a:isLocal) | return []
    elseif p =~ '-nl\|-ne\%[wline]' | let nl        = '\n'
    elseif p =~ '-e\%[scapable]'    | let escapable = 1
    elseif p =~ '-t\%[rigger]'      | let trigger   = matchstr(p, '-t\%[rigger]=\zs.*')
    elseif p =~ '-i\%[nsert]'       | let insert    = matchstr(p, '-i\%[nsert]=\zs.*')
    elseif p =~ '-v\%[isual]'       | let visual    = matchstr(p, '-v\%[isual]=\zs.*')
    elseif p =~ '-no\%[rmal]'       | let normal    = matchstr(p, '-n\%[ormal]=\zs.*')
    elseif p =~ '-co\%[ntext]='     | let context   = {'is'   : matchstr(p, '-co\%[ntext]=\zs.*')}
    elseif p =~ '-co\%[ntext]!='    | let context   = {"isn't": matchstr(p, '-co\%[ntext]!=\zs.*')}
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

  if !exists('trigger')      | let trigger    = options[0] | endif
  if !exists('l:Open')       | let l:Open       = options[0] | endif
  if !exists('l:Close')      | let l:Close      = options[1] | endif
  if !exists('l:Exceptions') | let l:Exceptions = ''         | endif

  return [nl, insert, visual, normal, options, trigger, l:Open, l:Close, l:Exceptions, escapable, context]
endfunction

" Function: lh#brackets#define(bang, ...) {{{2
function! lh#brackets#define(bang, ...) abort
  " Parse Options {{{3
  let isLocal    = a:bang != "!"
  let res = s:DecodeDefineOptions(isLocal, a:000)
  if empty(res) | return | endif
  let [nl, insert, visual, normal, options, trigger, l:Open, l:Close, l:Exceptions, escapable, context]
        \ = res

  if type(l:Open) != type(function('has')) &&  type(l:Close) != type(function('has'))
    call s:AddPair(isLocal, l:Open, l:Close)
    if escapable
      call s:AddPair(isLocal, '\\'.l:Open, '\\'.l:Close)
    endif
  endif

  " INSERT-mode open {{{3
  if insert
    " INSERT-mode close
    let areSameTriggers = options[0] == options[1]
    let map_ctx = empty(context) ? '' : ','.string(context)
    let inserter = 'lh#brackets#opener('.lh#brackets#_string(trigger).','. escapable.',"'.(nl).
          \'",'. lh#brackets#_string(l:Open).','.lh#brackets#_string(l:Close).','.string(areSameTriggers).','.string(l:Exceptions).map_ctx.')'
    call s:DefineImap(trigger, inserter, isLocal)
    if ! areSameTriggers
      let inserter = 'lh#brackets#closer('.lh#brackets#_string(options[1]).','.lh#brackets#_string (l:Close).','.lh#brackets#_string(l:Exceptions).map_ctx.')'
      call s:DefineImap(options[1], inserter, isLocal)
      if len(options[1])
        " TODO: enrich <bs> & <del> imaps for the close triggers
      endif
    endif
  endif

  " VISUAL-mode surrounding {{{3
  if visual
    if strlen(nl) > 0
      let action = ' <c-\><c-n>@=lh#map#surround('.
            \ lh#brackets#_string(options[0].'!cursorhere!').', '.
            \ lh#brackets#_string(options[1].'!mark!').", 1, 1, '', 1, ".lh#brackets#_string(trigger).")\<cr>"
    else
      let action = ' <c-\><c-n>@=lh#map#surround('.
            \ lh#brackets#_string(options[0]).', '.lh#brackets#_string(options[1]).", 0, 0, '`>ll', 1)\<cr>"
    endif
    call s:DefineMap(s:k_vmap_type.'nore', trigger, action, isLocal, 0)

    if type(normal)==type('string') && normal=="default=1"
      let normal = 1
    endif
  elseif type(normal)==type('string') && normal=="default=1"
    let normal = 0
  endif

  " NORMAL-mode surrounding {{{3
  if type(normal)==type(1) && normal == 1
    let normal = strlen(nl)>0 ? 'V' : 'viw'
  endif
  if type(normal)!=type(0) || normal != 0
    call s:DefineMap('n', trigger, normal.escape(trigger, '|'), isLocal, 0)
  endif
endfunction

"------------------------------------------------------------------------
" Function: lh#brackets#_match_any_bracket_pair() {{{2
function! lh#brackets#_match_any_bracket_pair() abort
  let crt_pairs = copy(s:GetPairs(0))
  call extend(crt_pairs, s:GetPairs(1))
  " let regex = '\V\('.join(map(copy(crt_pairs), 'escape(join(v:val,"\\%'.col('.').'c"), "\\")'), '\|').'\)'
  let regex = '\V\('.join(map(crt_pairs, 'join(v:val,"\\%'.col('.').'c")'), '\|').'\)'
  return getline(".")=~ regex
endfunction

"------------------------------------------------------------------------
" Function: lh#brackets#_delete_empty_bracket_pair() {{{2
function! lh#brackets#_delete_empty_bracket_pair() abort
  let crt_pairs = copy(s:GetPairs(0))
  call extend(crt_pairs, s:GetPairs(1))
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
" Function: lh#brackets#_add_newline_between_brackets() {{{2
" TODO: make this action redoable
function! lh#brackets#_add_newline_between_brackets() abort
  return "\<cr>\<esc>O"
endfunction

" Function: lh#brackets#_jump_text(marker) {{{2
function! lh#brackets#_jump_text(marker) abort
  let m = matchstr(a:marker, '^'.lh#marker#txt('.\{-}'))
  let l = lh#encoding#strlen(m)
  return repeat("\<del>", l)
endfunction
"
"------------------------------------------------------------------------
" Function: lh#brackets#_split_line(line, c, tw) {{{2
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

" }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
