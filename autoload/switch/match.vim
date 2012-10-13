" Constructor:
" ============

function! switch#match#New(mapping, pattern, start, end, length)
  let match = switch#match#NewNull()

  let match.mapping = a:mapping
  let match.pattern = a:pattern
  let match.start   = a:start
  let match.end     = a:end
  let match.length  = a:length

  return match
endfunction

function! switch#match#NewNull()
  let match = {
        \ 'mapping': {},
        \ 'start':   -1,
        \ 'end':     -1,
        \ 'length':  -1,
        \
        \ 'IsBetter': function('switch#match#IsBetter'),
        \ 'Replace':  function('switch#match#Replace'),
        \ 'IsNull':   function('switch#match#IsNull'),
        \ }

  return match
endfunction

" Methods:
" ========

function! switch#match#IsBetter(other) dict
  if self.IsNull() && a:other.IsNull()
    return 0
  elseif a:other.IsNull()
    return 1
  elseif self.length < a:other.length
    return 1
  else
    return 0
  endif
endfunction

function! switch#match#Replace() dict
  call self.mapping.Replace(self)
endfunction

function! switch#match#IsNull() dict
  return (self.length < 0)
endfunction
