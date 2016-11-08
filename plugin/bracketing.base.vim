" ======================================================================
" File:         plugin/bracketing.base.vim
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"               <URL:http://github.com/LucHermitte>
" License:      GPLv3 with exceptions
"               <URL:http://github.com/LucHermitte/lh-brackets/tree/master/License.md>
" Version:      3.2.0
"
"       Stephen Riehm's braketing macros for vim
"       Customizations by Luc Hermitte.
" ======================================================================
" History:      {{{1
"       08th Nov 2016:  by LH
"               * Add <Plug>MarkersJumpOutside
"       10th Dec 2015:  by LH
"               * !mark! & co have been deprecated as mappings
"               * Support for closing all markers and jumping to the last one
"       20th Mar 2012:  by LH
"               * lh-cpp-> GPLv3
"       03rd Jan 2011:  by LH
"               * marker_prefers_select=0 fixed
"       25th Nov 2010:  by LH
"               * Aware of Tom Link's Stakeholders presence for :SetMarker
"       20th Mar 2008:  by LH
"               * Defect #1 : It is possible to configure the colour used to
"               highlight the marker
"       22nd Feb 2008:  by LH
"               * :SetMarker could accept one argument
"       15th Feb 2008   by LH
"               * g:marker_select_current_fwd to select the current marker when
"               the cursor on anywhere on it (but the last character)
"       25th May 2006   by LH
"               * Workaround for UTF-8.
"                 Never defined a !imapping! as a call to a script-local
"                 function. Only global functions can be used in UTF-8.
"       22nd Nov 2004   by LH
"               * New behaviour for !mark! in visual mode:
"                 If a marker is selected (in visual or select mode), then the
"                 marker is replaced by its contents, and we end in insert
"                 mode, just after the contents.
"                 e.g. "<+contents+>" becomes "contents"
"                 Otherwise, the visual selection is wrapped into a pair of
"                 marker characters.
"               * New mappings: !mark! and <Plug>MarkersMark has been added for
"                 the normal mode.
"               * Revert to g:loaded_bracketing_base
"       23rd May 2004   by LH
"               * Use s:loaded_bracketing_base instead of
"                 g:loaded_bracketing_base
"       17th Sep 2003   by LH
"               * Marker_Jump() works correctly even if 'selection' is set to
"                 exclusive.
"       25th Aug 2003   by LH
"               * And 2 new mappingS: !jump-and-del! !bjump-and-del! which
"                 always delete the marker. Useful to always have the same
"                 behaviour when programming (ft)plugins.
"       15th Aug 2003   by LH, from an idea of Christophe "CLeek" Sahut
"               * New option: [bg]:marker_center used to center the display
"                 area on the marker we have jumped to.
"       25th Jun 2003   by LH
"               * Small correction when b:Marker_Open is set
"       09th jan 2003   by LH
"               * The :vmap for jumping backward uses: "`>" (Srinath's idea)
"               * Add option [bg]:marker_select_current.
"       07th jan 2003   by LH
"               * Changes go into black hole register -> '"_c' -> '@"' is left
"                 unchanged.
"               * Doesn't mess any more the search history ; but the tag
"                 within a marker is not supposed to spread accross several
"                 lines -- I think it is a reasonable requirement.
"               * The marker string may contain escape characters
"               * Insensible to 'magic'
"               * The marker string is automatically converted according to
"                 the current encoding -- may work only between latin1 and
"                 utf-8 because of iconv().
"               * Going into normal mode with <C-\><C-N> instead of
"                 '<esc><c-l>' -> less screen flashes
"               * Little bug fixed with :foldopen
"       10th dec 2002   by LH
"               * Add compatibility with vim-latex::imaps.vim
"       09th dec 2002   by LH
"               * First steps to support encodings different than latin1
"                 - ¡...! mappings changed to !...!
"                 - using nr2char(char2nr("\xab"))
"               * Name of the <Plug> mappings changed
"       20th nov 2002   by LH
"               * Don't mess with folding
"       08th nov 2002   by LH
"               * Pure vim6 solution.
"               * s/brkt/marker in options and functions names.
"               * Support closing markers of several characters.
"               * New mapping to jump to the previous marker
"               * Two commands: :MN and :MP that work in normal, visual and
"                 insert modes and permit to jump to next/previous marker.
"       21st jul 2002   by LH
"               * e-mail address obfuscated for spammers
"       04th apr 2002   by LH
"               * Marker_Txt takes an optional parameter : the text
"       21st feb 2002   by LH
"               * When a comment is within a mark, we now have the possibility
"                 to select the mark (in Select-MODE ...) instead of echoing
"                 the comment.
"               * In this mode, an empty mark can be chosen or deleted.
"       Previous Version: ??????        by LH
"               * Use accessors to acces b:marker_open and b:marker_close.
"                 Reason: Changing buffers with VIM6 does not re-source this
"                 file.
"       Previous Version: 22nd sep 2001 by LH
"               * Delete all the settings that should depends on ftplugins
"               * Enable to use other markers set as a buffer-relative option.
"       Based On Version: 16.01.2000
"               (C)opyleft: Stephen Riehm 1991 - 2000
"
"       Needs:  * VIM 6.0 +
"               * misc_map.vim  (MapAroundVisualLines, by LH)
"
"       Credits:
"               Stephen Riehm, Benji Fisher, Gergely Kontra, Robert Kelly IV.
"
"------------------------------------------------------------------------
" Options:      {{{1
" b:marker_open         -> the characters that opens the marker  ; default '«'
" b:marker_close        -> the characters that closes the marker ; default '»'
"       They are buffer-relative in order to be assigned to different values
"       regarding the filetype of the current buffer ; e.g. '«»' is not an
"       appropriate marker with LaTeX files.
"
" g:marker_prefers_select                                       ; default 1
"       Option to determine if the comment within a marker should be echoed or
"       if the whole marker should be selected (select-mode).
"       Beware: The select-mode is considered to be a visual-mode. Hence all
"       the i*map won't expand in select-mode! i*abbr fortunately does.
"
" g:marker_select_empty_marks                                   ; default 1
"       Option to determine if an empty marker should be selected or deleted.
"       Works only if g:marker_prefers_select is set.
"
" [bg]:use_place_holders                                        ; default 0
"       Option that says the characters to use are [bg]:Imap_PlaceHolderStart
"       and [bg]:Imap_PlaceHolderEnd.
"       These characters are the ones used by Srinath Avadhanula's imaps.vim
"       I meant to support Srinath's variations on my own variations ; this
"       way, this script defines correct and advanced jumping functions for
"       the vim-latex suite.
"
" [bg]:marker_select_current                                    ; default 0
"       When this option is set to 1, the 'jump backward' mecanism will
"       select the current marker (the cursor is within) if applicable.
"       Otherwise, we jump to the marker before the one the cursor is within.
"
" [bg]:marker_center                                            ; default 1
"       When this option is set to 1, the line of the marker (we jump to) is
"       moved to the middle of the window.
"
"------------------------------------------------------------------------
" }}}1
" ===========================================================================
" scriptencoding latin1
" Settings      {{{1
" ========
"       These settings are required for the macros to work.
"       Essentially all you need is to tell vim not to be vi compatible,
"       and to do some kind of groovy autoindenting.
"
"       Tell vim not to do screwy things when searching
"       (This is the default value, without c)
"set cpoptions=BeFs
set cpoptions-=c
" Avoid reinclusion
if exists("g:loaded_bracketing_base") && !exists('g:force_reload_bracketing_base')
  finish
endif
let g:loaded_bracketing_base = 1

let s:cpo_save = &cpo
set cpo&vim

" Mappings that can be redefined {{{1
" ==============================
" (LH) As I use <del> a lot, I use different keys than those proposed by SR.
call lh#mapping#plug('<M-Insert>',   '<Plug>MarkersMark',                  'inv')
call lh#mapping#plug('<M-Del>',      '<Plug>MarkersJumpF',                 'inv')
call lh#mapping#plug('<M-S-Del>',    '<Plug>MarkersJumpB',                 'inv')
call lh#mapping#plug('<M-End>',      '<Plug>MarkersCloseAllAndJumpToLast', 'inv')
call lh#mapping#plug('<C-PageDown>', '<Plug>MarkersJumpOutside',           'insx')

inoremap <silent> <Plug>MarkersInsertMark <c-r>=lh#marker#txt()<cr>
imap     <silent> <Plug>MarkersMark       <Plug>MarkersInsertMark<C-R>=LHMoveWithinMarker()<cr>
vnoremap <silent> <Plug>MarkersMark       <C-\><C-N>@=LHToggleMarkerInVisual()<cr>
nmap     <silent> <Plug>MarkersMark       viw<Plug>MarkersMark

" <C-\><C-N> is like '<ESC>', but without any screen flash. Here, we unselect
" the current selection and go into normal mode.
vnoremap <silent> <Plug>MarkersJumpF <C-\><C-N>@=Marker_Jump({'direction':1, 'mode':'v'})<cr>
inoremap <silent> <Plug>MarkersJumpF <C-R>=Marker_Jump({'direction':1, 'mode':'i'})<cr>
nnoremap <silent> <Plug>MarkersJumpF @=Marker_Jump({'direction':1, 'mode':'n'})<cr>
vnoremap <silent> <Plug>MarkersJumpB <C-\><C-N>`<@=Marker_Jump({'direction':0, 'mode':'v'})<cr>
nnoremap <silent> <Plug>MarkersJumpB @=Marker_Jump({'direction':0, 'mode':'n'})<cr>
inoremap <silent> <Plug>MarkersJumpB <C-R>=Marker_Jump({'direction':0, 'mode':'i'})<cr>

