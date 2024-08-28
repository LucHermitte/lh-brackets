"=============================================================================
" File:         map-tools::lh#marker.vim                            {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"               <URL:http://github.com/LucHermitte>
" License:      GPLv3 with exceptions
"               <URL:http://github.com/LucHermitte/lh-brackets/License.md>
" Version:      3.6.0
let s:k_version = 360
" Created:      27th Nov 2013
"------------------------------------------------------------------------
" Description:
"       Functions to generate and handle |markers|
"
"------------------------------------------------------------------------
" History:
" Version 2.0.2
"       * Moves Marker_txt() to lh#marker#txt()
" TODO:         «missing features»
" }}}1
"=============================================================================

let s:cpo_save=&cpo
set cpo&vim
"------------------------------------------------------------------------
" ## Misc Functions     {{{1
" # Version {{{2
function! lh#marker#version()
  return s:k_version
endfunction

" # Debug   {{{2
let s:verbose = get(s:, 'verbose', 0)
function! lh#marker#verbose(...)
  if a:0 > 0 | let s:verbose = a:1 | endif
  return s:verbose
endfunction

function! s:Log(expr, ...)
  call call('lh#log#this',[a:expr]+a:000)
endfunction

function! s:Verbose(expr, ...)
  if s:verbose
    call call('s:Log',[a:expr]+a:000)
  endif
endfunction

function! lh#marker#debug(expr) abort
  return eval(a:expr)
endfunction

"------------------------------------------------------------------------
" ## Exported functions {{{1

" Function: lh#marker#open() {{{2
function! lh#marker#open() abort
  " ::call s:Verbose('lh#marker#open()')
  if s:Option('use_place_holders', 0) && exists('*IMAP_GetPlaceHolderStart')
    let m = IMAP_GetPlaceHolderStart()
    if !empty(m)
      ::call s:Verbose('lh#marker#open '.m.'  using IMAP placeholder characters')
      return m
    endif
  endif
  if !exists("b:marker_open")
    call s:Verbose( "b:marker_open is not set")
    " Note: \xab <=> <C-K><<
    call lh#marker#_set("\xab", '')
    ::call s:Verbose( "b:last_encoding_used is set to ".&enc)
    let b:last_encoding_used = &enc
  else
    if !exists('b:last_encoding_used')
      ::call s:Verbose( "b:last_encoding_used is not set")
      call lh#marker#_set(b:marker_open, b:marker_close, &enc)
      ::call s:Verbose( "b:last_encoding_used is set to ".&enc)
      let b:last_encoding_used = &enc
    elseif &enc != b:last_encoding_used
      call lh#marker#_set(b:marker_open, b:marker_close, b:last_encoding_used)
      ::call s:Verbose( "b:last_encoding_used is changed to ".&enc)
      let b:last_encoding_used = &enc
    endif
  endif
  ::call s:Verbose('lh#marker#open '.b:marker_open)
  return b:marker_open
endfunction

" Function: lh#marker#close() {{{2
function! lh#marker#close() abort
  if s:Option('use_place_holders', 0) && exists('*IMAP_GetPlaceHolderEnd')
    let m = IMAP_GetPlaceHolderEnd()
    if !empty(m)
      ::call s:Verbose('lh#marker#close '.m.'  using IMAP placeholder characters')
      return m
    endif
  endif
  if !exists("b:marker_close")
    ::call s:Verbose( "b:marker_close is not set")
    " Note: \xbb <=> <C-K>>>
    call lh#marker#_set('', "\xbb")
    ::call s:Verbose( "b:last_encoding_used is set to ".&enc)
    let b:last_encoding_used = &enc
  else " if exists('b:last_encoding_used')
    if &enc != b:last_encoding_used
      ::call s:Verbose( "b:last_encoding_used is different from current")
      call lh#marker#_set(b:marker_open, b:marker_close, b:last_encoding_used)
      ::call s:Verbose( "b:last_encoding_used is changed from ".b:last_encoding_used." to ".&enc)
      let b:last_encoding_used = &enc
    endif
  endif
  ::call s:Verbose('lh#marker#close '.b:marker_close)
  return b:marker_close
endfunction

" Function: lh#marker#txt({text}) {{{2
function! lh#marker#txt(...) abort
  return lh#marker#open() . ((a:0>0) ? a:1 : '') . lh#marker#close()
endfunction

" Function: lh#marker#very_magic(...) {{{3
function! s:EscapeVeryMagic(text)
  return escape(a:text, '$.*~()|\.{}<+>')
