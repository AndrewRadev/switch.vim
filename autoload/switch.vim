function! switch#Switch(...)
  if a:0 > 0
    let options = a:1
  else
    let options = {}
  endif

  if has_key(options, 'definitions')
    let definitions = options.definitions
  else
    let definitions = s:GetDefaultDefinitions()
  endif

  silent! normal! zO

  try
    let saved_cursor = getpos('.')
    let min_match    = switch#match#Null()
    let definitions  = switch#util#FlatMap(copy(definitions), 'switch#mapping#Process(v:val, '.string(options).')')

    for mapping in definitions
      let match = mapping.Match()

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

function! switch#OpfuncForward(type)
  silent call switch#Switch()
  return ''
endfunction

function! switch#OpfuncReverse(type)
  silent call switch#Switch({'reverse': 1})
  return ''
endfunction

function! switch#NormalizedCase(definition)
  return {
        \ '_type': 'normalized_case',
        \ '_definition': a:definition,
        \ }
endfunction

function! switch#Words(definition)
  return {
        \ '_type': 'words',
        \ '_definition': a:definition,
        \ }
endfunction

function! switch#NormalizedCaseWords(definition)
  return {
        \ '_type': 'normalized_case_words',
        \ '_definition': a:definition,
        \ }
endfunction

function! s:GetDefaultDefinitions()
  let definitions = []

  if exists('g:switch_custom_definitions')
    call extend(definitions, g:switch_custom_definitions)
  endif

  if !exists('g:switch_no_builtins')
    let definitions = extend(definitions, g:switch_definitions)
  endif

  if exists('b:switch_custom_definitions')
    call extend(definitions, b:switch_custom_definitions)
  endif

  if exists('b:switch_definitions') && !exists('b:switch_no_builtins')
    call extend(definitions, b:switch_definitions)
  endif

  return definitions
endfunction
