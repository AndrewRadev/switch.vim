if !exists("g:loaded_switch")
  finish
endif

let b:switch_definitions =
      \ [
      \   [ 'pick', 'fixup', 'reword', 'edit', 'squash', 'exec', 'break', 'drop', 'label', 'reset', 'merge' ],
      \   { '^p ': 'fixup ' },
      \   { '^f ': 'reword ' },
      \   { '^r ': 'edit ' },
      \   { '^e ': 'squash ' },
      \   { '^s ': 'exec ' },
      \   { '^x ': 'break ' },
      \   { '^b ': 'drop ' },
      \   { '^d ': 'label ' },
      \   { '^l ': 'reset ' },
      \   { '^t ': 'merge ' },
      \   { '^m ': 'pick ' },
      \ ]
