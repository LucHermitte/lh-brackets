"=============================================================================
" $Id$
" File:         map-tools::lh#brackets.vim                             {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"               <URL:http://code.google.com/p/lh-vim/>
" License:      GPLv3 with exceptions
"               <URL:http://code.google.com/p/lh-vim/wiki/License>
" Version:      2.1.2
" Created:      28th Feb 2008
" Last Update:  $Date$
"------------------------------------------------------------------------
" Description:  
" 		This autoload plugin defines the functions behind the command
" 		:Brackets that simplifies the definition of mappings that
" 		insert pairs of caracters when the first one is typed. Typical
" 		examples are the parenthesis, brackets, <,>, etc. 
" 		The definitions can be buffer-relative or global.
"
" 		This commands is used by different ftplugins:
" 		<vim_brackets.vim>, <c_brackets.vim> <ML_brackets.vim>,
" 		<html_brackets.vim>, <php_brackets.vim> and <tex_brackets.vim>
" 		-- available on my VIM web site.
"
" 		BTW, they can be activated or desactivated by pressing <F9>
" 
"------------------------------------------------------------------------
" Installation: 
" * vim7+ required
" * lh-vim-lib required
" * drop into {rtp}/autoload/lh/brackets.vim
"
" History:
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
" 		* Issue#10 refinements: use a stricter placeholder regex to not
" 		delete everything in ").Marker_Txt('.\{-}').'\)\+')"
" Version 1.0.0:
" 		* Vim 7 required!
" 		* New way to configure the desired brackets, the previous
" 		approach has been deprecated
" TODO:         
" * Update doc
" * Move brackets manipulation functions in this autoload plugin
" * -surround=function('xxx') option
" * Try to use it to insert stuff like "while() {}" ?
" }}}1
"=============================================================================

let s:cpo_save=&cpo
set cpo&vim

" ## Debug {{{1
function! lh#brackets#verbose(level)
  let s:verbose = a:level
endfunction

function! s:Verbose(expr)
  if exists('s:verbose') && s:verbose
    echomsg a:expr
  endif
endfunction

function! lh#brackets#debug(expr)
  return eval(a:expr)
endfunction


" ## Options {{{1
" Defines the surrounding mappings:
" - for both VISUAL and select mode -> "v"
" - for both VISUAL mode only -> "x"
" NB: can be defined in the .vimrc only
" todo: find people using the select mode and never the visual mode
let s:k_vmap_type = lh#option#get('bracket_surround_in', 'x', 'g')

"------------------------------------------------------------------------
" ## Mappings Toggling {{{1
"
"# Globals {{{2
"# Definitions {{{3
if !exists('s:definitions') || exists('brackets_clear_definitions')
  let s:definitions = {}
endif

"# Activation State {{{3
" let s:active = 1
let s:state = {
      \ 'isActive': 1,
      \ 'isActiveInBuffer': {},
      \}

function! s:state.toggle() dict
  let self.isActive = 1 - self.isActive
  let bid = bufnr('%')
  let self.isActiveInBuffer[bid] = self.isActive
endfunction

function! s:state.mustActivate() dict
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

function! s:state.mustDeactivate() dict
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

" Function: Fetch the brackets defined for the current buffer. {{{3
function! s:GetDefinitions(isLocal)
  let bid = a:isLocal ? bufnr('%') : -1
  if !has_key(s:definitions, bid)
    let s:definitions[bid] = []
  endif
  let crt_definitions = s:definitions[bid]
  return crt_definitions
endfunction

" Function: Main function called to toggle bracket mappings. {{{3
function! lh#brackets#toggle()
  " todo: when entering a buffer, update the mappings depending on whether it
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
function! s:UpdateMappingsActivationE()
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

function! s:UpdateMappingsActivationL()
  let bid = bufnr('%')
  let s:state.isActiveInBuffer[bid] = s:state.isActive
  " echomsg "updateL[".bid."]: <- ". s:state.isActive
  " call confirm( "updateL[".bid."]: <- ". s:state.isActive, '&Ok', 1)
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

" s:UnMap(m) {{{2
function! s:UnMap(m)
  let cmd = a:m.mode[0].'unmap '. a:m.buffer . a:m.trigger
  if &verbose >= 1 | echomsg cmd | endif
  exe cmd
endfunction

" s:Map(m) {{{2
function! s:Map(m)
  let cmd = a:m.mode.'map <silent> ' . a:m.buffer . a:m.trigger .' '.a:m.action
  if &verbose >= 1 | echomsg cmd | endif
  exe cmd
