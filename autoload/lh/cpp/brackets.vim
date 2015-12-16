"=============================================================================
" File:		autoload/lh/cpp/brackets.vim                             {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"               <URL:http://github.com/LucHermitte>
" License:      GPLv3 with exceptions
"               <URL:http://github.com/LucHermitte/lh-brackets/License.md>
" Version:	2.4.0
" Created:	17th Mar 2008
" Last Update:	16th Dec 2015
"------------------------------------------------------------------------
" Description:
" 	Functions that tune how some bracket characters should expand in C&C++
" TODO:
" }}}1
"=============================================================================

let s:cpo_save=&cpo
set cpo&vim
"------------------------------------------------------------------------
" ## Functions {{{1

" - Callback function that specializes the behaviour of '<' {{{2
function! lh#cpp#brackets#lt()
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
function! lh#cpp#brackets#close_curly()
  let c = col('.') - 1
  let l = getline('.')
  let l = strpart(l, 0, c)
  let close =  l =~ 'struct\|class' ? '};' : '}'
  if lh#brackets#usemarks()
    return '{!cursorhere!'.close.'!mark!'
  else
    " return '<>' . "\<Left>"
    return '{!cursorhere!'.close
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

function! s:Mark() " {{{2
  return lh#brackets#usemarks()
        \ ?  "!mark!"
        \ : ""
  endif
endfunction

" }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
