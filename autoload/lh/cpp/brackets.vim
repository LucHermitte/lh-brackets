"=============================================================================
" File:         autoload/lh/cpp/brackets.vim                             {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"               <URL:http://github.com/LucHermitte>
" License:      GPLv3 with exceptions
"               <URL:http://github.com/LucHermitte/lh-brackets/License.md>
" Version:      3.6.0
let s:k_version = 360
" Created:      17th Mar 2008
" Last Update:  16th Nov 2019
"------------------------------------------------------------------------
" Description:
"       Functions that tune how some bracket characters should expand in C&C++
" TODO:
" }}}1
"=============================================================================

let s:cpo_save=&cpo
set cpo&vim
"------------------------------------------------------------------------
" Does vim supports the new way to support redo/undo?
let s:k_vim_supports_redo = has('patch-7.4.849')
let s:k_move_prefix = s:k_vim_supports_redo ? "\<C-G>U" : ""

" ## Misc Functions     {{{1
" # Version {{{2
function! lh#cpp#brackets#version()
  return s:k_version
endfunction

" # Debug   {{{2
let s:verbose = get(s:, 'verbose', 0)
function! lh#cpp#brackets#verbose(...)
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

function! lh#cpp#brackets#debug(expr) abort
  return eval(a:expr)
endfunction

" ## Functions {{{1

" - Callback function that specializes the behaviour of '<' {{{2
function! lh#cpp#brackets#lt() abort
  let c = col('.') - 1
  let l = getline('.')
  let l = strpart(l, 0, c)
  if l =~ '^#\s*include\s*$'
        \ . '\|\U\{-}_cast\s*$'
        \ . '\|template\s*$'
        \ . '\|typename[^<]*$'
        " \ . '\|\%(lexical\|dynamic\|reinterpret\|const\|static\)_cast\s*$'
    if lh#brackets#usemarks()
      return '<!cursorhere!>!mark!'
      " NB: InsertSeq with "\<left>" as parameter won't work in utf-8 => Prefer
      " "h" when motion is needed.
      " return '<>' . "!mark!\<esc>".lh#encoding#strlen(Marker_Txt())."hi"
      " return '<>' . "!mark!\<esc>".lh#encoding#strlen(Marker_Txt())."\<left>i"
    else
      " return '<>' . "\<Left>"
      return '<!cursorhere!>'
    endif
  else
    return '<'
  endif
endfunction

" - Callback function that specializes the behaviour of '{' {{{2
function! lh#cpp#brackets#curly_open() abort
  let c = col('.') - 1
  let l = getline('.')
  let l = strpart(l, 0, c)
  let close =  l =~ 'struct\|class\|enum\|union' ? '};' : '}'
  if lh#brackets#usemarks()
    return '{!cursorhere!'.close.'!mark!'
  else
    " return '<>' . "\<Left>"
    return '{!cursorhere!'.close
  endif
endfunction

" Function: lh#cpp#brackets#curly_close() {{{2
function! lh#cpp#brackets#curly_close() abort
  let lin = line(".")
  let col = col(".")
  let lig = getline(lin)

  if lig[col-1] == '}'
    let nb = matchend(lig[(col-1) :], '};\=')
    return lh#map#_move_cursor_on_the_current_line(nb).lh#brackets#_jump_text(lig[(col+nb-1) :])
  else
    " if the non white character is a curly bracket several lines later,
    " jump to it. Ignore any following semi-colon
    let pos = searchpos('\%#\_s*};\=', 'ce')

    if pos != [0,0]
      let delta_line = pos[0] - lin
      " We need to go to another line, this means, redo will be broken
      return s:k_move_prefix."\<home>".repeat("\<down>", delta_line)
            \ . lh#map#_move_cursor_on_the_current_line(pos[1])
            \ . lh#brackets#_jump_text(getline(pos[0])[pos[1]:])
    else
      return '}'
    endif
  endif
endfunction

" - Callback function that specializes the behaviour of '[', regarding C++11 attributes {{{2
" Function: lh#cpp#brackets#square_open() {{{3
function! lh#cpp#brackets#square_open() abort
  let col = col(".")
  let lig = getline(line("."))

  let result = '[!cursorhere!]'
  if lig[(col-2):(col-1)] == '[]'
    return result
  else
    return result.s:Mark()
  endif
endfunction

" Function: lh#cpp#brackets#square_close() {{{3
function! lh#cpp#brackets#square_close() abort
  let col = col(".")
  let lig = getline(line("."))

  if lig[col-1] == ']'
    let nb = matchend(lig[(col-1) :], ']\+')
    return lh#map#_move_cursor_on_the_current_line(nb).lh#brackets#_jump_text(lig[(col+nb-1) :])
  else
    return ']'
  endif
endfunction

function! s:Mark() abort " {{{2
  return lh#brackets#usemarks()
        \ ?  "!mark!"
        \ : ""
  endif
endfunction

" Function: lh#cpp#brackets#semicolon() {{{2
" expected to be called from insert mode
function! lh#cpp#brackets#semicolon() abort
  let line = getline('.')
  let col  = col('.') - 1

  " Cursor is within a "for"/"if" context?
  if line[0:col] =~ '\v<(for|if)>\s*\('
    " TODO: better detection of context with searchpair()
    if line[col : -1] =~ '^;'
      call s:Verbose("Within for/if && before a semicolon")
      " Merge only with the next semicolon; ignore following ones!
      " => 3rd param == empty string
      return lh#brackets#close_all_and_jump_to_last_on_line(';', {'to_merge': '', 'repeat': ''})
    else
      call s:Verbose("Within for/if")
      return ';'
    endif
  endif

  let rem = line[col : -1]

  if     rem =~ '^"\=\('.lh#marker#txt('.\{-}').'\)\=[)\]]\+'
    call s:Verbose("Within brackets -> jump")
    return lh#brackets#close_all_and_jump_to_last_on_line(')]', {'to_merge': ';'})
  elseif rem =~ '^;'
    call s:Verbose("Before a semicolon -> jump")
    return lh#brackets#close_all_and_jump_to_last_on_line(';', {'to_merge': ''})
  endif

  " Otherwise
  return ';'
endfunction

" Function: lh#cpp#brackets#move_semicolon_back_to_string_context() {{{3
function! lh#cpp#brackets#move_semicolon_back_to_string_context() abort
  " It seem c-o leaves the insert mode for good. Thats odd.
  " BUG? -> return "\<bs>\<c-o>F\";"
  " Let's do n-<left> instead
  let l=getline('.')[:col(".")-3]
  let end = matchstr(l, '"\s*)\+$')
  let lend= lh#encoding#strlen(end)
  let move = lh#position#move_n("\<left>", lend)
  return "\<bs>".move.";"
endfunction

" }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
