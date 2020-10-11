if !exists("g:loaded_switch")
  finish
endif

let b:switch_definitions =
      \ [
      \   g:switch_builtins.coffee_arrow,
      \   g:switch_builtins.coffee_dictionary_shorthand,
      \ ]