vnoremap <silent> <Plug>MarkersJumpAndDelF <C-\><C-N>@=Marker_Jump({'direction':1, 'mode':'v', 'delete':1})<cr>
nnoremap <silent> <Plug>MarkersJumpAndDelF @=Marker_Jump({'direction':1, 'mode':'n', 'delete':1})<cr>
imap     <silent> <Plug>MarkersJumpAndDelF <ESC><Plug>MarkersJumpFAndDel
vnoremap <silent> <Plug>MarkersJumpAndDelB <C-\><C-N>@=Marker_Jump({'direction':0, 'mode':'v', 'delete':1})<cr>
nnoremap <silent> <Plug>MarkersJumpAndDelB @=Marker_Jump({'direction':0, 'mode':'n', 'delete':1})<cr>
imap     <silent> <Plug>MarkersJumpAndDelB <ESC><Plug>MarkersJumpFAndDel

nnoremap <silent> <Plug>MarkersCloseAllAndJumpToLast a<c-r>=lh#brackets#close_all_and_jump_to_last_on_line(lh#brackets#closing_chars())<cr>
vmap     <silent> <Plug>MarkersCloseAllAndJumpToLast <C-\><C-N>`><Plug>MarkersCloseAllAndJumpToLast
imap     <silent> <Plug>MarkersCloseAllAndJumpToLast <c-r>=lh#brackets#close_all_and_jump_to_last_on_line(lh#brackets#closing_chars())<cr>

inoremap <silent> <Plug>MarkersJumpOutside <C-R>=lh#brackets#jump_outside({'mode': 'i'})<cr>
nnoremap <silent> <Plug>MarkersJumpOutside @=lh#brackets#jump_outside({'mode': 'n'})<cr>
xnoremap <silent> <Plug>MarkersJumpOutside <C-\><C-N>@=lh#brackets#jump_outside({'mode': 'x'})<cr>
    smap <silent> <Plug>MarkersJumpOutside <C-\><C-N>a<Plug>MarkersJumpOutside

" Note: don't add "<script>" within the previous <Plug>-mappings or else they
" won't work anymore.
" }}}

" Commands {{{1
" ========
command! -nargs=+ SetMarker :call lh#marker#_set(<f-args>, &enc)<bar>:call <sid>UpdateHighlight()

:command! -nargs=0 -range MP exe ":normal <Plug>MarkersJumpB"
:command! -nargs=0 -range MN exe ":normal <Plug>MarkersJumpF"
:command! -nargs=* -range MI :call s:MarkerInsert(<q-args>)
" :command! -nargs=0 MN <Plug>MarkersJumpF
" :command! -nargs=0 MI <Plug>MarkersMark

" This test function is incapable of detecting the current mode.
" There is no way to know when we are in insert mode.
" There is no way to know if we are in visual mode or if we are in normal mode
" and the cursor is on the start of the previous visual region.
function! s:MarkerInsert(text) range
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

" }}}1

" Jump to next marker {{{1
" ===================
" Rem:
" * Two working modes : display the text between the markers or select it
" * &wrapscan is implicitly taken into acount
" * The use of the SELECT-mode is inspired by
"   Gergely Kontra <kgergely at mcl.hu>
" * The backward search of markers is due to by Robert Kelly IV.
" * @" isn't messed thanks to Srinath Avadhanula (/Benji Fisher ?)
"
function! Marker_Jump(param) " {{{2
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
endfunction " }}}2


function! s:DoSelect(emo, emc, delete, position, mode)
  " In insert mode, now the mapping is using <c-r>=, we need to move the cursor
  " one character right
  let mode_prefix = a:mode == 'i' ? "\<c-\>\<c-n>l" : ''

  silent! foldopen!
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
    if !a:delete &&
          \ (s:Select_Empty_Mark() ||
          \ (matchstr(getline('.'),'\V\%'.c.'c'.a:emo.'\zs\.\{-}\ze'.a:emc)!= ''))
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

" }}}1
" ------------------------------------------------------------------------
" Internals         {{{1
" =================
function! s:Option(name, default) " {{{2
  if     exists('b:'.a:name) | return b:{a:name}
  elseif exists('g:'.a:name) | return g:{a:name}
  else                       | return a:default
  endif
endfunction

" Accessors to markers definition:  {{{2
function! s:UpdateMarkers()
endfunction

function! Marker_Open()            " {{{3
  return lh#marker#open()
endfunction

function! Marker_Close()           " {{{3
  return lh#marker#close()
endfunction

function! Marker_Txt(...)          " {{{3
  return Marker_Open() . ((a:0>0) ? a:1 : '') . Marker_Close()
endfunction

function! LHMoveWithinMarker()     " {{{3
  " function! s:MoveWithinMarker()
  " Purpose: move the cursor within the marker just inserted.
  " Here, b:marker_close exists
  return "\<esc>" . strlen(lh#encoding#iconv(lh#marker#close(),&enc, 'latin1')) . 'ha'
endfunction

function! LHToggleMarkerInVisual() " {{{3
  " function! s:ToggleMarkerInVisual()
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
  call InsertAroundVisual(lh#marker#open(),lh#marker#close(),0,0)
  return '`>'.lh#encoding#strlen(lh#marker#txt()).'l'
