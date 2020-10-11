if !exists("g:loaded_switch")
  finish
endif

if expand('%:t') == 'Cargo.toml'
  let b:switch_definitions = [
        \ g:switch_builtins.cargo_dependency_version,
        \ ]
end