endfunction
function! lh#marker#very_magic(...) abort
  return s:EscapeVeryMagic(lh#marker#open()) . ((a:0>0) ? a:1 : '') . s:EscapeVeryMagic(lh#marker#close())
endfunction

" Function: lh#marker#is_a_marker(...) {{{3
" Returns whether the text currently selected matches a marker and only one.
function! lh#marker#is_a_marker(...) abort
  if a:0 > 0
    " Check whether the selected text matches a marker (and only one)
    return (a:1 =~ '^'.lh#marker#txt('.\{-}').'$')
          \ && (a:1 !~ '\%(.*'.lh#marker#close().'\)\{2}')
  else
    if line("'<") == line("'>") " I suppose markers don't spread over several lines
      " Extract the selected text
      let a = lh#visual#selection()

      " Check whether the selected text matches a marker (and only one)
      return lh#marker#is_a_marker(a)
    endif
    return 0
  endif
endfunction

"------------------------------------------------------------------------
" ## Internal functions {{{1
" # Options {{{2
function! s:Option(name, default) " {{{3
  if     exists('b:'.a:name) | return b:{a:name}
  else                       | return get(g:, a:name, a:default)
  endif
endfunction

function! s:Select_or_Echo()    "                  {{{3
  return get(g:, 'marker_prefers_select', 1)
endfunction

function! s:Select_Empty_Mark() " or delete them ? {{{3
  return get(g:, 'marker_select_empty_marks', 1)
endfunction

function! lh#marker#_set(open, close, ...) abort " {{{2
  if !empty(a:close) && a:close == &enc
    throw ":SetMarker: two arguments expected"
  endif
  let from = (a:0!=0) ? a:1 : 'latin1'
  " :call Dfunc('lh#marker#_set('.a:open.','.a:close.','.from.')')

  " let ret = ''
  if !empty(a:open)
    let b:marker_open  = lh#encoding#iconv(a:open, from, &enc)
    " let ret = ret. "  b:open=".b:marker_open
  endif
  if !empty(a:close)
    let b:marker_close = lh#encoding#iconv(a:close, from, &enc)
    " let ret = ret . "  b:close=".b:marker_close
  endif
  " :call Dret("lh#marker#_set".ret)

  " Exploits Tom Link Stakeholders plugin if installed
  " http://www.vim.org/scripts/script.php?script_id=3326
  if exists(':StakeholdersEnable') && exists('b:marker_open') && exists('b:marker_close')
    let g:stakeholders#def = {'rx': b:marker_open.'\v(..{-})'.b:marker_close}
    " Seems to be required to update g:stakeholders#def.Replace(text)
    runtime autoload/stakeholders.vim
  endif
endfunction

function! lh#marker#_insert(text) range abort " {{{2
  " This test function is incapable of detecting the current mode.
  " There is no way to know when we are in insert mode.
  " There is no way to know if we are in visual mode or if we are in normal
  " mode and the cursor is on the start of the previous visual region.
  let mode =  confirm("'< = (".line("'<").','.virtcol("'<").
        \ ")\n'> =(".line("'>").','.virtcol("'>").
        \ ")\n.  =(".line(".").','.virtcol("."). ")\n\n Mode ?",
        \ "&Visual\n&Normal\n&Insert", 1)
  if mode == 1
    exe "normal gv\<Plug>MarkersMark"
  elseif mode == 2
    exe "normal viw\<Plug>MarkersMark"
  elseif mode == 3
    "<c-o>:MI titi toto<cr>
    let text = lh#marker#txt(a:text)
    exe "normal! i".text."\<esc>l"
  endif
endfunction

function! lh#marker#_jump(param) abort " {{{2
  " ¿ forward([1]) or backward(0) ?
  let direction = get(a:param, 'direction') ? '' : 'b'
  let delete    = get(a:param, 'delete', 0)
  let mode      = get(a:param, 'mode')

  " little optimization
  let mo = lh#marker#open()        | let emo = escape(mo, '\')
  let mc = lh#marker#close()       | let emc = escape(mc, '\')

  " Save cursor and current view
  let position = winsaveview()

  " if within a marker, and going backward, {{{3
  if (direction == 'b') && !s:Option('marker_select_current', 0)
    " echomsg 'B, !C'
    " then: go to the start of the marker.
    " Principle: {{{
    " 1- search backward the pair {open, close}
    "    In order to find the current pair correctly, we must consider the
    "    beginning of the match (\zs) to be just before the last character of
    "    the second pair.
    " 2- Then, in order to be sure we did jump to a match of the open marker,
    "    we search forward for its closing counter-part.
    "    Test: with open='«', close = 'ééé', and the text:{{{
    "       blah «»
    "       «1ééé  «2ééé
    "       «3ééé foo
    "       «4ééé
    "    with the cursor on any character. }}}
    "    Without this second test, the cursor would have been moved to the end
    "    of "blah «" which is not the beginning of a marker.
    " }}}
    if searchpair('\V'.emo, '', '\V'.substitute(emc, '.$', '\\zs\0', ''), 'b')
      echo '1-'.string(getpos('.'))
      if ! searchpair('\V'.emo, '', '\V'.emc, 'n')
        echo '2-'.string(getpos('.'))
        " restore cursor position as we are not within a marker.
        call winrestview(position)
      endif
    endif
  endif
  " if within a marker, and going forward, {{{3
  if (direction == '') && s:Option('marker_select_current_fwd', 1)
    " This option must be reserved to
    " echomsg 'F, C'
    " then: go to the start of the marker.
    if searchpair('\V'.emo, '', '\V'.emc, 'w')
      " echomsg '1-'.string(getpos('.'))
      if ! searchpair('\V'.emo, '', '\V'.emc, 'b')
        " echomsg '2-'.string(getpos('.'))
        " restore cursor position as we are not within a marker.
        call winrestview(position)
        " echomsg position
      else
        " echomsg "premature found"
        return s:DoSelect(emo, emc, delete, position, mode)
      endif
    endif
  endif
  " }}}3
  " "&ws?'w':'W'" is implicit with search()
  if !search('\V'.emo.'\.\{-}'.emc, direction) " {{{3
    " Case:             No more marker
    " Treatment:        None
    return ""
  else " found! {{{3
    return s:DoSelect(emo, emc, delete, position, mode)
  endif
  " }}}3
endfunction

function! s:DoSelect(emo, emc, delete, position, mode) abort " {{{2
  " In insert mode, now the mapping is using <c-r>=, we need to move the cursor
  " one character right
  let mode_prefix = a:mode == 'i' ? "\<c-\>\<c-n>l" : ''

  if foldclosed('.') >= 0
    silent! foldopen!
  endif
  if s:Option('marker_center', 1)
    exe "normal! zz"
  endif
  let mark_start = virtcol('.')
  let select = 'v'.mark_start.'|o'
  if &selection == 'exclusive' | let select .= 'l' | endif
  let c = col('.')
  " search for the last character of the closing string.
  call search('\V'.substitute(a:emc, '.$', '\\zs\0', ''))
  " call confirm(matchstr(getline('.'), se). "\n".se, "&Ok", 1 )
  if s:Select_or_Echo() " select! {{{4
    let is_not_empty = matchstr(getline('.'),'\V\%'.c.'c'.a:emo.'\zs\.\{-}\ze'.a:emc)!= ''
    if !a:delete &&
          \ (s:Select_Empty_Mark() || is_not_empty)
      " Case:           Marker containing a tag, e.g.: «tag»
      " Treatment:      The marker is selected, going into SELECT-mode
      return mode_prefix.select."\<c-g>"
    else
      " Case:           Empty marker, i.e. not containing a tag, e.g.: «»
      " Treatment:      The marker is deleted, going into INSERT-mode.
      if a:position.lnum == line('.') && a:mode == 'i'
        " Then we can move the cursor instead
        let mark_end   = virtcol('.')
        let offset = mark_start - a:position.curswant - 1
        let action
              \ = lh#map#_move_cursor_on_the_current_line(offset)
              \ . repeat("\<del>", mark_end-mark_start+1)

        " let g:debug = {'act':action, 'pos':a:position, 'mark_end':mark_end, 'mark_start':mark_start, 'offset':offset}
        call winrestview(a:position)
        return action
      endif
      return mode_prefix.select.'"_c'
    endif
  else " Echo! {{{4
    " Case:             g:marker_prefers_select == 0
    " Treatment:        Echo the tag within the marker
    return mode_prefix.select."v:echo lh#visual#selection()\<cr>gv\"_c"
  endif
endfunction

function! lh#marker#_move_within_marker()     abort " {{{2
  " Purpose: move the cursor within the marker just inserted.
  " Here, b:marker_close exists
  return "\<esc>" . strlen(lh#encoding#iconv(lh#marker#close(),&enc, 'latin1')) . 'ha'
endfunction

function! lh#marker#_toggle_marker_in_visual()     abort " {{{2
  " Purpose: Toggle the marker characters around a visual zone.
  " 1- Check wheither we areselecting a marker
  if line("'<") == line("'>") " I suppose markers don't spread over several lines
    " Extract the selected text
    let a_save = @a
    normal! gv"ay
    let a = @a
    let @a = a_save

    " Check whether the selected text is strictly a marker (and only one)
    if (a =~ '^'.lh#marker#txt('.\{-}').'$')
          \ && (a !~ '\%(.*'.lh#marker#close().'\)\{2}')
      " 2- If so, strip the marker characters
      let a = substitute(a, lh#marker#txt('\(.\{-}\)'), '\1', '')
      let unnamed_save=@"
      exe "normal! gvs".a."\<esc>"
      " escape(a, '\') must not be used.
      " exe "normal! gvs".a."\<esc>v".(strlen(a)-1)."ho\<c-g>"
      let @"=unnamed_save
      return 'a'
    endif
  endif

  " 3- Else insert the pair of marker characters around the visual selection
  call lh#map#insert_around_visual(lh#marker#open(),lh#marker#close(),0,0)
  return '`>'.lh#encoding#strlen(lh#marker#txt()).'l'
endfunction

" }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
