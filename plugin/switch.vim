if exists("g:loaded_switch") || &cp
  finish
endif

let g:loaded_switch = '0.1.1' " version number
let s:keepcpo = &cpo
set cpo&vim

let g:switch_builtins =
      \ {
      \   'ampersands': ['&&', '||'],
      \   'capital_true_false': {
      \     '\CTrue':  'False',
      \     '\CFalse': 'True',
      \   },
      \   'true_false': {
      \     '\Ctrue':  'false',
      \     '\Cfalse': 'true',
      \   },
      \   'ruby_hash_style': {
      \     ':\(\k\+\)\s*=>\s*': '\1: ',
      \     '\<\(\k\+\): ':      ':\1 => ',
      \   },
      \   'ruby_if_clause': {
      \     'if true or (\(.*\))':          'if false and (\1)',
      \     'if false and (\(.*\))':        'if \1',
      \     'if \%(true\|false\)\@!\(.*\)': 'if true or (\1)',
      \   },
      \   'ruby_tap': {
      \     '\.\%(tap\)\@!\(\k\+\)':   '.tap { |o| puts o.inspect }.\1',
      \     '\.tap { |o| \%(.\{-}\) }': '',
      \   },
      \   'ruby_string': {
      \     '"\(\k\+\)"':                '''\1''',
      \     '''\(\k\+\)''':              ':\1',
      \     ':\(\k\+\)\@>\%(\s*=>\)\@!': '"\1"\2',
      \   },
      \   'ruby_short_blocks': {
      \     '\(\k\+\)(&:\(\S\+\))':                   '\1 { |x| x\.\2 }',
      \     '\(\k\+\)\s\={ |\(\k\+\)| \2.\(\S\+\) }': '\1(&:\3)',
      \   },
      \   'ruby_array_shorthand': {
      \     '\[\%(\k\|[''", ]\)\+\]': {
      \       '\[':                    '%w(',
      \       '[''"]\(\k\+\)[''"],\=': '\1',
      \       ']':                     ')',
      \     },
      \     '%w(\%(\k\|\s\)\+)': {
      \       '%w(':      '[',
      \       '\(\k\+\) ': '''\1'', ',
      \       '\(\k\+\))': '''\1'']',
      \     },
      \   },
      \   'rspec_should': ['should ', 'should_not '],
      \   'rspec_be_true_false': ['be_true', 'be_false'],
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
      \   g:switch_builtins.ampersands,
      \   g:switch_builtins.capital_true_false,
      \   g:switch_builtins.true_false,
      \ ]

autocmd FileType eruby let b:switch_definitions =
      \ [
      \   g:switch_builtins.eruby_if_clause,
      \   g:switch_builtins.eruby_tag_type,
      \   g:switch_builtins.ruby_hash_style,
      \   g:switch_builtins.ruby_string,
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
      \   g:switch_builtins.rspec_be_true_false,
      \   g:switch_builtins.ruby_tap,
      \   g:switch_builtins.ruby_string,
      \   g:switch_builtins.ruby_short_blocks,
      \   g:switch_builtins.ruby_array_shorthand,
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

  if !exists('g:switch_no_builtins')
    let definitions = extend(definitions, g:switch_definitions)
  endif

  if exists('g:switch_custom_definitions')
    call extend(definitions, g:switch_custom_definitions)
  endif

  if exists('b:switch_definitions') && !exists('b:switch_no_builtins')
    call extend(definitions, b:switch_definitions)
  endif

  if exists('b:switch_custom_definitions')
    call extend(definitions, b:switch_custom_definitions)
  endif

  call switch#Switch(definitions)
  silent! call repeat#set(":Switch\<cr>")
endfunction

let &cpo = s:keepcpo
unlet s:keepcpo
