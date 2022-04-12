function! completor_shell#get_shell_commands()
  let ft = &filetype
  if !has_key(g:completor_shell#shell_commands, ft)
    return []
  endif

  return g:completor_shell#shell_commands[ft]
endfunction

function! completor_shell#adjust_token(raw)
  return matchstr(a:raw, '\k\+$')
endfunction
