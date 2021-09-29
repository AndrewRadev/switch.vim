if exists("g:loaded_switch") || &cp
  finish
endif

let g:loaded_switch = '0.3.0' " version number
let s:keepcpo = &cpo
set cpo&vim

if !exists('g:switch_mapping')
  let g:switch_mapping = 'gs'
endif

if !exists('g:switch_reverse_mapping')
  let g:switch_reverse_mapping = ''
endif

if !exists('g:switch_find_smallest_match')
  let g:switch_find_smallest_match = 1
endif

let g:switch_builtins =
      \ {
      \   'ampersands': ['&&', '||'],
      \   'capital_true_false': {
      \     '\C\<True\>':  'False',
      \     '\C\<False\>': 'True',
      \   },
      \   'true_false': {
      \     '\C\<true\>':  'false',
      \     '\C\<false\>': 'true',
      \   },
      \   'ruby_hash_style': {
      \     ':\(\k\+\)\s*=>\s*': '\1: ',
      \     '\<\(\k\+\): ':      ':\1 => ',
      \   },
      \   'ruby_oneline_hash': {
      \     '\v\{(\s*:(\k|["''])+\s*\=\>\s*[^,]+\s*,?)*}': {
      \       ':\(\%\(\k\|["'']\)\+\)\s*=>': '\1:',
      \     },
      \     '\v\{(\s*(\k|["''])+:\s*[^,]+,?)*\s*}': {
      \       '\(\%\(\k\|["'']\)\+\):': ':\1 =>',
      \     },
      \   },
      \   'ruby_lambda': {
      \     'lambda\s*{\s*|\([^|]\+\)|': '->(\1) {',
      \     '->\s*(\([^)]\+\))\s*{': 'lambda { |\1|',
      \     'lambda\s*{': '-> {',
      \     '->\s*{': 'lambda {'
      \   },
      \   'ruby_if_clause': {
      \     'if true or (\(.*\))':          'if false and (\1)',
      \     'if false and (\(.*\))':        'if \1',
      \     'if \%(true\|false\)\@!\(.*\)': 'if true or (\1)',
      \   },
      \   'ruby_string': {
      \     '"\(\k\+\%([?!]\)\=\)"':                '''\1''',
      \     '''\(\k\+\%([?!]\)\=\)''':              ':\1',
      \     ':\(\k\+\%([?!]\)\=\)\@>\%(\s*=>\)\@!': '"\1"\2',
      \   },
      \   'ruby_short_blocks': {
      \     '\(\k\+\)(&:\(\k\+[!?]\=\))':                   '\1 { |x| x\.\2 }',
      \     '\(\k\+\)\s\={\s*|\(\k\+\)|\s*\2.\(\S\+\)\s*}': '\1(&:\3)',
      \   },
      \   'ruby_array_shorthand': {
      \     '\v\[\s*%((["''])%([^"'']\s@!)+\1,?\s*)*]': {
      \       '\[':                                    '%w(',
      \       '\v\s*(["''])(%([^"'']\s@!)+)\1,?(\s)*': '\2\3',
      \       '\s*]':                                  ')',
      \     },
      \     '\v\%w\(\s*%([^"'',]\s*)+\)': {
      \       '%w(\s*':        '[''',
      \       '\v(\s+)@>\)@!': ''', ''',
      \       '\s*)':          ''']',
      \     },
      \     '\v\[\s*%(:\@{0,2}\k+,?\s*)+\]': {
      \       '\[':                        '%i(',
      \       '\v\s*:(\@{0,2}\k+),?(\s)*': '\1\2',
      \       '\s*]':                      ')',
      \     },
      \     '\v\%i\(\s*%(\@{0,2}\k+\s*)+\)': {
      \       '\v\%i\((\s*)@>': '[:',
      \       '\v(\s+)@>\)@!':  ', :',
      \       '\s*)':           ']',
      \     },
      \   },
      \   'ruby_fetch': {
      \     '\v(%(\%@<!\k)+)\[(.{-})\]': '\1.fetch(\2)',
      \     '\v(\k+)\.fetch\((.{-})\)': '\1[\2]',
      \   },
      \   'ruby_assert_nil': {
      \     'assert_equal nil,': 'assert_nil',
      \     'assert_nil':        'assert_equal nil,',
      \   },
      \   'rspec_should': ['should ', 'should_not '],
      \   'rspec_expect': {
      \     '\(expect(.*)\)\.to ':     '\1.not_to ',
      \     '\(expect(.*)\)\.to_not ': '\1.to ',
      \     '\(expect(.*)\)\.not_to ': '\1.to ',
      \   },
      \   'rspec_to': {
      \     '\.to ':     '.not_to ',
      \     '\.not_to ': '.to ',
      \     '\.to_not ': '.to ',
      \   },
      \   'rspec_be_truthy_falsey': ['be_truthy', 'be_falsey'],
      \   'eruby_if_clause': {
      \     '<% if true or (\(.*\)) %>':          '<% if false and (\1) %>',
      \     '<% if false and (\(.*\)) %>':        '<% if \1 %>',
      \     '<% if \%(true\|false\)\@!\(.*\) %>': '<% if true or (\1) %>',
      \   },
      \   'eruby_tag_type': {
      \     '<%= \(.*\) %>':   '<% \1 %>',
      \     '<% \(.*\) -\?%>': '<%# \1 %>',
      \     '<%# \(.*\) %>':   '<%= \1 %>',
      \   },
      \   'php_echo': {
      \     '<?php echo \(.\{-}\) ?>':        '<?php \1 ?>',
      \     '<?php \%(echo\)\@!\(.\{-}\) ?>': '<?php echo \1 ?>',
      \   },
      \   'cpp_pointer': {
      \     '\(\k\+\)\.': '\1->',
      \     '\(\k\+\)->': '\1.',
      \   },
      \   'javascript_function': {
      \     '\(async \)\?function\s*\(\k\+\)\s*()\s*{':                                    'const \2 = \1() => {',
      \     '\(async \)\?function\s*\(\k\+\)\s*(\([^()]\{-},[^()]\{-}\))\s*{':             'const \2 = \1(\3) => {',
      \     '\(async \)\?function\s*\(\k\+\)\s*(\(\k\+\))\s*{':                            'const \2 = \1\3 => {',
      \     '\%(var \|let \|const \)\?\(\k\+\)\s*=\s*\(async \)\?function\s*(':             '\2function \1(',
      \     '\%(var \|let \|const \)\?\(\k\+\)\s*=\s*\(async \)\?(\([^()]\{-}\))\s*=>\s*{': '\2function \1(\3) {',
      \     '\%(var \|let \|const \)\?\(\k\+\)\s*=\s*\(async \)\?\(\k\+\)\s*=>\s*{':        '\2function \1(\3) {',
      \   },
      \   'javascript_arrow_function': {
      \     'function\s*()\s*{':                        '() => {',
      \     'function\s*(\([^()]\{-},[^()]\{-}\))\s*{': '(\1) => {',
      \     'function\s*(\(\k\+\))\s*{':                '\1 => {',
      \     '(\([^()]\{-}\))\s*=>\s*{':                 'function(\1) {',
      \     '\(\k\+\)\s*=>\s*{':                        'function(\1) {',
      \   },
      \   'javascript_es6_declarations': {
      \     '\<var\s\+': 'let ',
      \     '\<let\s\+': 'const ',
      \     '\<const\s\+': 'let ',
      \   },
      \   'coffee_arrow': {
      \     '^\(.*\)->': '\1=>',
      \     '^\(.*\)=>': '\1->',
      \   },
      \   'coffee_dictionary_shorthand': {
      \     '\([{,]\_s*\)\@<=\(\k\+\)\(\s*[},]\)':       '\2: \2\3',
      \     '\([{,]\_s*\)\@<=\(\k\+\): \?\2\(\s*[},]\)': '\2\3',
      \   },
      \   'clojure_string': {
      \     '"\(\k\+\)"': '''\1',
      \     '''\(\k\+\)': ':\1',
      \     ':\(\k\+\)':  '"\1"\2',
      \   },
      \   'clojure_if_clause': {
      \     '(\(if\|if-not\|when\|when-not\) (or true \(.*\))':   '(\1 (and false \2)',
      \     '(\(if\|if-not\|when\|when-not\) (and false \(.*\))': '(\1 \2',
      \     '(\(if\|if-not\|when\|when-not\) (\@!\(.*\)':         '(\1 (or true \2)',
      \   },
      \   'scala_string': {
      \     '[sf"]\@<!"\(\%(\\.\|.\)\{-}\)""\@!': 's"\1"',
      \     's"\(\%(\\.\|.\)\{-}\)"':             'f"\1"',
      \     'f"\(\%(\\.\|.\)\{-}\)"':             '"""\1"""',
      \     '[sf"]\@<!"""\(.\{-}\)"""':           's"""\1"""',
      \     's"""\(.\{-}\)"""':                   'f"""\1"""',
      \     'f"""\(.\{-}\)"""':                   '"\1"',
      \   },
      \   'elixir_list_shorthand': {
      \     '\[\%(\k\|[''", ]\)\+\]': {
      \       '\[':                    '\~w(',
      \       '[''"]\(\k\+\)[''"],\=': '\1',
      \       ']':                     ')',
      \     },
      \     '\~w(\%(\k\|\s\)\+)a': {
      \       '\~w(':      '[',
      \       '\(\k\+\) ': ':\1, ',
      \       '\(\k\+\))a': ':\1]',
      \     },
      \     '\~w(\%(\k\|\s\)\+)a\@!': {
      \       '\~w(':      '[',
      \       '\(\k\+\) ': '"\1", ',
      \       '\(\k\+\))': '"\1"]',
      \     },
      \     '\[\%(\k\|[:, ]\)\+\]': {
      \       '\[':           '\~w(',
      \       ':\(\k\+\),\=': '\1',
      \       ']':            ')a',
      \     },
      \   },
      \   'rust_void_typecheck': {
      \     '\(let\s*\%(mut\s*\)\=\k\+\) = ': '\1: () = ',
      \     '\(let\s*\%(mut\s*\)\=\k\+\): () = ': '\1 = ',
      \   },
      \   'rust_turbofish': {
      \     '\(\k\+\)(': '\1::<Todo>(',
      \     '\(\k\+\)::<\%(\k\|\s\|[<>,]\)\+>(': '\1(',
      \   },
      \   'rust_string': {
      \     '"\([^"]*\)"':   'r"\1"',
      \     'r"\([^"]*\)"':  'r#"\1"#',
      \     'r#"\([^"]*\)"#': '"\1"',
      \   },
      \   'rust_is_some': {
      \     '\<is_some\>': 'is_none',
      \     '\<is_none\>': 'is_some',
      \   },
      \   'rust_assert': {
      \     '\<assert_eq!': 'assert_ne!',
      \     '\<assert_ne!': 'assert_eq!',
      \   },
      \   'cargo_dependency_version': {
      \     '^\s*\([[:keyword:]-]\+\)\s*=\s*\(["''].\{-}["'']\)': '\1 = { version = \2 }',
      \     '^\s*\([[:keyword:]-]\+\)\s*=\s*{\s*version\s*=\s*\(["''].\{-}["'']\)\s*}': '\1 = \2',
      \   },
      \   'vim_script_local_function': {
      \     '\<s:\(\h\w\+\)(':  '<SID>\1(',
      \     '<SID>\(\h\w\+\)(': 's:\1(',
      \   }
      \ }

let g:switch_definitions =
      \ [
      \   { '\C\<and\>': 'or', '\C\<or\>': 'and' },
      \   { '\C\<And\>': 'Or', '\C\<Or\>': 'And' },
      \   { '\C\<AND\>': 'OR', '\C\<OR\>': 'AND' },
      \   g:switch_builtins.ampersands,
      \   g:switch_builtins.capital_true_false,
      \   g:switch_builtins.true_false,
      \ ]

command! Switch call s:Switch()
function! s:Switch()
  silent call switch#Switch()
  silent! call repeat#set(":Switch\<cr>")
endfunction

command! SwitchReverse call s:SwitchReverse()
function! s:SwitchReverse()
  silent call switch#Switch({'reverse': 1})
  silent! call repeat#set(":SwitchReverse\<cr>")
endfunction

nnoremap <silent> <Plug>(Switch)        :set opfunc=switch#OpfuncForward<cr>g@l
nnoremap <silent> <Plug>(SwitchReverse) :set opfunc=switch#OpfuncReverse<cr>g@l

command! -nargs=* SwitchExtend call s:SwitchExtend(<args>)
fun! s:SwitchExtend(...)
  let b:switch_custom_definitions = get(b:, 'switch_custom_definitions',
        \                               copy(get(g:, 'switch_custom_definitions', [])))
  if a:0 == 0
    echo b:switch_custom_definitions
  else
    echohl ErrorMsg
    for def in a:000
      if (type(def) == type({}) || type(def) == type([]))
        if index(b:switch_custom_definitions, def) < 0
          call extend(b:switch_custom_definitions, [def])
        else
          echomsg 'SwitchExtend: skipping duplicate definition:' string(def)
        endif
      else
        echomsg 'SwitchExtend: args must be lists or dictionaries, skipping:' string(def)
      endif
    endfor
    echohl None
  endif
endfun

if g:switch_mapping != '' && !hasmapto('<Plug>(Switch)')
  exe 'nmap '.g:switch_mapping.' <Plug>(Switch)'
endif

if g:switch_reverse_mapping != '' && !hasmapto('<Plug>(SwitchReverse)')
  exe 'nmap '.g:switch_reverse_mapping.' <Plug>(SwitchReverse)'
endif

let &cpo = s:keepcpo
unlet s:keepcpo
