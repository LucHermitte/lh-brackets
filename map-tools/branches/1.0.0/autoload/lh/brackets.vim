"=============================================================================
" $Id$
" File:         map-tools::lh#brackets.vim                             {{{1
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
" TODO:         
" * Update doc
" * :Brackets -list to know all the brackets definitions
" * :Brackets -clear to remove brackets definitions
" * -context= option
" * Move brackets manipulation functions in this autoload plugin
" * -surround=function('xxx') option
" * Try to use it to insert stuff like "while() {}" ?
" }}}1
"=============================================================================

let s:cpo_save=&cpo
set cpo&vim


"# Options {{{1
" Defines the surrounding mappings:
" - for both VISUAL and select mode -> "v"
" - for both VISUAL mode only -> "x"
" NB: can be defined in the .vimrc only
" todo: find people using the select mode and never the visual mode
let s:k_vmap_type = lh#option#Get('bracket_surround_in', 'x', 'g')

"------------------------------------------------------------------------
"# Mappings Toggling {{{1
"
"# Globals {{{2
if !exists('s:definitions') || exists('brackets_clear_definitions')
  let s:definitions = {}
endif

let s:active = 1

"# Functions {{{2

" Function: Fetch the brackets defined for the current buffer. {{{3
function! s:GetDefinitions()
  let bid = bufnr('%')
  if !has_key(s:definitions, bid)
    let s:definitions[bid] = []
  endif
  let crt_definitions = s:definitions[bid]
  return crt_definitions
endfunction

" Function: Main function called to toogle bracket mappings. {{{3
function! lh#brackets#Toggle()
  " todo: when entering a buffer, update the mappings depending on whether it
  " has been toggled
  let crt_definitions = s:GetDefinitions()
  if s:active
    for m in crt_definitions
      call s:UnMap(m)
    endfor
    call lh#common#WarningMsg("Brakets mappings deactivated")
  else
    for m in crt_definitions
      call s:Map(m)
    endfor
    call lh#common#WarningMsg("Brakets mappings (re)activated")
  endif
  let s:active = 1 - s:active
endfunction

"# Mappings {{{2
"todo: move it to common_brackets.vim
nnoremap <silent> <F9> :call lh#brackets#Toggle()<cr>

"------------------------------------------------------------------------

"# Brackets definition functions {{{1
"------------------------------------------------------------------------

function! s:UnMap(m)
  let cmd = a:m.mode[0].'unmap <buffer> '.a:m.trigger
  if &verbose >= 1 | echomsg cmd | endif
  exe cmd
endfunction

function! s:Map(m)
  let cmd = a:m.mode.'map <buffer> <silent> '.a:m.trigger.' '.a:m.action
  if &verbose >= 1 | echomsg cmd | endif
  exe cmd
endfunction

function! s:DefineMap(mode, trigger, action)
  let crt_definitions = s:GetDefinitions()
  let crt_mapping = {}
  let crt_mapping.trigger = a:trigger
  let crt_mapping.mode    = a:mode
  let crt_mapping.action  = a:action
  if s:active
    call s:Map(crt_mapping)
  endif
  let p = lh#list#Find_if(crt_definitions,
        \ 'v:val.mode==v:1_.mode && v:val.trigger==v:1_.trigger',
        \ [crt_mapping])
  if p == -1
    call add(crt_definitions, crt_mapping)
  else
    if crt_mapping.action != a:action
      call lh#common#WarningMsg( "Overrriding ".a:mode."map ".a:trigger." ".crt_definitions[p].action."  with ".a:action)
    elseif &verbose >= 2
      echomsg "(almost) Overrriding ".a:mode."map ".a:trigger." ".crt_definitions[p].action." with ".a:action
    endif
    let crt_definitions[p] = crt_mapping
  endif
endfunction

function! s:DefineImap(trigger, inserter)
  if exists('*IMAP')
    call IMAP(a:trigger,  "\<c-r>=".a:inserter."\<cr>", &ft)
  else
    call s:DefineMap('inore', a:trigger, " \<c-r>=".(a:inserter)."\<cr>")
  endif
endfunction

