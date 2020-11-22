[![GitHub version](https://badge.fury.io/gh/andrewradev%2Fswitch.vim.svg)](https://badge.fury.io/gh/andrewradev%2Fswitch.vim)
[![Build Status](https://secure.travis-ci.org/AndrewRadev/switch.vim.svg?branch=master)](http://travis-ci.org/AndrewRadev/switch.vim)

## Screencast!

This plugin is easier to demonstrate than explain. You can find a screencast
[here](http://youtu.be/zIOOLZJb87U).

## Usage

The main entry point of the plugin is a single command, `:Switch`. When the
command is executed, the plugin looks for one of a few specific patterns under
the cursor and performs a substitution depending on the pattern. For example, if
the cursor is on the "true" in the following code:

``` ruby
flag = true
```

Then, upon executing `:Switch`, the "true" will turn into "false".

There's a default mapping to trigger the command, `gs`. Note that this is
already a Vim built-in, but it doesn't seem particularly useful.

If you'd like to change the mapping, change the value of `g:switch_mapping`.
For example, to map it to "-", place the following in your .vimrc:

``` vim
let g:switch_mapping = "-"
```

To avoid the default mapping completely, set the variable to an empty string:

``` vim
let g:switch_mapping = ""
```

See the "customization" section below for information on how to create several
mappings with different definitions.

There are three main principles that the substitution follows:

1. The cursor needs to be on the match. Regardless of the pattern, the plugin
   only performs the substitution if the cursor is positioned in the matched
   text.

2. When several patterns match, the shortest match is performed. For example,
   in ruby, the following switch is defined:

   ``` ruby
   { :foo => true }
   # switches into:
   { foo: true }
   ```

   This works if the cursor is positioned somewhere on the ":foo =>" part, but
   if it's on top of "true", the abovementioned true -> false substitution will
   be performed instead. If you want to perform a "larger" substitution instead,
   you could move your cursor away from the "smaller" match. In this case,
   move the cursor away from the "true" keyword.

3. When several patterns with the same size match, the order of the
   definitions is respected. For instance, in eruby, the following code can be
   transformed:

   ``` erb
   <% if foo? %>
   could switch into:
   <%# if foo? %>
   but instead, it would switch into:
   <% if true or (foo?) %>
   ```

   The second switch will be performed, simply because in the definition list,
   the pattern was placed at a higher spot. In this case, this seems to make
   sense to prioritize one over the other. If it's needed to prioritize in a
   different way, the definition list should be redefined by the user.

## Advanced usage

Instead of using the `:Switch` and `:SwitchReverse` commands, you can use the
autoloaded function `switch#Switch`. Calling it without any arguments is the
same as calling the `:Switch` command:

``` vim
:call switch#Switch()
" equivalent to:
:Switch
```

However, you can also call the function with a dict of options. Instead of
`:SwitchReverse`, you can invoke it with the `reverse` option:

``` vim
:call switch#Switch({'reverse': 1})
" or,
:call switch#Switch({'reverse': v:true})
" equivalent to:
:SwitchReverse
```

The other option you can provide is `definitions` to set an explicit list of
definitions that are different from the built-ins.

``` vim
:call switch#Switch({'definitions': list_of_definitions})
```

The `switch#Switch()` function returns 1 if it succeeded, and 0 if it failed.
You can use the return value to decide if you'd like to apply some other mapping.

See below in "Customization" for more details and examples on how to write
use this function.

## Customization

*Note: for more switches by the community, take a look at the
[wiki](https://github.com/AndrewRadev/switch.vim/wiki)*

There are two variables that hold the global definition list and the
buffer-local definition list -- `g:switch_definitions` and
`b:switch_definitions`, respectively. These contain the definitions for the
built-ins provided by the plugin. In order to add the switches you want, you
should override `g:switch_custom_definitions` and
`b:switch_custom_definitions` instead.


The format of the variables is a simple List of items. Each item can be either
a List or a Dict.

### List definitions

``` vim
let g:switch_custom_definitions =
    \ [
    \   ['foo', 'bar', 'baz']
    \ ]
```

With this definition list, if the plugin encounters "foo" under the cursor, it
will be changed to "bar". If it sees "bar", it will change it to "baz", and
"baz" would be turned into "foo". This is the simple case of a definition that
is implemented (in a slightly different way) by the "toggle.vim" plugin.

You might want this to work for different capitalizations, like with `true`
and `True` and `TRUE`. You might also want to also affect only word
boundaries. While you could use the more complicated dict definition, a simple
way to tackle these scenarios is with modifier functions:

- `switch#NormalizedCase`
- `switch#Words`
- `switch#NormalizedCaseWords`

Here's how you might use these:

``` vim
let g:switch_custom_definitions =
    \ [
    \   switch#NormalizedCase(['one', 'two']),
    \   switch#Words(['three', 'four']),
    \   switch#NormalizedCaseWords(['five', 'six']),
    \ ]
```

The result of this is that:
- The first definition would switch between "one" and "two", between "One" and
  "Two", and between "ONE" and "TWO".
- The second definition would switch between "three" and "four" only at word
  boundaries, as if the patterns have `\<` and `\>` modifiers added to them.
- The third would switch between "five"/"six", "Five"/"Six", "FIVE"/"SIX" only
  at word boundaries with a combination of the above.

See `:help switch-internals` for some information on the underlying data
format if you'd like to use a different method to generate definitions (like,
say, loading JSON).

Leaving lists aside, the more complicated (and more powerful) way to define a
switch pattern is by using a Dict. In fact, a list definition is processed
into three dict definitions, one for each pair of switches.

### Dict definitions

``` vim
autocmd FileType eruby let b:switch_custom_definitions =
    \ [
    \   {
    \     ':\(\k\+\)\s\+=>': '\1:',
    \     '\<\(\k\+\):':     ':\1 =>',
    \   },
    \ ]
```

When in the eruby filetype, the hash will take effect. The plugin will look
for something that looks like `:foo =>` and replace it with `foo: `, or the
reverse -- `foo: `, so it could turn it into `:foo =>`. The search string is
fed to the `search()` function, so all special patterns like `\%l` have effect
in it. And the replacement string is used in the `:substitute` command, so all
of its replacement patterns work as well.

Notice the use of `autocmd FileType eruby` to set the buffer-local variable
whenever an eruby file is loaded. The same effect could be achieved by placing
this definition in `ftplugin/eruby.vim`.

Another interesting example is the following definition:

``` vim
autocmd FileType php let b:switch_custom_definitions =
      \ [
      \   {
      \     '<?php echo \(.\{-}\) ?>':        '<?php \1 ?>',
      \     '<?php \%(echo\)\@!\(.\{-}\) ?>': '<?php echo \1 ?>',
      \   }
      \ ]
```

In this case, when in the "php" filetype, the plugin will attempt to remove
the "echo" in "<?php echo 'something' ?>" or vice-versa. However, the second
pattern wouldn't work properly if it didn't contain "\%(echo\)\@!". This
pattern asserts that, in this place of the text, there is no "echo".
Otherwise, the second pattern would match as well. Using the `\@!` pattern in
strategic places is important in many cases.

For even more complicated substitutions, you can use the nested form.

### Nested dict definitions

The following expression replaces underscored identifier names with their
camelcased versions.

``` vim
let b:switch_custom_definitions = [
      \   {
      \     '\<[a-z0-9]\+_\k\+\>': {
      \       '_\(.\)': '\U\1'
      \     },
      \     '\<[a-z0-9]\+[A-Z]\k\+\>': {
      \       '\([A-Z]\)': '_\l\1'
      \     },
      \   }
      \ ]
```

If the cursor is on "foo_bar_baz", then switching would produce "fooBarBaz"
and vice-versa. The logic is as follows:

  - The keys of the dict are patterns, just like the "normal" dict version.
  - The values of the dict are dicts with patterns for keys and replacements
    for values.

The goal of this form is to enable substituting several different kinds of
patterns within the limits of another one. In this example, there's no way to
define this switch using the simpler form, since there's an unknown number of
underscores in the variable name and all of them need to be replaced in order
to make the switch complete.

The nested patterns differ from the simple one in that each one of them is
replaced globally, only within the limits of the "parent" pattern.

Note that this particular example is **NOT** included as a built-in, since it
may overshadow other ones and is probably not that useful, either (it's rare
that a language would require changing between the two forms). An example usage
may be within javascript, if your server-side variables are underscored and the
client-side ones need to be camelcased. For something more complete, you can
take a look at [this gist](https://gist.github.com/othree/5655583).

You could also use a separate mapping for that.

### Separate mappings

While there's a default mapping for `:Switch`, you could actually define
several mappings with your own custom definitions:

``` vim
let g:variable_style_switch_definitions = [
      \   {
      \     '\<[a-z0-9]\+_\k\+\>': {
      \       '_\(.\)': '\U\1'
      \     },
      \     '\<[a-z0-9]\+[A-Z]\k\+\>': {
      \       '\([A-Z]\)': '_\l\1'
      \     },
      \   }
      \ ]
nnoremap + :call switch#Switch({'definitions': g:variable_style_switch_definitions})<cr>
nnoremap - :Switch<cr>
```

With this, typing `-` would invoke the built-in switch definitions, while
typing `+` would switch between camelcase and underscored variable styles.
This may be particularly useful if you have several clashing switches on
patterns that match similar things.

### More complicated mappings

By using the `switch#Switch()` function, you can also write more complicated
mappings that check if a switch succeeded, and apply some fallback if it
didn't. The function returns 1 for success and 0 for failure.

For example, if you want to switch, or fall back to activating the
[speeddating](https://github.com/tpope/vim-speeddating) plugin, you could map
`<c-a>` and `<c-x>` like so:

``` vim
" Don't use default mappings
let g:speeddating_no_mappings = 1

" Avoid issues because of us remapping <c-a> and <c-x> below
nnoremap <Plug>SpeedDatingFallbackUp <c-a>
nnoremap <Plug>SpeedDatingFallbackDown <c-x>

" Manually invoke speeddating in case switch didn't work
nnoremap <c-a> :if !switch#Switch() <bar>
      \ call speeddating#increment(v:count1) <bar> endif<cr>
nnoremap <c-x> :if !switch#Switch({'reverse': 1}) <bar>
      \ call speeddating#increment(-v:count1) <bar> endif<cr>
```


## Builtins

Here's a list of all the built-in switch definitions. To see the actual
definitions with their patterns and replacements, look at the file
[plugin/switch.vim](https://github.com/AndrewRadev/switch.vim/blob/master/plugin/switch.vim).

### Global

* Boolean conditions:
  ```
  foo && bar
  foo || bar
  ```

* Boolean constants:
  ```
  flag = true
  flag = false

  flag = True
  flag = False
  ```

### Ruby

* Hash style:
  ``` ruby
  foo = { :one => 'two' }
  foo = { one: 'two' }
  ```

* If-clauses:
  ``` ruby
  if predicate?
    puts 'Hello, World!'
  end

  if true or (predicate?)
    puts 'Hello, World!'
  end

  if false and (predicate?)
    puts 'Hello, World!'
  end
  ```

* Rspec `should`/`should_not`:
  ``` ruby
  1.should eq 1
  1.should_not eq 1
  ```

* Tap:
  ``` ruby
  foo = user.comments.map(&:author).first
  foo = user.comments.tap { |o| puts o.inspect }.map(&:author).first
  ```

* String style:
  ``` ruby
  foo = 'bar'
  foo = "baz"
  foo = :baz
  ```
  (Note that it only works for single-word strings.)


* Ruby block shorthands:
  ``` ruby
  do_something { |x| x.some_work! }
  do_something(&:some_work!)
  ```

* Array shorthands:
  ``` ruby
  ['one', 'two', 'three']
  %w(one two three)
  ```

  ``` ruby
  [:one, :two, :three]
  %i(one two three)
  ```
  (In this case, be careful to not have the cursor on one of the strings/symbols, or you'll trigger the string switch as seen above.)

### PHP "echo" in tags:

``` php
<?php "Text" ?>
<?php echo "Text" ?>
```

### Eruby

* If-clauses:
  ``` erb
  <% if predicate? %>
    <%= 'Hello, World!' %>
  <% end %>

  <% if true or (predicate?) %>
    <%= 'Hello, World!' %>
  <% end %>

  <% if false and (predicate?) %>
    <%= 'Hello, World!' %>
  <% end %>
  ```

* Tag type:
  ``` erb
  <% something %>
  <%# something %>
  <%= something %>
  ```

* Hash style:
  ``` erb
  <% foo = { :one => 'two' } %>
  <% foo = { one: 'two' } %>
  ```

### Haml

* If-clauses:
  ``` haml
  - if predicate?
    Hello, World!

  - if true or (predicate?)
    Hello, World!

  - if false and (predicate?)
    Hello, World!
  ```

* Tag type:
  ``` haml
  - something
  -# something
  = something
  ```

* Hash style:
  ``` haml
  %a{:href => '/example'}
  %a{href: '/example'}
  ```

### C++ pointer dots/arrows:

``` cpp
Object* foo = bar.baz;
Object* foo = bar->baz;
```
### JavaScript

* Function definitions:
  ``` javascript
  function example(one, two) { }
  var example = function(one, two) { }
  ```

* ES6-style arrow functions:
  ``` javascript
  var example = function(one, two) { }
  var example = (one, two) => { }
  ```

* ES6-style variable declarations:
  ``` javascript
  var example
  let example
  const example
  // var -> let
  // let -> const
  // const -> let
  ```
  Switching to var from const or let is unsupported, since it's assumed to be an unlikely case.

### CoffeeScript arrows

``` coffeescript
functionCall (foo) ->
functionCall (foo) =>
```

### CoffeeScript dictionary shorthands

``` coffeescript
foo = {one, two}
foo = {one: one, two}
```

### Clojure

* String style:
  ``` clojure
  "baz"
  'bar
  :baz
  ```
  (Note that it only works for single-word strings, such as `baz`, `b-a-z`, or `**`.)

* If-clauses:
  ``` clojure
  (if predicate?
    (prn "Hello, world!")
    (prn "oh..."))

  (if (or true predicate?)
    (prn "Hello, world!")
    (prn "oh..."))

  (if (and false predicate?)
    (prn "Hello, world!")
    (prn "oh..."))
  ```
  (Note that it also works for `if-not`, `when`, and `when-not`.)

### Scala

* String style:
  ``` scala
  "foo bar"
  s"foo bar"
  f"foo bar"
  """foo bar"""
  s"""foo bar"""
  f"""foo bar"""
  ```

### Git Rebase

* Git Rebase Commands
  ```
    pick -> fixup -> reword -> edit -> squash -> exec -> break -> drop -> label -> reset -> merge -> (loops back to pick)

    p -> fixup
    f -> reword
    r -> edit
    e -> squash
    s -> exec
    x -> break
    b -> drop
    d -> label
    l -> reset
    t -> merge
    m -> pick
  ```

### Elixir

Charlist -> Binary -> Atom

``` elixir
foo = 'bar'
foo = "bar"
foo = :bar
```

Elixir list shorthands

``` elixir
["one", "two", "three"]
~w(one two three)

[:one, :two, :three]
~w(one two three)a
```

Capitalized boolean constants :

``` elixir
flag = True
flag = False
```

### Rust

Void typecheck

``` rust
let value = complicated_expression();
let value: () = complicated_expression();
```

### TOML

Particularly for files named `Cargo.toml` with the `toml` filetype (not built-in, but there are plugins for it):

``` toml
structopt = "0.3.5"
structopt = { version = "0.3.5" }
```

## Similar work

This plugin is very similar to two other ones:
  - [toggle.vim](http://www.vim.org/scripts/script.php?script_id=895)
  - [cycle.vim](https://github.com/zef/vim-cycle)

Both of these work on replacing a specific word under the cursor with a
different one. The benefit of switch.vim is that it works for much more
complicated patterns. The drawback is that this makes extending it more
involved. I encourage anyone that doesn't need the additional power in
switch.vim to take a look at one of these two.

## Contributing

If you'd like to hack on the plugin, please see
[CONTRIBUTING.md](https://github.com/AndrewRadev/switch.vim/blob/master/CONTRIBUTING.md) first.

## Issues

Any issues and suggestions are very welcome on the
[github bugtracker](https://github.com/AndrewRadev/switch.vim/issues).
