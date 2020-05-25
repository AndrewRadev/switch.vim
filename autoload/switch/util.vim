" Similar to map(<list>, <expr>), but flattens the results one level. Expects
" that every result coming out of <expr> is a list.
"
function! switch#util#FlatMap(list, expr)
  let result = []

  for entry in map(a:list, a:expr)
    let result += entry
  endfor

  return result
endfunction

" Capitalize first letter of argument:
" foo -> Foo
function! switch#util#Capitalize(word)
  return substitute(a:word, '^\w', '\U\0', 'g')
endfunction

" function! switch#util#ReplaceMotion(motion, text) {{{2
"
" Replace the normal mode "motion" with "text". This is mostly just a wrapper
" for a normal! command with a paste, but doesn't pollute any registers.
"
"   Examples:
"     call switch#util#ReplaceMotion('Va{', 'some text')
"     call switch#util#ReplaceMotion('V', 'replacement line')
"
" Note that the motion needs to include a visual mode key, like "V", "v" or
" "gv"
function! switch#util#ReplaceMotion(motion, text)
  " reset clipboard to avoid problems with 'unnamed' and 'autoselect'
  let saved_clipboard = &clipboard
  set clipboard=

  let saved_register_text = getreg('"', 1)
  let saved_register_type = getregtype('"')

  call setreg('"', a:text, 'v')
  exec 'silent normal! '.a:motion.'p'
  silent normal! gv=

  call setreg('"', saved_register_text, saved_register_type)
  let &clipboard = saved_clipboard
endfunction

" function! switch#util#ReplaceLines(start, end, text) {{{2
"
" Replace the area defined by the 'start' and 'end' lines with 'text'.
function! switch#util#ReplaceLines(start, end, text)
  let interval = a:end - a:start

  if interval == 0
    return switch#util#ReplaceMotion(a:start.'GV', a:text)
  else
    return switch#util#ReplaceMotion(a:start.'GV'.interval.'j', a:text)
  endif
endfunction

" function! switch#util#ReplaceCols(start, end, text) {{{2
"
" Replace the area defined by the 'start' and 'end' columns on the current
" line with 'text'
function! switch#util#ReplaceCols(start, end, text)
  let start_position = getpos('.')
  let end_position   = getpos('.')

  let start_position[2] = a:start
  let end_position[2]   = a:end

  return switch#util#ReplaceByPosition(start_position, end_position, a:text)
endfunction

" function! switch#util#ReplaceByPosition(start, end, text) {{{2
"
" Replace the area defined by the 'start' and 'end' positions with 'text'. The
" positions should be compatible with the results of getpos():
"
"   [bufnum, lnum, col, off]
"
function! switch#util#ReplaceByPosition(start, end, text)
  let saved_z_pos = getpos("'z")

  try
    call setpos('.', a:start)
    call setpos("'z", a:end)

    return switch#util#ReplaceMotion('v`z', a:text)
  finally
    call setpos("'z", saved_z_pos)
  endtry
endfunction
