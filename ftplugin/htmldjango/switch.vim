if !exists("g:loaded_switch")
  finish
endif

let b:switch_definitions =
      \ [
      \   g:switch_builtins.jinja_tag_type,
      \ ]
