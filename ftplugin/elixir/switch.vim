if !exists("g:loaded_switch")
  finish
endif

let b:switch_definitions =
      \ [
      \   g:switch_builtins.ruby_string,
      \   g:switch_builtins.elixir_list_shorthand
      \ ]