endfunction

" Other options:                    {{{2

function! s:Select_or_Echo()    "                  {{{3
  return exists("g:marker_prefers_select") ? g:marker_prefers_select : 1
endfunction

function! s:Select_Empty_Mark() " or delete them ? {{{3
  return exists("g:marker_select_empty_marks") ? g:marker_select_empty_marks : 1
endfunction

function! s:Highlight()
  let default = (&bg == 'dark')
        \ ? 'guibg=#0d0d0d ctermbg=darkgray'
        \ : 'guibg=#d0d0d0 ctermbg=lightgray'
  return s:Option('marker_highlight', default)
endfunction

" Syntax highlighting of markers   {{{2
function! s:UpdateHighlight()
  " echomsg "Update marker color"
  silent! syn clear marker
  let hl = s:Highlight()
  if strlen(hl) > 0
    exe 'syn match marker /'.lh#marker#txt('.\{-}').'/ containedin=ALL'
    exe 'hi marker '.hl
  endif
endfunction

if strlen(s:Highlight()) > 0
  aug markerHL
    au!
    au EncodingChanged * :call s:UpdateMarkers()
    au BufWinEnter,EncodingChanged,ColorScheme * :call s:UpdateHighlight()
  aug END
endif

" Internal mappings {{{1
" =================
if get(g:, 'use_old_bracketting_macros', 0)
  " Defines: !mark! and !jump!
  " Note: these mappings are the one used by some other (ft)plugins I maintain.

  " Set a marker ; contrary to <Plug>MarkersInsertMark, !mark! doesn't move the
  " cursor between the marker characters.
  imap <silent> !mark! <Plug>MarkersMark
  vmap <silent> !mark! <Plug>MarkersMark
  nmap <silent> !mark! <Plug>MarkersMark

  vmap <silent> !jump!  <Plug>MarkersJumpF
  imap <silent> !jump!  <Plug>MarkersJumpF
  nmap <silent> !jump!  <Plug>MarkersJumpF
  vmap <silent> !jumpB! <Plug>MarkersJumpB
  nmap <silent> !jumpB! <Plug>MarkersJumpB
  imap <silent> !jumpB! <Plug>MarkersJumpB

  vmap <silent> !jump-and-del!  <Plug>MarkersJumpAndDelF
  nmap <silent> !jump-and-del!  <Plug>MarkersJumpAndDelF
  imap <silent> !jump-and-del!  <Plug>MarkersJumpAndDelF
  vmap <silent> !bjump-and-del! <Plug>MarkersJumpAndDelB
  nmap <silent> !bjump-and-del! <Plug>MarkersJumpAndDelB
  imap <silent> !bjump-and-del! <Plug>MarkersJumpAndDelB
