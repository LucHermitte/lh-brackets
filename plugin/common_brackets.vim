"===========================================================================
" File:         plugin/common_brackets.vim
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"               <URL:http://github.com/LucHermitte/lh-brackets>
" License:      GPLv3 with exceptions
"               <URL:http://github.com/LucHermitte/lh-brackets/tree/master/License.md>
" Version:      3.4.2
let s:version = 342
" Purpose:      {{{1
"               This file defines a command (:Brackets) that simplifies
"               the definition of mappings that insert pairs of caracters when
"               the first one is typed. Typical examples are the parenthesis,
"               brackets, <,>, etc.
"               The definitions can be buffer-relative or global.
"
"               This commands is used by different ftplugins:
"               <vim_brackets.vim>, <c_brackets.vim> <ML_brackets.vim>,
"               <html_brackets.vim>, <php_brackets.vim> and <tex_brackets.vim>
"               -- available on my VIM web site.
"
"               BTW, they can be activated or desactivated by pressing <F9>
"
" History:      {{{1
" Version 3.4.2:
"               * Mapping on <CR> will enrich any previous mapping
" Version 3.4.0:
"               * Replaces dependency to lh-dev to a dependency to
"               lh-style in tests
" Version 3.2.0:
"               * Removes dependency to lh-dev
" Version 3.0.1:
"               * Fix issue with old vim 7.2 version, thanks to Troy Curtis Jr
" Version 3.0.0:
"               * More brackets manipulations
"               * <Plug>Mappings for brackets manipulations are now always defined.
" Version 2.3.x:
"               * File deprecated. Use autoload/lh/map.vim instead
" Version 2.2.0:
"               * b:usemarks -> [bg]:usemarks
" Version 2.1.3:
"               * Bracket toggling mappings restricted to normal mode
"               * Bracket toggling mode waits for no more than one action/key
" Version 2.1.0:
"               * Features from lh-cpp moved to lh-brackets (
"                 - <cr> within empty brackets;
"                 - <del> within empty brackets ;
"               * New option -but to !Brackets to exclude patterns
"               * Default brackets definitions re-established
"                 - "-but" option used for single-quote mapping
" Version 2.0.0:
"               * GPLv3
" Version 1.0.0:
"               * Vim 7 required!
"               * New way to configure the desired brackets, the previous
"               approach has been deprecated
" Version 0.6.0:
"               * UTF-8 bug fix in Brkt_lt(), Brkt_gt(), Brkt_Dquote()
"               * New numerotation used in versionning
"               * Project Added in SVN
" Version 0.5.4
"               * b:cb_bracket == 2 replaces the previous behavior (==1)
"                 b:cb_bracket == 1, maps <localleader>[ in normal- and
"                 visual-modes, which does not mess anymore with vim default
"                 bindings of [a, [c, [[, [(, ...
" Version 0.5.3:
"               * Brackets manipulations support angle brackets
" Version 0.5.2:
"               * Triggers.vim can be installed into {rtp}/macros
" Version 0.5.1:
"               * Fix a small bug when editing vimL files.
" Version 0.5.0:
"               * Compatible with Srinath Avadhanula's imaps.vim
"               * Vim buffers: smarter keybindings for \(, \%( and (
"                 (requires imaps.vim)
"               * Visual-mode mappings for the brackets do not surround markers
"                 (/placeholders) anymore, now they are discarded
" Version 0.4.1:
"               * Uses InsertAroundVisual() in order to work even when
"                 'selection' is set to exclusive.
" Version 0.4.0:
"               * New option: b:cb_jump_on_close that specify weither the
"                 mappings for the closing brackets are defined or not
"                 default: true (1)
" Version 0.3.9:
"               * Updated to match changes within bracketing.base.vim
"                -> ¡xxx! mappings changed to !xxx!
"                [encodings issue]
" Version 0.3.8:
"               * Updated to match changes within bracketing.base.vim
"               * Markers-mappings moved back to bracketing.base.vim
" Version 0.3.7:
"               * Brackets manipulation mappings for normal mode can be changed
"                 They are now <Plug> mappings.
"                 Same enhancement for mappings to ¡mark! and ¡jump!
" Version 0.3.6c:
"               * Change every 'normal' to 'normal!'
" Version 0.3.6b:
"               * address obfuscated for spammers
" Version 0.3.6:
"               * accept default value for b:usemarks
" Version 0.3.5:
"               * add continuation lines support ; cf 'cpoptions'
" Version 0.3.4:
"               * Works correctly when editing several files (like with
"               "vim foo1.x foo2.x").
"               * ')' and '}' don't search for the end of the bracket when we
"               are within a comment.
" Version 0.3.3:
"               * Add support for \{, \(, \[, \<
"               * Plus some functions to change the type of brackets and
"               toggle backslashes before brackets.
"               Inspired from AucTeX.vim.
" Version 0.3.2:
"               * Bugs fixed with {
" Version 0.3.1:
"               * Triggers.vim and help.vim used, but not required.
" Version 0.3.0:
"               * Pure VIM6
" Version 0.2.1a:
"               * Some little change with the requirements
" Version 0.2.1:
"               * Use b:usemarks in the mapping of curly-brackets
" Version 0.2.0:
"               * Lately, I've discovered (SR) Stephen Riehm's bracketing
"               macros and felt in love with the markers feature. So, here is
"               the ver 2.x based on his package.
"               I still bring an original feature : a centralized way to
"               customize these pairs regarding options specified within
"               the ftplugins.
"               Note that I planned to use this file with my customized
"               version of Stephan Riehm's file.
"
" Options:      {{{1
"       (*) b:cb_bracket                        : [ -> [ & ]
"       (*) b:cb_cmp                            : < -> < & >
"           could be customized thanks to b:cb_ltFn and b:cb_gtFn [ML_set.vim]
"       (*) b:cb_acco                           : { -> { & }
"       (*) b:cb_parent                         : ( -> ( & )
"       (*) b:cb_mathMode                       : $ -> $ & $    [tex_set.vim]
"           type $$ in visual/normal mode
"       (*) b:cb_quotes                         : ' -> ' & '
"               == 2  => non active within comment or strings
"       (*) b:cb_Dquotes                        : " -> " & "
"           could be customized thanks to b:cb_DqFn ;   [vim_set.vim]
"               == 2  => non active within comment or strings
"       (*) [bg]:usemarks                               :
"               indicates the wish to use the marking feature first defined by
"               Stephan Riehm.
"       (*) b:cb_jump_on_close                  : ), ], }
"               == 0  => no mappings for ), ] and }
"               == 1  => mappings for ), ] and } (default)
"
"
" Todo:         {{{1
"       (*) Option b:cb_double that defines weither we must hit '(' or '(('
"       (*) Support '\%(\)' for vim when imaps.vim is not installed
"       (*) Support '||', '\|\|' and '&&' (within eqnarray[*]) for LaTeX.
"       (*) Systematically use [bg]:usemarks for opening and closing
" }}}1
"===========================================================================
"
"======================================================================
" line continuation used here ??
let s:cpo_save = &cpo
set cpo&vim