endfunction

" s:DefineMap(mode, trigger, action, isLocal) {{{2
function! s:DefineMap(mode, trigger, action, isLocal)
  let crt_definitions = s:GetDefinitions(a:isLocal)
  let crt_mapping = {}
  let crt_mapping.trigger = a:trigger
  let crt_mapping.mode    = a:mode
  let crt_mapping.action  = a:action
  let crt_mapping.buffer  = a:isLocal ? '<buffer> ' : ''
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
      echomsg "(almost) Overrriding ".a:mode."map ".a:trigger." ".crt_definitions[p].action." with ".a:action
    endif
    let crt_definitions[p] = crt_mapping
  endif
endfunction

" s:DefineImap(trigger, inserter, isLocal) {{{2
function! s:DefineImap(trigger, inserter, isLocal)
  if exists('*IMAP') && a:trigger !~? '<bs>\|<cr>\|<up>\|<down>\|<left>\|<right>' 
    if a:isLocal
      call IMAP(a:trigger,  "\<c-r>=".a:inserter."\<cr>", &ft)
    else
      call IMAP(a:trigger,  "\<c-r>=".a:inserter."\<cr>", '')
    endif
  else
    call s:DefineMap('inore', a:trigger, " \<c-r>=".(a:inserter)."\<cr>", a:isLocal)
  endif
endfunction

" s:ListMappings(isLocal) {{{2
function! s:ListMappings(isLocal)
  let crt_definitions = s:GetDefinitions(a:isLocal)
  for m in crt_definitions
    let cmd = m.mode.'map <silent> ' . m.buffer . m.trigger .' '.m.action
    echomsg cmd
  endfor
endfunction

" s:ClearMappings(isLocal) {{{2
function! s:ClearMappings(isLocal)
  let crt_definitions = s:GetDefinitions(a:isLocal)
  if s:state.isActive
    for m in crt_definitions
      call s:UnMap(m)
    endfor
  endif
  unlet crt_definitions[:]
endfunction

"------------------------------------------------------------------------
" s:thereIsAnException(Ft_exceptions) {{{2
function! s:thereIsAnException(Ft_exceptions)
  if empty(a:Ft_exceptions)
    return 0
  elseif type(a:Ft_exceptions) == type(function('has'))
    return a:Ft_exceptions()
  else
    return &ft =~ a:Ft_exceptions
  endif
endfunction

"------------------------------------------------------------------------
" lh#brackets#opener(trigger, escapable, nl, Open, Close, areSameTriggers,Ft_exceptions) {{{2
" NB: this function is made public because IMAPs.vim need it to not be private
" (s:)
function! lh#brackets#opener(trigger, escapable, nl, Open, Close, areSameTriggers, Ft_exceptions)
  if s:thereIsAnException(a:Ft_exceptions)
    return a:trigger
  endif
  let escaped = getline('.')[col('.')-2] == '\'
  if type(a:Open) == type(function('has'))
    let res = InsertSeq(a:trigger, a:Open())
    return res
  elseif has('*IMAP')
    return s:ImapBrackets(a:trigger)
  elseif a:escapable
    let e = (escaped ? '\\' : "")
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

  if strlen(a:nl) > 0
    " Cannot use the following generic line because &cinkey does not always
    " work and !cursorhere! does not provokes a reindentation
    "  :return InsertSeq(a:trigger, a:Open.a:nl.'!cursorhere!'.a:nl.a:Close.'!mark!')
    " hence the following solution
    return InsertSeq(a:trigger, open.a:nl.close.'!mark!\<esc\>O')
  else
    return InsertSeq(a:trigger, open.'!cursorhere!'.close.'!mark!')
endfunction

"------------------------------------------------------------------------
" lh#brackets#closer(trigger, Action, Ft_exceptions) {{{2
function! lh#brackets#closer(trigger, Action, Ft_exceptions)
  if s:thereIsAnException(a:Ft_exceptions)
    return a:trigger
  endif
  if type(a:Action) == type(function('has'))
    return InsertSeq(a:trigger,a:Action())
  elseif has('*IMAP')
    return s:ImapBrackets(a:trigger)
  else
    return s:JumpOrClose(a:trigger)
  endif
endfunction

"------------------------------------------------------------------------
" s:JumpOrClose(trigger) {{{2
function! s:JumpOrClose(trigger)
  if lh#option#get('cb_jump_on_close',1) && lh#position#char_at_mark('.') == a:trigger
    " todo: detect even if there is a newline in between
    return s:Jump()
  else
    return a:trigger
  endif
