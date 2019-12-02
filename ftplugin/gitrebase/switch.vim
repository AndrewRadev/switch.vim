let b:switch_definitions =
      \ [
      \   [ 'pick', 'fixup', 'reword', 'edit', 'squash', 'exec', 'drop' ],
      \   { '^p ': 'fixup ' },
      \   { '^f ': 'reword ' },
      \   { '^r ': 'edit ' },
      \   { '^e ': 'squash ' },
      \   { '^s ': 'exec ' },
      \   { '^x ': 'drop ' },
      \   { '^d ': 'pick ' },
      \ ]
