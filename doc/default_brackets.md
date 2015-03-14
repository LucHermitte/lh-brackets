### Brackets mappings

| In mode                 | INSERT               | VISUAL                                 | NORMAL     |
|:------------------------|:---------------------|:---------------------------------------|:-----------|
| **keys**                | Expands into ..      | Surrounds the selection with ... <sup>2</sup> | Surrounds the current ... |
| `(`                     | `(<cursor>)«»`     | `(<selection>)`                        | word       |
| `[`                     | `[<cursor>]«»`     | <sup>1</sup>                                  | <sup>1</sup>  |
| `<leader>[`             |                      | `[<selection>]`                        | word       |
| `{`                     | `{<cursor>}«»`<sup>3</sup>  | `{<selection>}`                        | word       |
| `<leader>{`             |                      | `{\n<selection>\n}«»`                | line       |
| `"` (1 double quote)    | `"<cursor>"«»`     | <sup>1</sup>                                  | <sup>1</sup>  |
| `""`                    |                      | `"<selection>"`                        | word       |
| `'`                     | `'<cursor>'«»`<sup>4</sup>  | <sup>1</sup>                                  | <sup>1</sup>  |
| `''` (2 single quotes)  |                      | `'<selection>'`                        | word       |
| `<leader><`             |                      | `<<selection>>`                        | word       |

#### Notes:
  * <sup>1</sup> Not defined to avoid hijacking default vim key bindings.
  * <sup>2</sup> The visual mode mappings do not surround the current marker/placeholder selected, but trigger the INSERT-mode mappings instead.
  * <sup>3</sup> The exact behavior of this mapping has changed with release r719 (on Google Code). Now, no newline is inserted by default. However, hitting `<cr>` in the middle of a pair of curly-bracket will expand into `{\n<cursor>\n}`.
  * <sup>4</sup> This mapping is neutralized for text filetypes -- the list of text-filetypes is defined in [`lh#ft#is\_text()`](http://github.com/LucHermitte/lh-vim-lib)
  * `«»` represents a marker/placeholder, it may be expanded with other characters like `<++>` depending on your preferences.
  * These mappings can be disabled from the `.vimrc` by setting `g:cb_no_default_brackets` to 1 (default: 0)
