if !exists("g:loaded_switch")
  finish
endif

let b:switch_definitions =
      \ [
      \   g:switch_builtins.clojure_string,
      \   g:switch_builtins.clojure_if_clause,
      \ ]
