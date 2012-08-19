if exists("g:loaded_switch") || &cp
  finish
endif

let g:loaded_switch = '0.0.1' " version number
let s:keepcpo = &cpo
set cpo&vim

let g:switch_builtins =
      \ {
      \   'ruby_hash_style': {
      \     ':\(\k\+\)\s\+=>': '\1:',
      \     '\<\(\k\+\):':     ':\1 =>',
      \   },
      \   'ruby_if_clause': {
      \     'if true or (\(.*\))':          'if false and (\1)',
      \     'if false and (\(.*\))':        'if \1',
      \     'if \%(true\|false\)\@!\(.*\)': 'if true or (\1)',
      \   },
      \   'ruby_tap': {
      \     '\.\%(tap\)\@!\(\k\+\)':        '.tap { |o| puts o.inspect }.\1',
      \     '\.tap { |o| puts o.inspect }': '',
      \   },
      \   'rspec_should': ['should ', 'should_not '],
      \   'eruby_if_clause': {
      \     '<% if true or (\(.*\)) %>':          '<% if false and (\1) %>',
      \     '<% if false and (\(.*\)) %>':        '<% if \1 %>',
      \     '<% if \%(true\|false\)\@!\(.*\) %>': '<% if true or (\1) %>',
      \   },
      \   'eruby_tag_type': {
      \     '<%= \(.*\) %>':    '<% \1 %>',
      \     '<% \(.*\) -\?%>':  '<%# \1 %>',
      \     '<%# \(.*\) %>':    '<%=raw \1 %>',
      \     '<%=raw \(.*\) %>': '<%= \1 %>',
      \   },
      \   'php_echo': {
      \     '<?php echo \(.\{-}\) ?>':        '<?php \1 ?>',
      \     '<?php \%(echo\)\@!\(.\{-}\) ?>': '<?php echo \1 ?>',
      \   },
      \   'cpp_pointer': {
      \     '\(\k\+\)\.': '\1->',
      \     '\(\k\+\)->': '\1.',
      \   },
      \   'coffee_arrow': {
      \     '^\(.*\)->': '\1=>',
      \     '^\(.*\)=>': '\1->',
      \   },
      \ }

let g:switch_definitions =
      \ [
      \   ['&&', '||'],
      \   ['true', 'false'],
      \ ]

autocmd FileType eruby let b:switch_definitions =
      \ [
      \   g:switch_builtins.eruby_if_clause,
      \   g:switch_builtins.eruby_tag_type,
      \   g:switch_builtins.ruby_hash_style,
      \ ]

autocmd FileType php let b:switch_definitions =
      \ [
      \   g:switch_builtins.php_echo,
      \ ]

autocmd FileType ruby let b:switch_definitions =
      \ [
      \   g:switch_builtins.ruby_hash_style,
      \   g:switch_builtins.ruby_if_clause,
      \   g:switch_builtins.rspec_should,
      \   g:switch_builtins.ruby_tap,
      \ ]

autocmd FileType cpp let b:switch_definitions =
      \ [
      \   g:switch_builtins.cpp_pointer,
      \ ]

autocmd FileType coffee let b:switch_definitions =
      \ [
      \   g:switch_builtins.coffee_arrow,
      \ ]

command! Switch call s:Switch()
function! s:Switch()
  let definitions = []
  let definitions = extend(definitions, g:switch_definitions)

  if exists('b:switch_definitions')
    call extend(definitions, b:switch_definitions)
  endif

  call switch#Switch(definitions)
endfunction

let &cpo = s:keepcpo
unlet s:keepcpo
