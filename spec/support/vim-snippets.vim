" Code from lh-misc to test surrounding
xnoremap <buffer> <silent> ,if
      \ <c-\><c-n>@=lh#map#surround('if !cursorhere!', 'endif',
      \ 1, 1, '', 1, 'if ')<cr>