endfunction

"------------------------------------------------------------------------
" Function: s:JumpOverAllClose(chars) {{{2
function! s:JumpOverAllClose(chars, ...)
  let del_mark = ''
  let p = col('.')
  let ll = getline('.')[p : ] " ignore char under cursor, look after
  let m = matchstr(ll, '^\(['.a:chars.']\|'.Marker_Txt('.\{-}').'\)\+')
  echomsg ll.'##'.m.'##'
  let lm = strwidth(m)
  let len_match = strlen(m)
  if lm
    let del_mark = repeat("\<del>", lm)
    let del_mark .= substitute(m, '[^'.a:chars.']', '', 'g')
  endif
  " Is there an optional terminal mark to check and merge/add (like: «»;«») ?
  if a:0 > 0
    let remaining = ll[len_match : ]
    echomsg "rem: <<".remaining.">>"
    let match_rem = matchstr(remaining, '^\('.Marker_Txt('.\{-}').'\)*'.a:1.'\('.Marker_Txt('.\{-}').'\)*')
    let len_match_rem = strwidth(match_rem)
    if len_match_rem
      let del_mark = repeat("\<del>", len_match_rem).del_mark
    endif
    let del_mark .= a:1
  endif
  echomsg strtrans(del_mark)


  return "\<right>".del_mark
endfunction

"------------------------------------------------------------------------
" Function: s:Jump() {{{2
function! s:Jump()
  " todo: get rid of the marker as well
  let del_mark = ''
  let p = col('.')

  let ll = getline('.')[p : ]
  " echomsg ll
  let m = matchstr(ll, '^'.Marker_Txt('.\{-}'))
  let lm = strwidth(m)
  if lm
    let del_mark = repeat("\<del>", lm)
  endif
  return "\<right>".del_mark
endfunction

"------------------------------------------------------------------------
" Function: s:ImapBrackets(obrkt, cbrkt, esc, nl)  {{{2
" Internal function.
" {obrkt}:      open bracket
" {cbrkt}:      close bracket
" {esc}:        escaped version 0:none, 1:\, 2:\%
" {nm}:         new line between {obrkt} and {cbrkt}
function! s:ImapBrackets(obrkt, cbrkt, esc, nl) 
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
function! lh#brackets#_switch_int(trigger, cases)
  for c in a:cases
    if eval(c.condition)
      return eval(c.action)
    endif
  endfor
  return ReinterpretEscapedChar(eval(a:trigger))
endfunction

function! lh#brackets#_switch(trigger, cases)
  return lh#brackets#_switch_int(a:trigger, a:cases)
  " debug return lh#brackets#_switch_int(a:trigger, a:cases)
endfunction

" Function: lh#brackets#define_imap(trigger, cases, isLocal [,default=trigger]) {{{2
function! lh#brackets#define_imap(trigger, cases, isLocal, ...)
  " - Some keys, like '<bs>', cannot be used to code the default.
  " - Double "string(" because those chars are correctly interpreted with
  " ReinterpretEscapedChar(eval()), which requires nested strings...
  let default = (a:0>0) ? (a:1) : (a:trigger)
  let sCases='lh#brackets#_switch('.string(string(default)).', '.string(a:cases).')'
  call s:DefineImap(a:trigger, sCases, a:isLocal)
endfunction

" Function: lh#brackets#enrich_imap(trigger, case, isLocal [,default=trigger]) {{{2
function! lh#brackets#enrich_imap(trigger, case, isLocal, ...)
  " - Some keys, like '<bs>', cannot be used to code the default.
  " - Double "string(" because those chars are correctly interpreted with
  " ReinterpretEscapedChar(eval()), which requires nested strings...
  let default = (a:0>0) ? (a:1) : (a:trigger)
  let sCase='lh#brackets#_switch('.string(string(default)).', '.string([a:case]).')'
  call s:DefineImap(a:trigger, sCase, a:isLocal)
endfunction
"------------------------------------------------------------------------
" lh#brackets#define(bang, ...) {{{2
function! lh#brackets#define(bang, ...)
  " Parse Options {{{3
  let isLocal    = a:bang != "!"
  let nl         = ''
  let insert     = 1
  let visual     = 1
  let normal     = 'default=1'
  let options    = []
  for p in a:000
    if     p =~ '-l\%[list]'        | call s:ListMappings(isLocal)  | return
    elseif p =~ '-cle\%[ar]'        | call s:ClearMappings(isLocal) | return
    elseif p =~ '-nl\|-ne\%[wline]' | let nl        = '\n'
    elseif p =~ '-e\%[scapable]'    | let escapable = 1
    elseif p =~ '-t\%[rigger]'      | let trigger   = matchstr(p, '-t\%[rigger]=\zs.*')
    elseif p =~ '-i\%[nsert]'       | let insert    = matchstr(p, '-i\%[nsert]=\zs.*')
    elseif p =~ '-v\%[isual]'       | let visual    = matchstr(p, '-v\%[isual]=\zs.*')
    elseif p =~ '-no\%[rmal]'       | let normal    = matchstr(p, '-n\%[ormal]=\zs.*')
    elseif p =~ '-b\%[ut]'
      let exceptions= matchstr(p, '-b\%[ut]=\zs.*')
      if exceptions =~ "^function"
        exe 'let Exceptions='.exceptions
      else
        let Exceptions = exceptions
      endif
    elseif p =~ '-o\%[open]'     
      let open = matchstr(p, '-o\%[pen]=\zs.*')
      if open =~ "^function"
        exe 'let Open =' . open
      else
        let Open = open
      endif
      " let Open = open =~ "^function" ? {open} : open   ## don't work with function()
    elseif p =~ '-clo\%[se]'     
      let close = matchstr(p, '-clo\%[se]=\zs.*')
      if close =~ "^function"
        exe 'let Close =' . close
      else
        let Close = close
      endif
      " let Close = close =~ "^function" ? {close} : close   ## don't work with function()
    else 
      call add(options, p)
    endif
  endfor
  if len(options) != 2
    throw ":Brackets: incorrect number of arguments"
  endif
  
  if !exists('trigger')    | let trigger    = options[0] | endif
  if !exists('Open')       | let Open       = options[0] | endif
  if !exists('Close')      | let Close      = options[1] | endif
  if !exists('Exceptions') | let Exceptions = ''         | endif

  " INSERT-mode open {{{3
  if insert
    " INSERT-mode close
    let areSameTriggers = options[0] == options[1]
    let inserter = 'lh#brackets#opener('.string(trigger).','. exists('escapable').','.string(nl).
	  \','. string(Open).','.string(Close).','.string(areSameTriggers).','.string(Exceptions).')'
    call s:DefineImap(trigger, inserter, isLocal)
    if ! areSameTriggers
      let inserter = 'lh#brackets#closer('.string(options[1]).','.string (Close).','.string(Exceptions).')'
      call s:DefineImap(options[1], inserter, isLocal)
      if len(options[1])
        " TODO: enrich <bs> & <del> imaps for the close triggers
      endif
    endif
  endif

  " VISUAL-mode surrounding {{{3
  if visual
    if strlen(nl) > 0
      let action = ' <c-\><c-n>@=Surround('.
            \ string(options[0].'!cursorhere!').', '.
            \ string(options[1].'!mark!').", 1, 1, '', 1, ".string(trigger).")\<cr>"
    else
      let action = ' <c-\><c-n>@=Surround('.
            \ string(options[0]).', '.string(options[1]).", 0, 0, '`>ll', 1)\<cr>"
    endif
    call s:DefineMap(s:k_vmap_type.'nore', trigger, action, isLocal)

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
    call s:DefineMap('n', trigger, normal.trigger, isLocal)
  endif
endfunction

"------------------------------------------------------------------------
" Function: lh#brackets#_match_any_bracket_pair() {{{2
function! lh#brackets#_match_any_bracket_pair()
  return getline(".")[col(".")-2:]=~'^\(()\|{}\|\[]\|""\|''\)'
endfunction

"------------------------------------------------------------------------
" Function: lh#brackets#_delete_empty_bracket_pair() {{{2
function! lh#brackets#_delete_empty_bracket_pair()
  let l=getline('.')[col("."):]
  let m = matchstr(l, '^'.Marker_Txt('.\{-}'))
  let lm = lh#encoding#strlen(m)

  return "\<left>".repeat("\<del>", lm+2)
endfunction

"------------------------------------------------------------------------
" Function: lh#brackets#_add_newline_between_brackets() {{{2
function! lh#brackets#_add_newline_between_brackets()
  return "\<cr>\<esc>O"
endfunction

" Function: lh#brackets#_jump_text(marker) {{{3
function! lh#brackets#_jump_text(marker)
  let m = matchstr(a:marker, '^'.lh#marker#txt('.\{-}'))
  let l = lh#encoding#strlen(m)
  return repeat("\<del>", l)
endfunction
"
" }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
