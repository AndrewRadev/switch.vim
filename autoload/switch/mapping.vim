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
  for [pattern, replacement] in items(self.definitions)
    let [start, end, length] = s:Match(pattern)

    if length > 0
      return switch#match#New(self, pattern, start, end, length)
    endif
  endfor

  return switch#match#NewNull()
endfunction

function! switch#mapping#Replace(match) dict
  let pattern     = a:match.pattern
  let replacement = self.definitions[pattern]

  call s:Replace(pattern, replacement, a:match.start, a:match.end)
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

function! s:Match(pattern)
  try
    let saved_cursor = getpos('.')
    let [_buf, lnum, col, _off] = saved_cursor

    call search(a:pattern, 'bcW', line('.'))
    if search(a:pattern, 'cW', line('.')) <= 0
      return [-1, -1, -1]
    endif

    let match_start = col('.')
    call search(a:pattern, 'cWe', line('.'))

    " extra logic for multibyte characters
    if col('.') + 1 == col('$')
      let match_end = col('.')
    else
      normal! l
      let match_end = col('.')
    endif

    if match_start > col || match_end < col
      return [-1, -1, -1]
    else
      return [match_start, match_end, (match_end - match_start + 1)]
    endif
  finally
    call setpos('.', saved_cursor)
  endtry
endfunction

function! s:Replace(pattern, replacement, start, end)
  if type(a:replacement) == s:type_dict
    call s:ReplaceMultiple(a:replacement, a:start, a:end)
  else
    let pattern = s:LimitPattern(a:pattern, a:start, a:end)
    call s:ReplaceSimple(pattern, a:replacement, '')
  endif
endfunction

function! s:ReplaceSimple(pattern, replacement, flags)
  let pattern     = escape(a:pattern, '/')
  let replacement = escape(a:replacement, '/&')

  exe 's/'.pattern.'/'.replacement.'/'.a:flags
  return 1
endfunction

function! s:ReplaceMultiple(definitions, start, end)
  let changedtick = b:changedtick

  for [pattern, replacement] in items(a:definitions)
    let pattern = s:LimitPattern(pattern, a:start, a:end)
    call s:ReplaceSimple(pattern, replacement, 'ge')
  endfor
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
