if exists("g:loaded_switch") || &cp
  finish
endif

let g:loaded_switch = '0.0.1' " version number
let s:keepcpo = &cpo
set cpo&vim

let g:switch_definitions =
      \ [
      \   ['&&', '||'],
      \   ['true', 'false'],
      \ ]

autocmd FileType eruby let b:switch_definitions =
      \ [
      \   {
      \     '<%= \(.*\) %>':    '<%# \1 %>',
      \     '<%# \(.*\) %>':    '<%=raw \1 %>',
      \     '<%=raw \(.*\) %>': '<%= \1 %>',
      \   }
      \ ]

autocmd FileType ruby let b:switch_definitions =
      \ [
      \   {
      \     ':\(\k\+\)\s\+=>': '\1:',
      \     '\<\(\k\+\):':     ':\1 =>',
      \   },
      \   {
      \     'if true or (\(.*\))':   'if false and (\1)',
      \     'if false and (\(.*\))': 'if \1',
      \   },
      \   {
      \     'if \(.*\)': 'if true or (\1)',
      \   },
      \   ['should ', 'should_not '],
      \ ]

command! Switch call s:Switch()
function! s:Switch()
  let definitions = []

  if exists('b:switch_definitions')
    call extend(definitions, b:switch_definitions)
  endif

  let definitions = extend(definitions, g:switch_definitions)

  call switch#Switch(definitions)
endfunction

let &cpo = s:keepcpo
unlet s:keepcpo
