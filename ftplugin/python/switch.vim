if !exists("g:loaded_switch")
  finish
endif

let b:switch_definitions =
      \ [
      \   g:switch_builtins.python_dict_get,
      \   g:switch_builtins.python_string_style,
      \   g:switch_builtins.python_dict_style,
      \ ]
