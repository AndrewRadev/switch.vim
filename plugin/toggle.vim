if exists("g:loaded_toggle") || &cp
  finish
endif

let g:loaded_toggle = '0.0.1' " version number
let s:keepcpo = &cpo
set cpo&vim

let g:toggle_definitions =
      \ [
      \   [ 'WORD', ['&&', '||'] ],
      \   [ 'word', ['true', 'false'] ],
      \ ]

autocmd FileType eruby let b:toggle_definitions =
      \ [
      \   [ 'line', {
      \     '<%= \(.*\) %>':    '<%# \1 %>',
      \     '<%# \(.*\) %>':    '<%=raw \1 %>',
      \     '<%=raw \(.*\) %>': '<%= \1 %>'
      \   }]
      \ ]

command! Toggle call s:Toggle()
function! s:Toggle()
  let definitions = extend([], g:toggle_definitions)

  if exists('b:toggle_definitions')
    call extend(definitions, b:toggle_definitions)
  endif

  call toggle#Toggle(definitions)
endfunction

let &cpo = s:keepcpo
unlet s:keepcpo
