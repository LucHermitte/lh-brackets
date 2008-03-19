"=============================================================================
" $Id$
" File:         map-tools#brackets.vim                                 {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"               <URL:http://hermitte.free.fr/vim/>
" Version:      1.0.0
" Created:      28th Feb 2008
" Last Update:  $Date$
"------------------------------------------------------------------------
" Description:  «description»
" 
"------------------------------------------------------------------------
" Installation: «install details»
" History:      «history»
" TODO:         «missing features»
" }}}1
"=============================================================================

let s:cpo_save=&cpo
set cpo&vim

"------------------------------------------------------------------------
function! s:IsSet(what) " -> vim-lib (avec IsEmpty)
  if     type(a:what) == type(0)               | return a:what != 0
  elseif type(a:what) == type('string')        | return strlen(a:what) != 0
  elseif type(a:what) == type(function('has')) | return 1
  elseif type(a:what) == type({}) || type(a:what) == type([])
    return len(a:what) != 0
  else                                         | return 0
  endif
endfunction

"------------------------------------------------------------------------

function! s:DefineMappings(kind)
  if exists('b:cb_'.a:kind)
    let how = b:cb_{a:kind}
    if type(how) == type(1)
      " backward compatibility
      call s:DoDefine(a:kind, {'i':how, 'n':how, 'v':how}) 
    elseif type(how) == type('string')
      " backward compatibility
      call s:DoDefine(a:kind, {'i':how, 'n':1, 'v':1}) 
    elseif type(how) == type({})
      call s:DoDefine(a:kind, how)
    endif
  endif
endfunction
"------------------------------------------------------------------------
function! s:DoDefineInsertOpen(kind, Open)
  if s:IsSet(a:Open)
    if type(a:kind) == type({})
      let trigger = string({a:kind}.open)
    else
      let trigger = string(a:kind)
    endif
    let inserter = "<sid>Opener(".trigger.','.string (a:Open). ")"
    echomsg inserter
    call s:DoMap(trigger, inserter)
  endif
endfunction

function! s:DoDefine(kind, modes)
  " I- Insert mode mappings
  if has_key(a:modes, 'i')
    " 1- determine if we need open and/or close mappings
    let Choice = a:modes.i
    if type(Choice) == type(0)
      let Open  = Choice
      let Close = Choice
    elseif type(Choice) == type('string')
      let Open  = Choice
      let Close = 1
    elseif type(Choice) == type({})
      let Open  = Choice.open
      let Close = Choice.close
    elseif type(Choice) == type([])
      let Open  = Choice[0]
      let Close = Choice[1]
    else
      throw "lh#bracket: unexpected type (".type(Choice).') for '.a:kind.' brackets.'
    endif

    " 2- define everything
    let kind = 's:kind_'.a:kind
    " if s:IsSet(Open)
      " let inserter = "<sid>Opener(".string({kind}.open).','.string (Open). ")"
      " call s:DoMap({kind}.open, inserter)
    " endif
    if type(Open) == type({})
      for [trigger,Op] in items(Open)
        call s:DoDefineInsertOpen(trigger, Op)
      endfor
    else
      call s:DoDefineInsertOpen(kind, Open)
    endif

    if s:IsSet(Close)
      " let inserter = s:Closer({kind}.close, Close)
      let inserter = "<sid>Closer(".string({kind}.close).','.string (Close). ")"
      call s:DoMap({kind}.close, inserter)
    endif
  endif " End: Insert mode
endfunction

function! s:DoMap(trigger, inserter)
  if exists('*IMAP')
    call IMAP(a:trigger,  "\<c-r>=".a:inserter."()\<cr>", &ft)
  else
    echomsg 'inoremap <buffer> '.a:trigger.' <c-r>='.a:inserter.'<cr>'
    exe 'inoremap <buffer> '.a:trigger." \<c-r>=".(a:inserter)."\<cr>"
  endif
endfunction


