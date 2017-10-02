## Default bracket mappings

By default, lh-brackets comes with a few ready-to-use mappings:
 * some are [global](#global-mappings) and apply to all filetypes,
 * other are specialized for various filetypes:
   * [C and C++](#c-and-c-mappings)
   * [HTML](#html-mappings)
   * [Javascript](#javascript-mappings)
   * [Markdown](#markdown-mappings)
   * [Perl](#perl-mappings)
   * [Ruby](#ruby-mappings)
   * [(La)TeX](#latex-mappings)
   * [VimL](#viml-mappings)


### Global mappings

The following mappings apply to all filetypes (unless specified otherwise, or specialized).

| in mode                 | insert                      | visual                                        | normal                    |
|:------------------------|:----------------------------|:----------------------------------------------|:--------------------------|
| **keys**                | expands into ..             | surrounds the selection with ... <sup>2</sup> | surrounds the current ... |
| `(`                     | `(<cursor>)«»`              | `(<selection>)`                               | word                      |
| `[`                     | `[<cursor>]«»`              | <sup>1</sup>                                  | <sup>1</sup>              |
| `[` after a `[`         | `[[<cursor>]]«»`            | n/a                                           | n/a                       |
| `]` before `]]`         | close all `]]`              | n/a                                           | n/a                       |
| `<leader>[`             |                             | `[<selection>]`                               | word                      |
| `{`                     | `{<cursor>}«»`<sup>3</sup>  | `{<selection>}`                               | word                      |
| `<leader>{`             |                             | `{\n<selection>\n}«»`                         | line                      |
| `"` (1 double quote)    | `"<cursor>"«»`              | <sup>1</sup>                                  | <sup>1</sup>              |
| `""`                    |                             | `"<selection>"`                               | word                      |
| `'`                     | `'<cursor>'«»`<sup>4</sup>  | <sup>1</sup>                                  | <sup>1</sup>              |
| `''` (2 single quotes)  |                             | `'<selection>'`                               | word                      |
| `<leader><`             |                             | `<<selection>>`                               | word                      |

#### Notes:
  * <sup>1</sup> Not defined to avoid hijacking default vim key bindings.
  * <sup>2</sup> The visual mode mappings do not surround the current marker/placeholder selected, but trigger the INSERT-mode mappings instead.
  * <sup>3</sup> The exact behavior of this mapping has changed with release r719 (on Google Code). Now, no newline is inserted by default. However, hitting `<cr>` in the middle of a pair of curly-bracket will expand into `{\n<cursor>\n}`.
  * <sup>4</sup> This mapping is neutralized for text filetypes -- the list of text-filetypes is defined in [`lh#ft#is_text()`](http://github.com/LucHermitte/lh-vim-lib)
  * `«»` represents a marker/placeholder, it may be expanded with other characters like `<++>` depending on your preferences.
  * These mappings can be disabled from the `.vimrc` by setting `g:cb_no_default_brackets` to 1 (default: 0)

### C and C++ mappings

See [lh-cpp documentation](https://github.com/LucHermitte/lh-cpp#brackets) for the complete mappings table.

The main differences from the global table are:
 * `<` will result in `<<cursor>>` if it follows `#include`, `template`,
   `typename` or `_cast`.
 * `{` on the same line of a `struct` or `class` will result in `{<cursor>};`.
 *  In visual mode, `<localleader>{` surrounds the selection with a pair of
    curly brackets (and newlines are introduced).
 * `<tt>` is recognized as an opening bracket (I use it a lot to write Doxygen
   _code_ instead of `\c` when I need to type several things).
 * `;` will try to close parenthesis -- set `(bpg):[{ft}_]semicolon_closes_bracket` to 0 to inhibit this setting.
 * `<bs>` take care of semi-colons after the closing curly-bracket -- set `(bpg):[{ft}_]semicolon_closes_bracket` to 0 to inhibit this setting.

### HTML mappings

The main differences from the global table are:
 * Typing `<` twice results in `&lt;`, and `<>` results in `&gt;`.
 *  In visual mode, `<localleader><` surrounds the selection with a pair of
    angle brackets.

### Javascript mappings
The main differences from the global table are:
 *  In visual mode, `<localleader>{` surrounds the selection with a pair of
    curly brackets (and newlines are introduced).

### Markdown mappings
New mappings are avaible.

| in mode                 | insert                          | visual                                        | normal                    |
|:------------------------|:--------------------------------|:----------------------------------------------|:--------------------------|
| **keys**                | expands into ..                 | surrounds the selection with ... <sup>2</sup> | surrounds the current ... |
| `_`                     | `_<cursor>_<++>` <sup>3</sup>   | `_<selection>_`                               | word                      |
| `_` after a `_`         | `__<cursor>__<++>`              | n/a                                           | n/a                       |
| `*`                     | `*<cursor>*<++>` <sup>3,4</sup> | `*<selection>*`                               | word                      |
| `*` after a `*`         | `**<cursor>**<++>`              | n/a                                           | n/a                       |
| `` ` ``                 | `` `<cursor>`<++>``             | `` `<selection>` ``                           | word                      |
| `~`                     | `<del><cursor></del>«»`         | <sup>1</sup>                                  | <sup>1</sup>              |
| `<localleader>~`        |                                 | `<del><cursor></del>`                         | word                      |

#### Notes:
  * <sup>1</sup> Not defined to avoid hijacking default vim key bindings.
  * <sup>2</sup> The visual mode mappings do not surround the current marker/placeholder selected, but trigger the INSERT-mode mappings instead.
  * <sup>3</sup> Within a pair of backquotes (_code_ marker), formatting pairs
    are not expanded
  * <sup>4</sup> Right after spaces at the beginning of the line, `*` is not
    expanded: it will serve to start a new point in a bullet-list.
  * `<bs>` has been updated to handle the new pairs of brackets.

### Perl mappings
The main differences from the global table are:
 *  In visual mode, `<localleader>{` surrounds the selection with a pair of
    curly brackets (and newlines are introduced).
 *  In visual mode, `<localleader><` surrounds the selection with a pair of
    angle brackets.

### Ruby mappings
 * In normal mode, `<C-X>{` replace `begin`-`end` block by `{-}`, or the other
   way around.

### (La)TeX mappings
New and specialized mappings are avaible.

| in mode                 | insert                      | visual                                        | normal                    |
|:------------------------|:----------------------------|:----------------------------------------------|:--------------------------|
| **keys**                | expands into ..             | surrounds the selection with ... <sup>2</sup> | surrounds the current ... |
| `(`                     | `(<cursor>)<++>`            | `(<selection>)`                               | word                      |
| `(` after a `\`         | `\(<cursor>\)<++>`          | n/a                                           | n/a                       |
| `{`                     | `{<cursor>}<++>`            | `{<selection>}`                               | word                      |
| `{` after a `\`         | `\{<cursor>\}<++>`          | n/a                                           | n/a                       |
| `[`                     | `[<cursor>]<++>`            | `[<selection>]`                               | word                      |
| `[` after a `\`         | `\[<cursor>\]<++>`          | n/a                                           | n/a                       |
| `<leader>[`             |                             | `[<selection>]`                               | word                      |
| `$`                     | `$<cursor>$<++>`            | <sup>1</sup>                                  | <sup>1</sup>              |
| `<leader>$`             |                             | `$<selection>$`                               | word                      |

#### Notes:
  * <sup>1</sup> Not defined to avoid hijacking default vim key bindings.
  * <sup>2</sup> The visual mode mappings do not surround the current marker/placeholder selected, but trigger the INSERT-mode mappings instead.
  *  In (La)TeX, `<++>` is used as a placeholder instead of `«»`.

### VimL mappings

New and specialized mappings are avaible.

| in mode                 | insert                      | visual                                        | normal                    |
|:------------------------|:----------------------------|:----------------------------------------------|:--------------------------|
| **keys**                | expands into ..             | surrounds the selection with ... <sup>2</sup> | surrounds the current ... |
| `(`                     | `(<cursor>)«»`              | `(<selection>)`                               | word                      |
| `(` after a `\`         | `\(<cursor>\)«»`            | n/a                                           | n/a                       |
| `<`                     | `<<cursor>>«»` <sup>5<sup>  | <sup>1</sup>                                  | <sup>1</sup>              |
| `<leader><`             |                             | `<<selection>>`                               | word                      |
| `"`                     | `"<cursor>"«»` <sup>6<sup>  | <sup>1</sup>                                  | <sup>1</sup>              |

#### Notes:
  * <sup>1</sup> Not defined to avoid hijacking default vim key bindings.
  * <sup>2</sup> The visual mode mappings do not surround the current marker/placeholder selected, but trigger the INSERT-mode mappings instead.
  * <sup>5</sup> except after an `if`, a `while`, or within comments. Still
    this rule knowns an exception: within a string, or after a `\`, `<` is
    always converted to `<>`.  Does not handle special characters like `'<` and
    `'>`
  * <sup>6</sup> except for comments
