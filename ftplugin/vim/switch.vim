if !exists("g:loaded_switch")
  finish
endif

let b:switch_definitions =
      \ [
      \   g:switch_builtins.vim_script_local_function,
      \   g:switch_builtins.vim_string_style,
      \ ]
