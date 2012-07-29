let s:type_list = type([])
let s:type_dict = type({})

function! switch#Switch(definitions)
  try
    let saved_cursor = getpos('.')

    for definition in a:definitions
      let mapping = s:CanonicalMapping(definition)

      for [pattern, replacement] in items(mapping)
        let [match_start, match_end] = s:Match(pattern)

        if match_start > 0
          let pattern = s:LimitPatternToColumns(pattern, match_start, match_end)
          call s:Replace(pattern, replacement)
          return 1
        endif
      endfor

      unlet definition
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

      let pattern       = '\V'.string.'\m'
      let replacement   = mapping[next_index]
      let dict[pattern] = replacement
      let index         = next_index
    endfor

    return dict
  endif
endfunction

function! s:Match(pattern)
  try
    let saved_cursor = getpos('.')
    let [_buf, lnum, col, _off] = saved_cursor

    call search(a:pattern, 'bcW', line('.'))
    if search(a:pattern, 'cW', line('.')) <= 0
      return [-1, -1]
    endif

    let match_start = col('.')
    call search(a:pattern, 'cWe', line('.'))
    let match_end = col('.')

    if match_start > col || match_end < col
      return [-1, -1]
    else
      return [match_start, match_end]
    endif
  finally
    call setpos('.', saved_cursor)
  endtry
endfunction

function! s:Replace(pattern, replacement)
  let pattern     = escape(a:pattern, '/')
  let replacement = escape(a:replacement, '/&')

  exe 's/'.pattern.'/'.replacement.'/'
  return 1
endfunction

function! s:LimitPatternToColumns(pattern, start, end)
  if a:start == 1
    let pattern = '^'.a:pattern
  else
    let pattern = '\%>'.(a:start - 1).'c'.a:pattern
  endif

  if a:end >= col('$') - 2
    let pattern = a:pattern.'$'
  else
    let pattern = pattern.'\%<'.(a:end + 2).'c'
  endif

  return pattern
endfunction
