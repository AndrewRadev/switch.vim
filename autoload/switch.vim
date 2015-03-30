function! switch#Switch(definitions)
  silent! normal! zO

  try
    let saved_cursor = getpos('.')
    let min_match    = switch#match#Null()

    for definition in a:definitions
      let mapping = switch#mapping#New(definition)
      let match   = mapping.Match()

      if !match.IsNull()
        if g:switch_find_smallest_match
          if match.IsBetter(min_match)
            let min_match = match
          endif
        else
          " no point in continuing
          let min_match = match
          break
        endif
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
