if !exists("g:loaded_switch")
  finish
endif

let b:switch_definitions =
      \ [
      \   g:switch_builtins.javascript_function,
      \   g:switch_builtins.javascript_arrow_function,
      \   g:switch_builtins.javascript_es6_declarations,
      \ ]
