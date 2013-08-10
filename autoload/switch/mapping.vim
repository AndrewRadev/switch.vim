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
  return s:NewDictMapping(s:MakeDict(a:definition))
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

" One of the central algorithms in the plugin, takes care of finding the start
" and end of a match in the buffer.
"
" Note that the start of the pattern is its first character, while the end is
" the next character that is not a part of the match, or the end of the line
" (`col('$')`).
"
" Returns a Match object with data for the match. Returns a null match if the
" pattern is not found or the cursor is not in it.
"
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
      let match_end = col('.')

      " set the end of the pattern to the next character, or EOL. Extra logic
      " is for multibyte characters. The 'whichwrap' option is reset to the
      " default in order to avoid "l" wrapping around.
      let original_whichwrap = &whichwrap
      set whichwrap&vim
      normal! l
      if col('.') == match_end
        " no movement, we must be at the end
        let match_end = col('$')
      else
        let match_end = col('.')
      endif
      let &whichwrap = original_whichwrap

      if match_start > col || match_end <= col
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

" Replaces the pattern from the match data with its replacement. Takes care of
" both simple replacements and nested ones.
"
function! switch#mapping#Replace(match) dict
  let pattern     = a:match.pattern
  let replacement = self.definitions[pattern]

  if type(replacement) == s:type_dict
    " maintain change delta for adjusting match limits
    let delta = 0

    for [pattern, sub_replacement] in items(replacement)
      let last_column     = col('$')
      let pattern         = s:LimitPattern(pattern, a:match.start, a:match.end + delta)
      let pattern         = escape(pattern, '/')
      let sub_replacement = escape(sub_replacement, '/&')

      silent! foldopen!
      exe 's/'.pattern.'/'.sub_replacement.'/ge'

      " length of the line may have changed, adjust
      let delta += col('$') - last_column
    endfor
  else
    let pattern     = s:LimitPattern(pattern, a:match.start, a:match.end)
    let pattern     = escape(pattern, '/')
    let replacement = escape(replacement, '/&')

    exe 's/'.pattern.'/'.replacement.'/'
  endif
endfunction

" Private:
" ========

" Transforms the given list of words to a dictionary mapping. This function
" may be removed if the word-list logic starts to differ significantly from
" the pattern-replacement-dict one.
"
function! s:MakeDict(mapping)
  let mapping = a:mapping
  let index   = 0
  let len     = len(mapping)
  let dict    = {}

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
endfunction

" Limits the given pattern to only work in the given [start, end) interval by
" anchoring it to these column positions.
"
function! s:LimitPattern(pattern, start, end)
  let pattern = a:pattern

  if a:start > 1
    let pattern = '\%>'.(a:start - 1).'c'.pattern
  endif

  if a:end > 1 && a:end < col('$')
    let pattern = pattern.'\%<'.(a:end + 1).'c'
  endif

  return pattern
endfunction
