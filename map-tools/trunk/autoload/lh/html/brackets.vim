"=============================================================================
" $Id$
" File:		autoload/lh/html/brackets.vim                             {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://code.google.com/p/lh-vim/>
" License:      GPLv3 with exceptions
"               <URL:http://code.google.com/p/lh-vim/wiki/License>
" Version:	2.0.0
" Created:	24th Mar 2008
" Last Update:	$Date$
"------------------------------------------------------------------------
" Description:
" 	Functions that tune how some bracket characters should expand in C&C++
" 
"------------------------------------------------------------------------
" Installation:	
" 	Requires Vim7+ and lh-map-tools
" 	Used by {ftp}/ftplugin/html/html_brackets.vim
" 	Drop this file into {rtp}/autoload/lh/html
"
" History:	
" 	v1.0.0: First version
"       v2.0.0: GPLv3
" }}}1
"=============================================================================

let s:cpo_save=&cpo
set cpo&vim

" ## Debug {{{1
function! lh#html#brackets#verbose(level)
  let s:verbose = a:level
endfunction

function! s:Verbose(expr)
  if exists('s:verbose') && s:verbose
    echomsg a:expr
  endif
endfunction

function! lh#html#brackets#debug(expr)
  return eval(a:expr)
endfunction

"------------------------------------------------------------------------
" ## Hooks {{{1
function! lh#html#brackets#lt()
  return s:Insert(0)
endfunction

function! lh#html#brackets#gt()
  return s:Insert(1)
endfunction

" '<' automatically inserts its counter part
" '>' reach the next '>' 
" While '<'+'<' inserts '&lt;' and '<'+'>' inserts '&gt;'
"
" And '<' + '/' will insert the closing tag associated to the previous one
" not already closed.

" Which==0 <=> '<'; 
function! s:Insert(which)
  let column = col(".")
  let lig = getline(line("."))
  if lig[column-2] == '<'
    let ret = "\<BS>&". ((a:which == 0) ? 'lt;' : 'gt;')
    if lig[column-1] == '>'
      let ret = "\<Right>\<BS>" . ret
    endif
    " if lig[column].lig[column+1] == Marker_Txt()
    if strpart(lig, column) =~ '\V'.escape(Marker_Txt(), '\')
      let ret .= substitute(Marker_Txt(), '.', "\<del>", 'g')
    endif
    return ret
  else
    if a:which == 0 
      if exists("b:usemarks") && b:usemarks == 1
	" return "<>\<c-r>=Marker_Txt()\<cr>\<esc>F>i"
	return "<>!mark!\<esc>F>i"
	"TODO: tester sans imaps.vim
      else
	return "<>\<left>"
      endif
    else            | return "\<esc>/>\<CR>a"
    endif
  endif
endfunction

"
function! s:CloseTag()
  let ret = '/'
  let column = col(".")
  let lig = getline(line("."))
  if lig[column-2] == '<'
    " find the previous match ... perhaps thanks to matchit
    let ret = "\<BS>&lt;"
    if lig[column-1] == '>'
      let ret = "\<Right>\<BS>" . ret
    endif
  endif
  return ret;
endfunction

let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
