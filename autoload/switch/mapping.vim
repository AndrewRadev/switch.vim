let s:type_list = type([])
let s:type_dict = type({})
let s:type_func = type(function('tr'))

" Constructor:
" ============

function! switch#mapping#Process(definition, options)
  if type(a:definition) == s:type_list
    return s:ProcessListMapping(a:definition, a:options)
  elseif type(a:definition) == s:type_dict
    if has_key(a:definition, '_type') && has_key(a:definition, '_definition')
      if a:definition._type == 'default'
        return s:ProcessDictMapping(a:definition._definition)
      elseif a:definition._type == 'normalized_case'
        return s:ProcessModifierListMapping(a:definition._definition, {'case': 1, 'words': 0})
      elseif a:definition._type == 'words'
        return s:ProcessModifierListMapping(a:definition._definition, {'case': 0, 'words': 1})
      elseif a:definition._type == 'normalized_case_words'
        return s:ProcessModifierListMapping(a:definition._definition, {'case': 1, 'words': 1})
      else
        echomsg "Unknown definition type: ".a:definition._type
        return []
      endif
    else
      return s:ProcessDictMapping(a:definition)
    endif
  endif
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

  for [pattern, Replacement] in items(self.definitions)
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

      " set the end of the pattern to the next character, or EOL.
      "
      " whichwrap logic is for multibyte characters. The 'whichwrap' option is
      " reset to the default in order to avoid "l" wrapping around.
      let original_whichwrap = &whichwrap
      set whichwrap&vim
      silent! normal! l

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

" Replaces the pattern from the match data with its Replacement. Takes care of
" both simple replacements and nested ones.
"
function! switch#mapping#Replace(match) dict
  let pattern     = a:match.pattern
  let Replacement = self.definitions[pattern]
  let oldsearch   = @/

  if type(Replacement) == s:type_dict
    " maintain change delta for adjusting match limits
    let delta = 0

    for [pattern, sub_replacement] in items(Replacement)
      let last_column     = col('$')
      let pattern         = s:LimitPattern(pattern, a:match.start, a:match.end + delta)
      let pattern         = escape(pattern, '/')
      let sub_replacement = escape(sub_replacement, '/&')

      silent! foldopen!
      exe 's/'.pattern.'/'.sub_replacement.'/ge'
      " remove pattern from history
      call histdel('search', -1)

      " length of the line may have changed, adjust
      let delta += col('$') - last_column
    endfor
  elseif type(Replacement) == s:type_func
    let pattern = s:LimitPattern(pattern, a:match.start, a:match.end)
    let pattern = escape(pattern, '/')

    let g:Switch_replacer = Replacement
    let submatch_expression = join(map(range(0, 9), '"submatch(".v:val.")"'), ',')

    let Replacement = '\=call(g:Switch_replacer, [['.submatch_expression.']])'
    exe 's/'.pattern.'/'.Replacement.'/'

    unlet g:Switch_replacer

    " remove pattern from history
    call histdel('search', -1)
  else
    let pattern     = s:LimitPattern(pattern, a:match.start, a:match.end)
    let pattern     = escape(pattern, '/')
    let Replacement = escape(Replacement, '/&')

    exe 's/'.pattern.'/'.Replacement.'/'
    " remove pattern from history
    call histdel('search', -1)
  endif

  let @/ = oldsearch
endfunction

" Private:
" ========

" Limits the given pattern to only work in the given [start, end) interval by
" anchoring it to these column positions.
"
function! s:LimitPattern(pattern, start, end)
  let pattern = a:pattern

  if a:start > 1
    let pattern = a:pattern =~# '\\zs'
          \ ? substitute(pattern, '\\zs', '\\zs\\%>'.(a:start - 1).'c', '')
          \ : '\%>'.(a:start - 1).'c'.pattern
  endif

  if a:end > 1 && a:end < col('$')
    let pattern = a:pattern =~# '\\ze'
          \ ? substitute(pattern, '\\ze', '\\ze\\%<'.(a:end + 1).'c', '')
          \ : pattern.'\m\%<'.(a:end + 1).'c'
  endif

  return pattern
endfunction

function! s:ProcessListMapping(definitions, options)
  let dict_mappings = []

  if has_key(a:options, 'reverse') && a:options.reverse
    let definitions = reverse(copy(a:definitions))
  else
    let definitions = a:definitions
  endif

  for [first, second] in s:LoopedListItems(definitions)
    let dict_mapping          = {}
    let pattern               = '\C\V'.first.'\m'
    let Replacement           = second
    let dict_mapping[pattern] = Replacement

    let dict_mappings += s:ProcessDictMapping(dict_mapping)
  endfor

  return dict_mappings
endfunction

function! s:ProcessDictMapping(definition)
  let mapping = {
        \ 'definitions': a:definition,
        \
        \ 'Match':   function('switch#mapping#Match'),
        \ 'Replace': function('switch#mapping#Replace'),
        \ }

  return [mapping]
endfunction

function! s:ProcessModifierListMapping(definition, options)
  if type(a:definition) != s:type_list
    echoerr "Modifier mappings (case normalization, word boundaries) work only for list definitions"
    return []
  endif

  let dict_mappings = []
  let normalized_case = a:options.case
  let word_boundaries = a:options.words

  for [first, second] in s:LoopedListItems(a:definition)
    let m = {}
    let m[first] = second
    call add(dict_mappings, m)
  endfor

  let mappings = []
  for entry in dict_mappings
    for [key, value] in items(entry)
      if word_boundaries
        let key = '\<'.key.'\>'
      endif

      if normalized_case
        let key   = tolower(key)
        let value = tolower(value)

        let m = {}
        let m['\C'.key] = value
        let mappings += s:ProcessDictMapping(m)

        let m = {}
        let m['\C'.toupper(key)] = toupper(value)
        let mappings += s:ProcessDictMapping(m)

        let m = {}
        let m['\C'.switch#util#Capitalize(key)] = switch#util#Capitalize(value)
        let mappings += s:ProcessDictMapping(m)
      else
        let m = {}
        let m[key] = value
        let mappings += s:ProcessDictMapping(m)
      endif
    endfor
  endfor

  return mappings
endfunction

function! s:LoopedListItems(list)
  let index = 0
  let len   = len(a:list)
  let items = []

  for entry in a:list
    let next_index = index + 1
    if next_index >= len
      let next_index = 0
    endif

    call add(items, [entry, a:list[next_index]])

    let index = next_index
  endfor

  return items
endfunction