"======================================================================
"# Anti-reinclusion & dependencies {{{1
if exists("g:loaded_common_brackets") && !exists('g:force_reload_common_brackets')
  let &cpo = s:cpo_save
  finish
endif
let g:loaded_common_brackets = s:version

" Make sure imaps.vim, if installed, is loaded before this plugin
if !exists("*IMAP")
  runtime plugin/imaps.vim
endif

"======================================================================
"# Brackets definitions {{{1
"# :Brackets Command {{{2
command! -nargs=+ -bang Brackets call lh#brackets#define("<bang>", <f-args>)

"# <Plug>ToggleBrackets Mappings {{{2
nnoremap <silent> <Plug>ToggleBrackets :call lh#brackets#toggle()<cr>
if !hasmapto('<Plug>ToggleBrackets', 'n') && (mapcheck("<F9>", "n") == "")
  nmap <silent> <F9> <Plug>ToggleBrackets
endif
inoremap <silent> <Plug>ToggleBrackets <c-o>:call lh#brackets#toggle()<cr>
if !hasmapto('<Plug>ToggleBrackets', 'i') && (mapcheck("<F9>", "i") == "")
  imap <silent> <F9> <Plug>ToggleBrackets
endif

"# <Plug>ToggleMarkers Mappings {{{2
nnoremap <silent> <Plug>ToggleMarkers :call lh#brackets#toggle_usemarks()<cr>
if !hasmapto('<Plug>ToggleMarkers', 'n') && (mapcheck("<M-F9>", "n") == "")
  nmap <silent> <M-F9> <Plug>ToggleMarkers
