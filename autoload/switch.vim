function! switch#Switch(definitions)
  silent! normal! zO

  try
    let saved_cursor = getpos('.')
    let min_match    = switch#match#Null()

    for definition in a:definitions
      let mapping = switch#mapping#New(definition)
      let match   = mapping.Match()

      " TODO figure out why IsNull is needed here
      if !match.IsNull() && match.IsBetter(min_match)
        let min_match = match
      endif

      unlet definition
    endfor

    if !min_match.IsNull()
      call min_match.Replace()
      return 1
    else
      return 0
    endif
  finally
    call setpos('.', saved_cursor)
  endtry
endfunction