"------------------------------------------------------------------------
" NB: this function is made public because IMAPs.vim need it to not be private
" (s:)
function! lh#brackets#Opener(trigger, escapable, nl, Open, Close)
  if type(a:Open) == type(function('has'))
    let res = InsertSeq(a:trigger, a:Open())
    return res
  elseif has('*IMAP')
    return s:ImapBrackets(a:trigger)
  elseif a:escapable
    let e = ((getline('.')[col('.')-2] == '\') ? '\\' : "")
    " todo: support \%(\) with vim
    " let open = '\<c-v\>'.a:Open
    " let close = e.'\<c-v\>'.a:Close
    let open = a:Open
    let close = e.a:Close
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
function!lh#brackets#Closer(trigger, Action)
  if type(a:Action) == type(function('has'))
    return InsertSeq(a:trigger,a:Action())
  elseif has('*IMAP')
    return s:ImapBrackets(a:trigger)
  else
    return s:JumpOrClose(a:trigger)
  endif
endfunction

"------------------------------------------------------------------------
function! s:JumpOrClose(trigger)
  if lh#option#Get('cb_jump_on_close',1) && lh#position#CharAtMark('.') == a:trigger
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

"------------------------------------------------------------------------
"------------------------------------------------------------------------
"------------------------------------------------------------------------
"------------------------------------------------------------------------
function! lh#brackets#Define(...)
  let nl = ''
  let insert = 1
  let visual = 1
  let normal = 'default=1'
  let options = []
  for p in a:000
    if     p =~ '-nl\|-ne\%[wline]' | let nl        = '\n'
    elseif p =~ '-e\%[scapable]'    | let escapable = 1
    elseif p =~ '-t\%[rigger]'      | let trigger   = matchstr(p, '-t\%[rigger]=\zs.*')
    elseif p =~ '-i\%[nsert]'       | let insert    = matchstr(p, '-i\%[nsert]=\zs.*')
    elseif p =~ '-v\%[isual]'       | let visual    = matchstr(p, '-v\%[isual]=\zs.*')
    elseif p =~ '-no\%[rmal]'       | let normal    = matchstr(p, '-n\%[ormal]=\zs.*')
    elseif p =~ '-o\%[open]'     
      let open = matchstr(p, '-o\%[pen]=\zs.*')
      if open =~ "^function"
        exe 'let Open =' . open
      else
        let Open = open
      endif
      " let Open = open =~ "^function" ? {open} : open   ## don't work with function()
    elseif p =~ '-c\%[lose]'     
      let close = matchstr(p, '-c\%[lose]=\zs.*')
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
    throw ":Brackets: incorrect numner of arguments"
  endif
  
  if !exists('trigger') | let trigger = options[0] | endif
  if !exists('Open')    | let Open    = options[0] | endif
  if !exists('Close')   | let Close   = options[1] | endif

  " INSERT-mode open
  if insert
    let inserter = "lh#brackets#Opener(".string(trigger).','. exists('escapable').','.string(nl).
          \','. string(Open).','.string(Close).")"
    call s:DefineImap(trigger, inserter )
    " INSERT-mode close
    if options[0] != options[1]
      let inserter = "lh#brackets#Closer(".string(options[1]).','.string (Close). ")"
      call s:DefineImap(options[1], inserter)
    endif
  endif

  " VISUAL-mode surrounding
  if visual
    if strlen(nl) > 0
      let action = ' <c-\><c-n>@=Surround('.
            \ string(options[0].'!cursorhere!').', '.
            \ string(options[1].'!mark!').", 1, 1, '', 1, ".string(trigger).")\<cr>"
    else
      let action = ' <c-\><c-n>@=Surround('.
            \ string(options[0]).', '.string(options[1]).", 0, 0, '`>ll', 1)\<cr>"
    endif
    call s:DefineMap(s:k_vmap_type.'nore', trigger, action)

    if type(normal)==type('string') && normal=="default=1"
      let normal = 1
    endif
  elseif type(normal)==type('string') && normal=="default=1"
    let normal = 0
  endif

  " NORMAL-mode surrounding
  if type(normal)==type(1) && normal == 1
    let normal = strlen(nl)>0 ? 'V' : 'viw'
  endif
  if type(normal)!=type(0) || normal != 0
    call s:DefineMap('n', trigger, normal.trigger)
  endif
endfunction

" }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
