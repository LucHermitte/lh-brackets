"=============================================================================
" $Id$
" File:		brackets.vim                                           {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://hermitte.free.fr/vim/>
" Version:	�version�
" Created:	17th Mar 2008
" Last Update:	$Date$
"------------------------------------------------------------------------
" Description:	�description�
" 
"------------------------------------------------------------------------
" Installation:	�install details�
" History:	�history�
" TODO:		�missing features�
" }}}1
"=============================================================================

let s:cpo_save=&cpo
set cpo&vim
"------------------------------------------------------------------------

" Callback function that specializes the behaviour of '<'
function! lh#cpp#brackets#lt()
  let c = col('.') - 1
  let l = getline('.')
  let l = strpart(l, 0, c)
  if l =~ '^#\s*include\s*$'
	\ . '\|\U\{-}_cast\s*$'
	\ . '\|template\s*$'
	\ . '\|typename[^<]*$'
	" \ . '\|\%(lexical\|dynamic\|reinterpret\|const\|static\)_cast\s*$'
    if exists('b:usemarks') && b:usemarks
      return '<!cursorhere!>!mark!'
      " NB: InsertSeq with "\<left>" as parameter won't work in utf-8 => Prefer
      " "h" when motion is needed.
      " return '<>' . "!mark!\<esc>".strlen(Marker_Txt())."hi"
      " return '<>' . "!mark!\<esc>".strlen(Marker_Txt())."\<left>i"
    else
      " return '<>' . "\<Left>"
      return '<!cursorhere!>'
    endif
  else
    return '<'
  endif
endfunction




"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
