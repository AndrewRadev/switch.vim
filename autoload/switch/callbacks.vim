function! switch#callbacks#RustVarType(match)
  let match = a:match
  let text = strpart(getline('.'), match.start - 1, match.end)

  " text should be of the form `let x = `
  let text = substitute(text, match.pattern, '\1: () = ', '')
  call switch#util#ReplaceCols(match.start, match.end, text)

  " enter select mode
  call feedkeys("f(vl\<c-g>", 'n')
endfunction
