let s:type_list = type([])
let s:type_dict = type({})

" Constructor:
" ============

function! switch#mapping#New(definition)
  if type(a:definition) == s:type_list
    return s:NewListMapping(a:definition)
  elseif type(a:definition) == s:type_dict
    return s:NewDictMapping(a:definition)
  endif
endfunction

function! s:NewListMapping(definition)
  return s:NewDictMapping(s:CanonicalMapping(a:definition))
endfunction

function! s:NewDictMapping(definition)
  let mapping = {
        \ 'definitions': a:definition,
        \
        \ 'Match':   function('switch#mapping#Match'),
        \ 'Replace': function('switch#mapping#Replace'),
        \ }

  return mapping
endfunction

" Methods:
" ========

function! switch#mapping#Match() dict
  let match_start  = -1
  let match_end    = -1
  let match_length = -1

  for [pattern, replacement] in items(self.definitions)
    try
      let saved_cursor = getpos('.')
      let [_buf, lnum, col, _off] = saved_cursor

      " try to find the pattern nearest to the cursor
      call search(pattern, 'bcW', lnum)
      if search(pattern, 'cW', lnum) <= 0
        " not found, try the next pattern
        continue
      endif
      let match_start = col('.')

      " find the end of the pattern
      call search(pattern, 'cWe', lnum)

      " apply extra logic for multibyte characters
      if col('.') + 1 == col('$')
        let match_end = col('.')
      else
        normal! l
        let match_end = col('.')
      endif

      if match_start > col || match_end < col
        " then the cursor is not in the pattern
        continue
      else
        " a match has been found
        return switch#match#New(self, pattern, match_start, match_end)
      endif
    finally
      call setpos('.', saved_cursor)
    endtry
  endfor

  " no match found, return a null match
  return switch#match#Null()
endfunction

function! switch#mapping#Replace(match) dict
  let pattern     = a:match.pattern
  let replacement = self.definitions[pattern]
  let pattern     = s:LimitPattern(pattern, a:match.start, a:match.end)

  if type(replacement) == s:type_dict
    for [pattern, sub_replacement] in items(replacement)
      let pattern         = escape(pattern, '/')
      let sub_replacement = escape(sub_replacement, '/&')

      exe 's/'.pattern.'/'.sub_replacement.'/ge'
    endfor
  else
    let pattern     = escape(pattern, '/')
    let replacement = escape(replacement, '/&')

    exe 's/'.pattern.'/'.replacement.'/'
  endif
endfunction

" Private:
" ========

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

function! s:LimitPattern(pattern, start, end)
  let pattern = a:pattern

  if a:start > 1
    let pattern = '\%>'.(a:start - 1).'c'.pattern
  endif

  if a:end > 1 && a:end < col('$') - 1
    let pattern = pattern.'\%<'.(a:end + 1).'c'
  endif

  return pattern
endfunction