endif

" }}}1
" ============================================================================
" Stephen Riehm's Bracketing macros {{{1
" ========== You should not need to change anything below this line ==========
"

"
if get(g:, 'use_old_bracketting_macros', 0)
  "       Quoting/bracketting macros
  "       Note: The z cut-buffer is used to temporarily store data!
  "
  "       double quotes
  imap !"! <C-V>"<C-V>"!mark!<ESC>F"i
  vmap !"! "zc"<C-R>z"<ESC>
  "       single quotes
  imap !'! <C-V>'<C-V>'!mark!<ESC>F'i
  vmap !'! "zc'<C-R>z'<ESC>
  "       stars
  imap !*! <C-V>*<C-V>*!mark!<ESC>F*i
  vmap !*! "zc*<C-R>z*<ESC>
  "       braces
  imap !(! <C-V>(<C-V>)!mark!<ESC>F)i
  vmap !(! "zc(<C-R>z)<ESC>
  "       braces - with padding
  imap !)! <C-V>(  <C-V>)!mark!<ESC>F i
  vmap !)! "zc( <C-R>z )<ESC>
  "       underlines
  imap !_! <C-V>_<C-V>_!mark!<ESC>F_i
  vmap !_! "zc_<C-R>z_<ESC>
  "       angle-brackets
  imap !<! <C-V><<C-V>>!mark!<ESC>F>i
  vmap !<! "zc<<C-R>z><ESC>
  "       angle-brackets with padding
  imap !>! <C-V><  <C-V>>!mark!<ESC>F i
  vmap !>! "zc< <C-R>z ><ESC>
  "       square brackets
  imap ![! <C-V>[<C-V>]!mark!<ESC>F]i
  vmap ![! "zc[<C-R>z]<ESC>
  "       square brackets with padding
  imap !]! <C-V>[  <C-V>]!mark!<ESC>F i
  vmap !]! "zc[ <C-R>z ]<ESC>
  "       back-quotes
  imap !`! <C-V>`<C-V>`!mark!<ESC>F`i
  vmap !`! "zc`<C-R>z`<ESC>
  "       curlie brackets
  imap !{! <C-V>{<C-V>}!mark!<ESC>F}i
  vmap !{! "zc{<C-R>z}<ESC>
  "       new block bound by curlie brackets
  imap !}! <ESC>o{<C-M>!mark!<ESC>o}!mark!<ESC>^%!jump!
  vmap !}! >'<O{<ESC>'>o}<ESC>^
  "       spaces :-)
  imap !space! .  !mark!<ESC>F.xa
  vmap !space! "zc <C-R>z <ESC>
  "       Nroff bold
  imap !nroffb! \fB\fP!mark!<ESC>F\i
  vmap !nroffb! "zc\fB<C-R>z\fP<ESC>
  "       Nroff italic
  imap !nroffi! \fI\fP!mark!<ESC>F\i
  vmap !nroffi! "zc\fI<C-R>z\fP<ESC>

  "
  " Extended / Combined macros
  "       mostly of use to programmers only
  "
  "       typical function call
  imap !();!  <C-V>(<C-V>);!mark!<ESC>F)i
  imap !(+);! <C-V>(  <C-V>);!mark!<ESC>F i
  "       variables
  imap !$! $!{!
  vmap !$! "zc${<C-R>z}<ESC>
  "       function definition
  imap !func! !)!!mark!!jump!!}!!mark!<ESC>kk0!jump!
  vmap !func! !}!'<kO!)!!mark!!jump!<ESC>I

  "
  " Special additions:
  "
  "       indent mail
  vmap !mail! :s/^[^ <TAB>]*$/> &/<C-M>
  map  !mail! :%s/^[^ <TAB>]*$/> &/<C-M>
  "       comment marked lines
  imap !#comment! <ESC>0i# <ESC>A
  vmap !#comment! :s/^/# /<C-M>
  map  !#comment! :s/^/# /<C-M>j
  imap !/comment! <ESC>0i// <ESC>A
  vmap !/comment! :s,^,// ,<C-M>
  map  !/comment! :s,^,// ,<C-M>j
  imap !*comment! <ESC>0i/* <ESC>A<TAB>*/<ESC>F<TAB>i
  vmap !*comment! :s,.*,/* &      */,<C-M>
  map  !*comment! :s,.*,/* &      */,<C-M>j
  "       uncomment marked lines (strip first few chars)
  "       doesn't work for /* comments */
  vmap !stripcomment! :s,^[ <TAB>]*[#>/]\+[ <TAB>]\=,,<C-M>
  map  !stripcomment! :s,^[ <TAB>]*[#>/]\+[ <TAB>]\=,,<C-M>j

  "
  " HTML Macros
  " ===========
  "
  "       turn the current word into a HTML tag pair, ie b -> <b></b>
  imap !Htag! <ESC>"zyiwciw<<C-R>z></<C-R>z>!mark!<ESC>F<i
  vmap !Htag! "zc<!mark!><C-R>z</!mark!><ESC>`<!jump!
  "
  "       set up a HREF
  imap !Href! <a href="!mark!">!mark!</a>!mark!<ESC>`[!jump!
  vmap !Href! "zc<a href="!mark!"><C-R>z</a>!mark!<ESC>`<!jump!
  "
  "       set up a HREF name (tag)
  imap !Hname! <a name="!mark!">!mark!</a>!mark!<ESC>`[!jump!
  vmap !Hname! "zc<a name="!mark!"><C-R>z</a>!mark!<ESC>`<!jump!
endif

" }}}1
" ======================================================================
let &cpo = s:cpo_save
" vim600: set fdm=marker:
