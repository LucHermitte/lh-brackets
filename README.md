# lh-brackets [![Last release](https://img.shields.io/github/tag/LucHermitte/lh-brackets.svg)](https://github.com/LucHermitte/lh-brackets/releases) [![Build Status](https://secure.travis-ci.org/LucHermitte/lh-brackets.png?branch=master)](http://travis-ci.org/LucHermitte/lh-brackets) [![Project Stats](https://www.openhub.net/p/21020/widgets/project_thin_badge.gif)](https://www.openhub.net/p/21020)

## Features

lh-brackets (ex- map-tool) provides various commands and functions to help design smart and advanced mappings dedicated to text insertion.

It is made of three sub-systems:
  * [a placeholder subsystem](#the-placeholder-subsystem),
  * [the core bracketing-system](#the-bracketing-subsystem),
  * [various Vim functions to support ftplugin definitions](#the-vim-library).

### The placeholder subsystem

This subsystem provides functions and mappings to:
  * mark places in the code where we could jump to later,  
    See the help about `!mark!`, `lh#marker#txt()`, and `<Plug>MarkersMark`
  * jump forward and backward to those places.  
    See the help about `!jump!`, and `<Plug>MarkersJumpF`
  * close all placeholders on the same line that are after closing bracket-like
    characters and jump to the last one -- see
    `<Plug>MarkersCloseAllAndJumpToLast` which is binded by default to `<M-End>`.

The marker/placeholder characters:
  * default to the French quote characters («»),
  * can be specified on a filetype basis,
  * are converted to match the current encoding,
  * can be shared with the ones from imaps.vim (`:h g:use_place_holders`).

Jumping to the next/previous placeholder:
  * is binded to `<M-ins>` or `<C-J>` by default (see `:h <Plug>MarkersJumpF`),
  * can be tuned to delete or select the placeholder the cursor is jumping to (`:h g:marker_prefers_select`, `:h g:marker_select_empty_marks`),
  * can select or ignore the placeholder where the cursor is currently within (if any) (`:h g:marker_select_current`, `:h g:marker_select_current_fwd`),
  * may move the line of the placeholder (we jump to) to the middle of the window (`:h g:marker_center`),
  * respects `'wrapscan'`,
  * opens the folder where the placeholder, we jump to, is,
  * doesn't break _redo_ (is the case of empty placeholders, when placeholders
    are deleted instead of selected) ; this feature requires Vim 7.4-849.


### The bracketing subsystem

#### Brackets insertion

This subsystem provides a command that helps define INSERT-, NORMAL-, and VISUAL-mode mappings to insert any pairs of brackets-like characters.

  * The INSERT-mode mappings will
    * insert the pair of brackets-like characters when the opening one is triggered, add a placeholder after the closing character, and move the cursor between the two bracket characters;
    * insert the closing character when pressed, or move after it if it is the next character after the cursor ;
    * delete the current pair of empty brackets when `<BS>` is hit from within the brackets (following placeholders will also be deleted) (this can be disabled by setting `[gb]:cb_delete_empty_brackets` to 0)
    * insert an extra newline when `<CR>` is hit within an empty pair of curly-brackets {} (this can be disabled by setting `[gb]:cb_newline_within_empty_brackets` to 0)
  * The VISUAL-mode mapping will surround the current selection with the pair of bracket-like characters ;
  * The NORMAL-mode mapping will select the current word (or the current line depending on the use of the newline (`-nl`) option), and then surround this selection with the pair of bracket-like characters.

It is possible to:
  * tune what is exactly inserted in INSERT-mode (thanks to the `-open` and `-close` options),
  * not insert the placeholder (depending on `b:usemark` value),
  * specify which keys sequence actually triggers the mappings defined (thanks to the `-trigger` option),
  * define the mappings only in some modes (thanks to the options `-insert`, `-visual`, and also `-normal`)
  * make the mappings line-wise (thanks to the `-nl` option),
  * tune how the NORMAL-mode mapping select a current _anything_ (thanks to the `-normal` option),
  * toggle the definitions of all the brackets mappings by pressing `<F9>` (`:h <Plug>ToggleBrackets`) ;
  * make the mappings global with `:Brackets!`, or local to a buffer with `:Brackets`. ;
  * neutralize the mapping with `-but` option ; typically to neutralize the insertion of the brackets-pair for specified filetypes, or for more complex contexts.


Here is an excerpt from the C&C++ brackets definitions, see the documentation for more help.
```
let b:usemarks         = 1
let b:cb_jump_on_close = 1

:Brackets { } -visual=0 -nl
:Brackets { } -visual=0 -trigger=#{
:Brackets { } -visual=1 -insert=0 -nl -trigger=<localleader>{
:Brackets { } -visual=1 -insert=0

:Brackets ( )
:Brackets [ ] -visual=0
:Brackets [ ] -insert=0 -trigger=<localleader>[
:Brackets " " -visual=0 -insert=1 -escapable
:Brackets " " -visual=1 -insert=0 -trigger=""
:Brackets ' ' -visual=0 -insert=1
:Brackets ' ' -visual=1 -insert=0 -trigger=''
:Brackets < > -open=function('lh#cpp#brackets#lt') -visual=0
```

**Note:** This feature has been completely rewritten for the version 1.0.0 of map-tools. The old way of tuning the brackets insertion is no longer available.

By default, the [mappings are active for most filetypes](doc/default_brackets.md).

#### Brackets replacement

map-tools provides mappings (originally from auctex.vim) to replace a pair of bracket-characters by another pair of bracket-characters. See `:h brackets_manipulations` for more information.

### The Vim library

As [lh-vim-lib](http://github.com/LucHermitte/lh-vim-lib), map-tools provides a few functions of its own. All these functions are specialized into the definition of smart abbreviations and INSERT-mode mappings.

| Function                                      | Purpose                                                                                                                    |
|:----------------------------------------------|:---------------------------------------------------------------------------------------------------------------------------|
| `lh#map#no_context()`, `lh#map#no_context2()` | Core functions to define mappings that only expand outside of _string_, _comment_, and _character_ contexts                |
| `lh#map#4_these_contexts()`                   | Like `lh#map#no_context()`, except this time we can specify which text must be returned depending on the current context   |
| `lh#map#insert_around_visual()`               | This is the core surrounding function ; the surrounding text is not interpreted                                            |
| `lh#map#surround()`                           | Interprets the `!.*!` mappings that are passed to `lh#map#insert_around_visual()` (`!cursorhere!` tells were to put the cursor). This function also recognises when the selected area is actually a marker/placeholder in order to not surround, but expand instead. |
| `lh#map#build_map_seq()`                      | Core function that interprets `!.*!` mappings                                                                              |
| `lh#map#eat_char()`, `:I(nore)abbr`           | Permits to define abbreviations that do not insert a whitespace when the `<space>` key is used to trigger the abbreviation |
| `lh#map#insert_seq()`                         | High level function that interprets `!.*!` mappings, and take the context into account                                     |


# Installation
  * Requirements: Vim 7.+ (7.4-849 in order to support redo), [lh-vim-lib](http://github.com/LucHermitte/lh-vim-lib) v4.0.0+, [lh-style](http://github.com/LucHermitte/lh-style) v1.0.0+ for unit testing.
  * With [vim-addon-manager](https://github.com/MarcWeber/vim-addon-manager), install lh-brackets (this is the preferred method because of the dependencies)
```vim
ActivateAddons lh-brackets
```
  * or with [vim-flavor](https://github.com/kana/vim-flavor) (which also support dependencies)
```
flavor 'LucHermitte/lh-brackets'
```
  * or you can clone the git repositories
```bash
git clone git@github.com:LucHermitte/lh-vim-lib.git
git clone git@github.com:LucHermitte/lh-brackets.git
```
  * or with Vundle/NeoBundle:
```vim
Bundle 'LucHermitte/lh-vim-lib'
Bundle 'LucHermitte/lh-brackets'
```

## Credits
  * This bracketing system is actually a variation on [Stephen Riehm's original bracketing system](http://mywebpage.netscape.com/bbenjif/vim/Riehm/doc/) ;
  * The brackets manipulation comes from Saul Lubkin code, also present in [auctex.vim](http://www.vim.org/scripts/script.php?script_id=162) ;
  * Using SELECT-mode when reaching a placeholder was a suggestion from Gergely Kontra.

## See also
  * [imaps.vim, from LaTeX-suite](http://www.vim.org/scripts/script.php?script_id=475), with which map-tools is compatible (there is no conflictual mappings if both are installed) ;
  * All the [brackets related tips on vim.wikia](http://vim.wikia.com/wiki/Category:Brackets) ;
  * Most of my ftplugins for examples of use, or more simply the [Python ftplugin](ftplugin/python/python_snippets.vim) shipped with lh-brackets.
  * [muTemplate](http://github.com/LucHermitte/mu-template), a template-files expander built on top of map-tools.
  * [surround plugin on SF](http://www.vim.org/scripts/script.php?script_id=1697)
