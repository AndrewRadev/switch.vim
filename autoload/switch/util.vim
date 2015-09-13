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
