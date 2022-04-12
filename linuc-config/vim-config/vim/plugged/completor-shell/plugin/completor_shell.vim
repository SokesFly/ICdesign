if exists('g:loaded_completor_shell_plugin')
  finish
endif

let g:loaded_completor_shell_plugin = 1

" samples
"
" ${token} -> token
" ${filetype} -> filetype
"
" let g:completor_shell#shell_commands = {
" \   'swift': ["grep '^${token}' ${filetype}.dict"],
" \ }

if !exists('g:completor_shell#shell_commands')
  let g:completor_shell#shell_commands = {}
endif

let s:py = has('python3') ? 'py3' : 'py'

function! s:err(msg)
  echohl Error
  echo a:msg
  echohl NONE
endfunction

function! s:import_python()
  try
    exe s:py 'import completor, completers.common'
  catch /^Vim(py\(thon\|3\)):/
    call s:err('Fail to import completor')
    return
  endtry

  try
    exe s:py 'import completor_shell'
  catch /^Vim(py\(thon\|3\)):/
    call s:err('Fail to import completor_shell')
    return
  endtry

  try
    exe s:py 'completor.get("common").hooks.append(completor_shell.Shell.filetype)'
  catch /^Vim(py\(thon\|3\)):/
    call s:err('Fail to add shell hook')
  endtry
endfunction

function! s:enable()
  call s:import_python()
  call s:disable()
endfunction

function! s:disable()
  augroup completor_shell
    autocmd!
  augroup END
endfunction

augroup completor_shell
  autocmd!
  autocmd InsertEnter * call s:enable()
augroup END
