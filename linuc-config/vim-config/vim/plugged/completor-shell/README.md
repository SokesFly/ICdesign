# completor-shell
- for [completor.vim](https://github.com/maralla/completor.vim.git).
- You can add some complete functions with shell command

## Sample

```
" let g:completor_shell#shell_commands = {
" \   'swift': ["grep '^${token}' /foo/bar/dict/${filetype}.dict"],
" \ }

```

- grep keywords from a dictionary file

## Parameters

- `${token}`
    - The keyword being entered
    - `\k\+$`
    - with [iskeyword](http://vimdoc.sourceforge.net/htmldoc/options.html#'iskeyword')

- `${filetype}`
    - The filetype of the current buffer
    - `&filetype`
    - [filetype](http://vimdoc.sourceforge.net/htmldoc/options.html#'filetype')
