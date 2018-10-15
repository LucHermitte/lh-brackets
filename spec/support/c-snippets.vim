  xnoremap <buffer> <silent> µ
        \ <c-\><c-n>@=lh#style#surround('if(!cursorhere!){', '}!mark!',
        \ 0, 1, '', 1, 'if ')<cr>

  Inoreabbr <buffer> <silent> if <C-R>=lh#map#insert_seq('if ',
        \ lh#style#apply('\<c-f\>if(!cursorhere!){!mark!}!mark!'))<cr>
