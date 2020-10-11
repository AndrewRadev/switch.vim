if !exists("g:loaded_switch")
  finish
endif

if &ft == 'eruby'
  " could happen, depending on load order
  finish
endif

let b:switch_definitions =
      \ [
      \   g:switch_builtins.ruby_hash_style,
      \   g:switch_builtins.ruby_oneline_hash,
      \   g:switch_builtins.ruby_lambda,
      \   g:switch_builtins.ruby_if_clause,
      \   g:switch_builtins.rspec_should,
      \   g:switch_builtins.rspec_expect,
      \   g:switch_builtins.rspec_to,
      \   g:switch_builtins.rspec_be_truthy_falsey,
      \   g:switch_builtins.ruby_string,
      \   g:switch_builtins.ruby_short_blocks,
      \   g:switch_builtins.ruby_array_shorthand,
      \   g:switch_builtins.ruby_fetch,
      \   g:switch_builtins.ruby_assert_nil
      \ ]