endif
inoremap <silent> <Plug>ToggleMarkers <c-o>:call lh#brackets#toggle_usemarks()<cr>
if !hasmapto('<Plug>ToggleMarkers', 'i') && (mapcheck("<M-F9>", "i") == "")
  imap <silent> <M-F9> <Plug>ToggleMarkers
endif

"# Delete empty brackets {{{2
if lh#ft#option#get('cb_delete_empty_brackets', &ft, 1)
  call lh#brackets#define_imap('<bs>',
        \ [{ 'condition': 'lh#brackets#_match_any_bracket_pair()',
        \   'action': 'lh#brackets#_delete_empty_bracket_pair()'}],
        \ 0,
        \ '\<bs\>'
        \ )
endif

"# Add new line on <cr> within empty brackets {{{2
" TODO: add options to tune the kind of brackets depending on the filetype
if lh#option#get('cb_newline_within_empty_brackets', 1)
  call lh#brackets#enrich_imap('<cr>',
        \ {'condition': 'getline(".")[col(".")-2:col(".")-1]=="{}"',
        \   'action': 'lh#brackets#_add_newline_between_brackets()'},
        \ 0
        \ )
endif

"# Default brackets definitions {{{2
if ! lh#option#get('cb_no_default_brackets', 0)
  " Older vim versions do not properly autoload `lh#ft#is_text` wrapped in
  " `function()`.
  if !has('patch-7.2-061')
    call lh#ft#version()
  endif
  :Brackets! ( )
  :Brackets! [ ] -visual=0
  :Brackets! [ ] -insert=0 -trigger=<leader>[

  :Brackets! " " -visual=0 -insert=1
  :Brackets! " " -visual=1 -insert=0 -trigger=""
  " :Brackets! ' ' -visual=0 -insert=1 -but=^$\\\\|text\\\\|latex
  :Brackets! ' ' -visual=0 -insert=1 -but=function('lh#ft#is_text')
  :Brackets! ' ' -visual=1 -insert=0 -trigger=''

  :Brackets! < > -visual=1 -insert=0 -trigger=<localleader><

  " :Brackets { } -visual=0 -nl
  " :Brackets { } -visual=0 -trigger=#{
  " :Brackets { } -visual=1 -insert=0
  :Brackets! { }
  :Brackets! { } -visual=1 -insert=0 -nl -trigger=<leader>{
  "}
endif

"======================================================================
"# Matching Brackets Macros, From AuCTeX.vim (due to Saul Lubkin).   {{{1
" Except, that I use differently the chanching-brackets functions.
" For normal mode.

"# Bindings for the Bracket Macros {{{2
if !exists('g:cb_want_mode ') | let g:cb_want_mode = 1 | endif
if g:cb_want_mode " {{{
  if !hasmapto('BracketsManipMode')
    nnoremap <silent> <M-b>     :call BracketsManipMode("\<M-b>")<cr>
  endif
  " }}}
else " {{{
  if !hasmapto('<Plug>DeleteBrackets')
    nmap <M-b>x         <Plug>DeleteBrackets
    nmap <M-b><Del>     <Plug>DeleteBrackets
  endif

  if !hasmapto('<Plug>ChangeToRoundBrackets')
    nmap <M-b>(         <Plug>ChangeToRoundBrackets
  endif

  if !hasmapto('<Plug>ChangeToSquareBrackets')
    nmap <M-b>[         <Plug>ChangeToSquareBrackets
  endif

  if !hasmapto('<Plug>ChangeToCurlyBrackets')
    nmap <M-b>{         <Plug>ChangeToCurlyBrackets
  endif

  if !hasmapto('<Plug>ChangeToAngleBrackets')
    nmap <M-b>{         <Plug>ChangeToAngleBrackets
  endif

  if !hasmapto('<Plug>ToggleBackslash')
    nmap <M-b>\         <Plug>ToggleBackslash
  endif
endif " }}}

noremap <silent> <Plug>DeleteBrackets         :call <SID>DeleteBrackets()<CR>
noremap <silent> <Plug>ChangeToRoundBrackets  :call <SID>ChangeRound()<CR>
noremap <silent> <Plug>ChangeToSquareBrackets :call <SID>ChangeSquare()<CR>
noremap <silent> <Plug>ChangeToCurlyBrackets  :call <SID>ChangeCurly()<CR>
noremap <silent> <Plug>ChangeToAngleBrackets  :call <SID>ChangeAngle()<CR>
nnoremap <silent> <Plug>ToggleBackslash       :call <SID>ToggleBackslash()<CR>

" Bindings for the Bracket Macros

"inoremap <C-Del> :call <SID>DeleteBrackets()<CR>
"inoremap <C-BS> <Left><C-O>:call <SID>DeleteBrackets()<CR>

"# Then the procedures. {{{2
function! s:DeleteBrackets() " {{{
  let s:b = getline(line("."))[col(".") - 2]
  let s:c = getline(line("."))[col(".") - 1]
  if s:b == '\' && (s:c == '{' || s:c == '}')
    normal! X%X%
  endif
  if s:c == '{' || s:c == '[' || s:c == '('
    normal! %x``x
  elseif s:c == '}' || s:c == ']' || s:c == ')'
    normal! %%x``x``
  endif
endfunction " }}}

function! s:ChangeTo(open_close) abort " {{{
  let line = getline(line("."))
  let off = col(".") - 1
  let c = line[off]
  " matchpairs only accept different pair characters
  if c =~ '[''/"`]'
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
    set matchpairs+=<:>,(:),{:},[:]
    if has_key(s:k_pairs, c) | exe 'normal! %r'.(a:open_close[1]).'``r'.(a:open_close[0])
    elseif c =~ '[)>}\]]'    | exe 'normal! %%r'.(a:open_close[1]).'``r'.(a:open_close[0])
    endif
  finally
    call cleanup.finalize()
  endtry
endfunction " }}}


function! s:ToggleBackslash() " {{{
  let s:b = getline(line("."))[col(".") - 2]
  let s:c = getline(line("."))[col(".") - 1]
  if s:b == '\'
    if s:c =~ '(\|{\|['     | normal! %X``X
    elseif s:c =~ ')\|}\|]' | normal! %%X``X%
    endif
  else
    if s:c =~ '(\|{\|['     | exe "normal! %i\\\<esc>``i\\\<esc>"
    elseif s:c =~ ')\|}\|]' | exe "normal! %%i\\\<esc>``i\\\<esc>%"
    endif
  endif
endfunction " }}}

" TODO: get the current pairs from the one registered in lh#brackets
let s:k_pairs = {
      \ '(' : [ '(', ')' ],
      \ '[' : [ '[', ']' ],
      \ '{' : [ '{', '}' ],
      \ '<' : [ '<', '>' ],
      \ '"' : [ '"', '"' ],
      \ '`' : [ '`', '`' ],
      \ '/' : [ '/', '/' ],
      \ "'" : [ "'", "'" ]
      \ }
function! BracketsManipMode(starting_key) " {{{
  redraw! " clear the msg line
  echohl StatusLineNC
  echo "\r-- brackets manipulation mode (x ( [ { < ' \" ` \\ <F1> q)"
  echohl None
  let key = getchar()
  let bracketsManip=nr2char(key)
  if (-1 != stridx("x".join(keys(s:k_pairs), '')."\\q",bracketsManip)) ||
        \ (key =~ "\\(\<F1>\\|\<Del>\\)")
    if     bracketsManip == "x"      || key == "\<Del>"
      call s:DeleteBrackets()    | redraw! | return ''
    elseif bracketsManip == "\\" | call s:ToggleBackslash()
    elseif has_key(s:k_pairs, bracketsManip)
      call s:ChangeTo(s:k_pairs[bracketsManip])
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
endfunction " }}}
" Then the procedures.

" Matching Brackets Macros, From AuCTeX.vim (due to Saul Lubkin).   }}}1
" ===========================================================================
let &cpo = s:cpo_save
" ===========================================================================
" Implementation and other remarks : {{{
" (*) Whithin the vnoremaps, `>ll at the end put the cursor at the
"     previously last character of the selected area and slide left twice
"     (ll) to compensate the addition of the surrounding characters.
" (*) The <M-xxx> key-binding used in insert mode apply on the word
"     currently under the cursor. There also exist the normal mode version
"     of these macros.
"     Unfortunately several of these are not accessible from the french
"     keyboard layout -> <M-{>, <M-[>, <M-`>, etc
" (*) nmap <buffer> " ... is a very bad idea, hence nmap ""
" (*) !mark! and !jump! can't be called yet from MapNoContext().
"     but <c-r>=Marker_Txt()<cr> can.
" }}}
" ===========================================================================
" vim600: set fdm=marker:
