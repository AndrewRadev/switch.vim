let s:type_list = type([])
let s:type_dict = type({})

function! switch#Switch(definitions)
  try
    let saved_cursor = getpos('.')

    for definition in a:definitions
      let switch_type = definition[0]
      let mapping     = s:CanonicalMapping(definition[1])

      for [pattern, replacement] in items(mapping)
        let pattern = s:LimitPatternByType(pattern, switch_type)

        if s:Matches(pattern)
          call s:Replace(pattern, replacement)
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

      let pattern       = '\V'.string.'\m'
      let replacement   = mapping[next_index]
      let dict[pattern] = replacement
      let index         = next_index
    endfor

    return dict
  endif
endfunction

function! s:LimitPatternByType(pattern, type)
  let pattern                    = a:pattern
  let type                       = a:type
  let [_bufnum, lnum, col, _off] = getpos('.')
  let line                       = getline('.')

  if type == 'word'
    let [word_start, word_end] = s:LineSegmentCoordinates(expand('<cword>'))
    let pattern = s:LimitPatternToColumns(pattern, word_start - 1, word_end + 2)
  elseif type == 'WORD'
    let [word_start, word_end] = s:LineSegmentCoordinates(expand('<cWORD>'))
    let pattern = s:LimitPatternToColumns(pattern, word_start - 1, word_end + 2)
  end

  return pattern
endfunction

function! s:Matches(pattern)
  try
    let saved_cursor = getpos('.')
    call cursor(line('.'), 1)

    return (search(a:pattern, 'nW', line('.')) > 0)
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

function! s:LineSegmentCoordinates(word)
  let word   = a:word
  let line   = getline('.')
  let cursor = col('.')

  let first_part  = strpart(line, 0, cursor - 1)
  let second_part = strpart(line, cursor - 1)

  let start = len(substitute(first_part, '\w\+$', '', '')) + 1
  let end   = start + len(word) - len(substitute(second_part, '^\w\+', '', ''))

  return [start, end]
endfunction

function! s:LimitPatternToColumns(pattern, start, end)
  return '\%>'.a:start.'c'.a:pattern.'\%<'.a:end.'c'
endfunction
