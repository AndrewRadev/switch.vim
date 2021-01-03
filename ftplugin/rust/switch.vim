if !exists("g:loaded_switch")
  finish
endif

let b:switch_definitions =
      \ [
      \   g:switch_builtins.rust_is_some,
      \   g:switch_builtins.rust_assert,
      \   g:switch_builtins.rust_void_typecheck,
      \   g:switch_builtins.rust_turbofish,
      \   g:switch_builtins.rust_string,
      \   g:switch_builtins.coffee_dictionary_shorthand,
      \ ]
