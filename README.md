[![Build Status](https://secure.travis-ci.org/AndrewRadev/switch.vim.png?branch=master)](http://travis-ci.org/AndrewRadev/switch.vim)

## Screencast!

This plugin is easier to demonstrate than explain. You can find a screencast
[here](http://youtu.be/zIOOLZJb87U).

## Usage

The main entry point of the plugin is a single command, `:Switch`. When the
command is executed, the plugin looks for one of a few specific patterns under
the cursor and performs a substition depending on the pattern. For example, if
the cursor is on the "true" in the following code:

``` ruby
flag = true
```

Then, upon executing `:Switch`, the "true" will turn into "false".

It is highly recommended to map the `:Switch` command to a key. For example,
to map it to "-", place the following in your .vimrc:

``` vim
nnoremap - :Switch<cr>
```
See the "customization" section below for information on how to create several
mappings with different definitions.

There are three main principles that the substition follows:

1. The cursor needs to be on the match. Regardless of the pattern, the plugin
   only performs the substition if the cursor is positioned in the matched
   text.

2. When several patterns match, the shortest match is performed. For example,
   in ruby, the following switch is defined:

   ``` ruby
   { :foo => true }
   # switches into:
   { foo: true }
   ```

   This works if the cursor is positioned somewhere on the ":foo =>" part, but
   if it's on top of "true", the abovementioned true -> false substition will
   be performed instead. If you want to perform a "larger" substition instead,
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

## Customization

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

The more complicated (and more powerful) way to define a switch pattern is by
using a Dict.

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

For even more complicated substitions, you can use the nested form.

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

While it was recommended to define a mapping for `:Switch`, you could actually
define several mappings with your own custom definitions:

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
nnoremap + :call switch#Switch(g:variable_style_switch_definitions)<cr>
nnoremap - :Switch<cr>
```

With this, typing `-` would invoke the built-in switch definitions, while
typing `+` would switch between camelcase and underscored variable styles.
This may be particularly useful if you have several clashing switches on
patterns that match similar things.

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

* Rspec should/should_not:
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


* Ruby block shorthands (g:switch_builtins.ruby_short_blocks):
  ``` ruby
  do_something { |x| x.some_work! }
  do_something(&:some_work!)
  ```

* Array shorthands:
  ``` ruby
  ['one', 'two', 'three']
  %w(one two three)
  ```
  (In this case, be careful to not have the cursor on one of the strings, or you'll trigger the string switch as seen above.)

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
  <%=raw something %>
  <%= something %>
  ```

* Hash style:
  ``` erb
  <% foo = { :one => 'two' } %>
  <% foo = { one: 'two' } %>
  ```

### C++ pointer dots/arrows:

``` cpp
Object* foo = bar.baz;
Object* foo = bar->baz;
```

### Coffeescript arrows

``` coffeescript
functionCall (foo) ->
functionCall (foo) =>
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