function! s:Opener(trigger, Action)
  if type(a:Action) == type(function('has'))
    " return "InsertSeq(".a:trigger.",".string(a:Action).")"
    return InsertSeq(a:trigger,a:Action())
  elseif has('*IMAP')
    return s:ImapBrackets(a:trigger)
  elseif a:Action == '\'
    echomsg "esc"
    " return "\<c-r>=".s:EscapableBrackets0(a:trigger, '\<c-v\>'.a:trigger,  '\<c-v\>'.s:close[a:trigger])."\<cr>"
    return s:EscapableBrackets2(a:trigger, '\<c-v\>'.a:trigger,  '\<c-v\>'.s:close[a:trigger])
  elseif a:Action == "\n"
    echomsg "nl"
    return Smart_insert_seq1(a:trigger,
          \ a:trigger.'\<cr\>'.s:close[a:trigger].'\<esc\>O',
          \ a:trigger.'\<cr\>'.s:close[a:trigger].Marker_Txt().'\<esc\>O')
  else
    echomsg "smart"
    return Smart_insert_seq1(a:trigger,
          \ a:trigger.s:close[a:trigger].'\<esc\>i',
          \ a:trigger.s:close[a:trigger].Marker_Txt().'\<esc\>F'.a:trigger.'a')
  endif
endfunction

function! s:Closer(trigger, Action)
  if type(a:Action) == type(function('has'))
    return InsertSeq(a:trigger,a:Action())
  elseif has('*IMAP')
    return s:ImapBrackets(a:trigger)
  else
    return s:JumpOrClose(a:trigger)
  endif
endfunction

function! s:JumpOrClose(trigger)
  if b:cb_jump_on_close && lh#position#CharAtMark('.') == a:trigger
    " todo: detect even if there is a newline in between
    return "\<right>"
  else
    return a:trigger
  endif
endfunction
"------------------------------------------------------------------------
" Function: s:ImapBrackets(obrkt, cbrkt, esc, nl)  {{{
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
endfunction "}}}
"------------------------------------------------------------------------
let s:kind_round = {
      \ 'open': '(', 'close': ')'
      \ }
let s:kind_square = {
      \ 'open': '[', 'close': ']'
      \ }
let s:kind_curly = {
      \ 'open': '{', 'close': '}'
      \ }
let s:kind_angle = {
      \ 'open': '<', 'close': '>'
      \ }
let s:inserters = {
      \ '<': 'Brkt_lt()'         , '>': 'gt',
      \ '[': 'square_open', ']': 'square_close'
      \ }
let s:close = {
      \ '[': ']' ,
      \ '(': ')' ,
      \ '{': '}' ,
      \ '<': '>' ,
      \ "'": "'" ,
      \ '"': '"' }

