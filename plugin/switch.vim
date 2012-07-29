if exists("g:loaded_switch") || &cp
  finish
endif

let g:loaded_switch = '0.0.1' " version number
let s:keepcpo = &cpo
set cpo&vim

let g:switch_definitions =
      \ [
      \   [ 'WORD', ['&&', '||'] ],
      \   [ 'word', ['true', 'false'] ],
      \ ]

autocmd FileType eruby let b:switch_definitions =
      \ [
      \   [ 'line', {
      \     '<%= \(.*\) %>':    '<%# \1 %>',
      \     '<%# \(.*\) %>':    '<%=raw \1 %>',
      \     '<%=raw \(.*\) %>': '<%= \1 %>'
      \   }]
      \ ]

autocmd FileType ruby let b:switch_definitions =
      \ [
      \   ['word', {
      \       ':\(\k\+\)\s\+=>': '\1:',
      \       '\<\(\k\+\):':     ':\1 =>',
      \     }
      \   ],
      \   [ 'word', ['should ', 'should_not '] ]
      \ ]

command! Switch call s:Switch()
function! s:Switch()
  let definitions = extend([], g:switch_definitions)

  if exists('b:switch_definitions')
    call extend(definitions, b:switch_definitions)
  endif

  call switch#Switch(definitions)
endfunction

let &cpo = s:keepcpo
unlet s:keepcpo
