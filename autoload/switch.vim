let s:type_list = type([])
let s:type_dict = type({})

function! switch#Switch(definitions)
  try
    let saved_cursor = getpos('.')

    for definition in a:definitions
      let switch_type = definition[0]
      let mapping     = s:CanonicalMapping(definition[1])

      for [pattern, replacement] in items(mapping)
        if s:Matches(switch_type, pattern)
          call s:Replace(switch_type, pattern, replacement)
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
      let replacement   = mapping[next_index]
      let dict[pattern] = replacement
      let index         = next_index
    endfor

    return dict
  endif
endfunction

function! s:Matches(replacement_type, pattern)
  let line = getline('.')

  return (line =~ a:pattern)
endfunction

function! s:Replace(replacement_type, pattern, replacement)
  let pattern     = escape(a:pattern, '/')
  let replacement = escape(a:replacement, '/&')

  exe 's/'.pattern.'/'.replacement.'/'
  return 1
endfunction
