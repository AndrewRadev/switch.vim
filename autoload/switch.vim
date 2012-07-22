let s:type_list = type([])
let s:type_dict = type({})

function! switch#Switch(definitions)
  try
    let saved_cursor = getpos('.')
    let line         = getline('.')

    for definition in a:definitions
      let switch_type = definition[0]
      let mapping     = s:CanonicalMapping(definition[1])

      for [pattern, replacement] in items(mapping)
        if line =~ pattern
          let pattern      = escape(pattern, '/')
          let substitution = escape(replacement, '/&')

          exe 's/'.pattern.'/'.substitution.'/'
          return 1
        endif
      endfor
    endfor

    return 0
  finally
    call setpos('.', saved_cursor)
  endtry
endfunction

function! s:CanonicalMapping(mapping)
  let mapping = a:mapping

  if type(mapping) == s:type_dict
    return mapping
  elseif type(mapping) == s:type_list
    let index = 0
    let len   = len(mapping)
    let dict  = {}

    for string in mapping
      let next_index = index + 1
      if next_index >= len
        let next_index = 0
      endif

      let pattern       = '\V'.string
      let substitution  = mapping[next_index]
      let dict[pattern] = substitution
      let index         = next_index
    endfor

    return dict
  endif
endfunction