" s:EscapableBrackets, and s:EscapableBracketsLn are two different functions
" in order to acheive a little optimisation
function! s:EscapableBrackets0(key, left, right) " {{{
  let r = ((getline('.')[col('.')-2] == '\') ? '\\\\' : "") . a:right
  let expr1 = a:left.r.'\<esc\>i'
  let expr2 = a:left.r.'!mark!\<esc\>F'.a:key.'a'
  if exists('b:usemarks') && b:usemarks
    return "MapNoContext('".a:key."',BuildMapSeq('".expr2."'))"
  else
    return "MapNoContext('".a:key."', '".expr1."')"
  endif
endfunction " }}}

function! s:EscapableBrackets2(key, left, right) " {{{
  let r = ((getline('.')[col('.')-2] == '\') ? '\\' : "") . a:right
  let expr = InsertSeq(a:key, a:left.'!cursorhere!'.r.'!mark!')
  return expr
endfunction " }}}

function! s:EscapableBracketsLn(key, left, right) " {{{
  let r = ((getline('.')[col('.')-2] == '\') ? '\\\\' : "") . a:right
  let expr1 = a:left.'\<cr\>'.r.'\<esc\>O'
  let expr2 = a:left.'\<cr\>'.r.'!mark!\<esc\>O'
  if exists('b:usemarks') && b:usemarks
    return "MapNoContext('".a:key."',BuildMapSeq('".expr2."'))"
  else
    return "MapNoContext('".a:key."', '".expr1."')"
  endif
endfunction " }}}
"------------------------------------------------------------------------
"------------------------------------------------------------------------
"------------------------------------------------------------------------
"------------------------------------------------------------------------
function! s:DefineImap(trigger, inserter)
  if exists('*IMAP')
    call IMAP(a:trigger,  "\<c-r>=".a:inserter."()\<cr>", &ft)
  else
    echomsg 'inoremap <buffer> '.a:trigger.' <c-r>='.a:inserter.'<cr>'
    exe 'inoremap <buffer> '.a:trigger." \<c-r>=".(a:inserter)."\<cr>"
  endif
endfunction

function! s:Open(trigger, escapable, nl, Open, Close)
  if type(a:Open) == type(function('has'))
    return InsertSeq(a:trigger, a:Open())
  elseif has('*IMAP')
    return s:ImapBrackets(a:trigger)
  elseif a:escapable
    let e = ((getline('.')[col('.')-2] == '\') ? '\\' : "")
    " let open = '\<c-v\>'.a:Open
    " let close = e.'\<c-v\>'.a:Close
    let open = a:Open
    let close = e.a:Close
    " return s:EscapableBrackets2(a:trigger, open,  close)
  else
    let open = a:Open
    let close = a:Close
  endif

  if strlen(a:nl) > 0
    " cannot use the following because &cinkey does not always work and
    " !cursorhere! does not provokes a reindentation
    " return InsertSeq(a:trigger, a:Open.a:nl.'!cursorhere!'.a:nl.a:Close.'!mark!')
    return InsertSeq(a:trigger, open.a:nl.close.'!mark!\<esc\>O')
  else
    return InsertSeq(a:trigger, open.'!cursorhere!'.close.'!mark!')
endfunction

function! lh#brackets#Define(...)
  let nl = ''
  let insert = 1
  let visual = 1
  let options = []
  for p in a:000
    if     p =~ '-n\%[l]'        | let nl        = '\n'
    elseif p =~ '-e\%[scapable]' | let escapable = 1
    elseif p =~ '-t\%[rigger]'   | let trigger   = matchstr(p, '-t\%[rigger]=\zs.*')
    elseif p =~ '-i\%[nsert]'    | let insert    = matchstr(p, '-i\%[nsert]=\zs.*')
    elseif p =~ '-v\%[isual]'    | let visual    = matchstr(p, '-v\%[isual]=\zs.*')
    elseif p =~ '-o\%[open]'     
      let open = matchstr(p, '-o\%[pen]=\zs.*')
      if open =~ "^function"
        exe 'let Open =' . open
      else
        let Open = open
      endif
      " let Open = open =~ "^function" ? {open} : open   ## don't work with function()
    else 
      call add(options, p)
    endif
  endfor
  if len(options) != 2
    throw ":Brackets: incorrect numner of arguments"
  endif
  
  if !exists('trigger') | let trigger = options[0] | endif
  if !exists('Open')    | let Open    = options[0] | endif
  if !exists('Close')   | let Close   = options[1] | endif

  " INSERT-mode open
  if insert
    let inserter = "<sid>Open(".string(trigger).','. exists('escapable').','.string(nl).
          \','. string(Open).','.string(Close).")"
    call s:DefineImap(trigger, inserter )
    " INSERT-mode close
    if options[0] != options[1]
      let inserter = "<sid>Closer(".string(options[1]).','.string (Close). ")"
      call s:DoMap(options[1], inserter)
    endif
  endif

  " VISUAL-mode surrounding
  if visual
    if strlen(nl) > 0
      let cmd = 'vnoremap <buffer> '.trigger.' <c-\><c-n>@=Surround('.
            \ string(options[0].'!cursorhere!').', '.string(options[1].'!mark!').", 1, 1, '', 1, ".string(trigger).")\<cr>"
    else
      let cmd = 'vnoremap <buffer> '.trigger.' <c-\><c-n>@=Surround('.
            \ string(options[0]).', '.string(options[1]).", 0, 0, '`>ll', 0)\<cr>"
    endif
    echomsg cmd
    exe cmd
  endif

  " call s:DefineMappings('square')
  " call s:DefineMappings('angle')
  " call s:DefineMappings('curly')
  " call s:DefineMappings('round')
endfunction
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
