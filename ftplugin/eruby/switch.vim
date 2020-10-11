if !exists("g:loaded_switch")
  finish
endif

let b:switch_definitions =
      \ [
      \   g:switch_builtins.eruby_if_clause,
      \   g:switch_builtins.eruby_tag_type,
      \   g:switch_builtins.ruby_hash_style,
      \   g:switch_builtins.ruby_oneline_hash,
      \   g:switch_builtins.ruby_string,
      \ ]
