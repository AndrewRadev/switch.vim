require 'spec_helper'

describe "ruby definitions" do
  let(:filename) { 'test.rb' }

  specify "true/false" do
    set_file_contents 'flag = true'

    vim.search('true').switch
    assert_file_contents 'flag = false'

    vim.switch
    assert_file_contents 'flag = true'

    vim.search('flag').switch
    assert_file_contents 'flag = true'
  end

  specify "hash style" do
    set_file_contents <<-EOF
      foo = {
        :one => 'two',
        :three => 4
      }
    EOF
    vim.search('one').switch
    vim.search('three').switch
    assert_file_contents <<-EOF
      foo = {
        one: 'two',
        three: 4
      }
    EOF

    vim.search('one').switch
    vim.search('three').switch
    assert_file_contents <<-EOF
      foo = {
        :one => 'two',
        :three => 4
      }
    EOF
  end

  specify "hash style (single line)" do
    set_file_contents <<-EOF
      foo = { :one => 'two', :three => 4 }
    EOF

    vim.search('three').switch
    assert_file_contents <<-EOF
      foo = { :one => 'two', three: 4 }
    EOF

    vim.search('three').switch
    assert_file_contents <<-EOF
      foo = { :one => 'two', :three => 4 }
    EOF

    vim.search('{').switch
    assert_file_contents <<-EOF
      foo = { one: 'two', three: 4 }
    EOF

    vim.search(',').switch
    assert_file_contents <<-EOF
      foo = { :one => 'two', :three => 4 }
    EOF
  end

  specify "hash style (whitespace)" do
    set_file_contents 'foo:bar'
    vim.switch
    assert_file_contents 'foo:bar'

    set_file_contents ':foo=>bar'
    vim.switch
    assert_file_contents 'foo: bar'

    set_file_contents 'foo: bar'
    vim.switch
    assert_file_contents ':foo => bar'
  end

  specify "lambdas" do
    set_file_contents 'lambda { |x, y| whatever(x, y) }'
    vim.switch
    assert_file_contents '->(x, y) { whatever(x, y) }'
    vim.switch
    assert_file_contents 'lambda { |x, y| whatever(x, y) }'
  end

  specify "rspec should/should_not" do
    set_file_contents '1.should eq 1'

    vim.search('should').switch
    assert_file_contents '1.should_not eq 1'

    vim.switch
    assert_file_contents '1.should eq 1'
  end

  specify "rspec be_truthy/be_falsey" do
    set_file_contents 'value.should be_truthy'

    vim.search('be_truthy').switch
    assert_file_contents 'value.should be_falsey'

    vim.switch
    assert_file_contents 'value.should be_truthy'

    vim.search('value').switch
    assert_file_contents 'value.should be_truthy'
  end

  specify "rspec .to/to_not" do
    set_file_contents 'expect { value }.to change(foo).to(bar)'

    vim.search('to').switch
    assert_file_contents 'expect { value }.not_to change(foo).to(bar)'

    vim.switch
    assert_file_contents 'expect { value }.to change(foo).to(bar)'
  end

  specify "rspec expect(...).to/not_to" do
    set_file_contents 'expect(value).to be_present'

    vim.search('expect').switch
    assert_file_contents 'expect(value).not_to be_present'

    vim.switch
    assert_file_contents 'expect(value).to be_present'
  end

  specify "if-clauses" do
    set_file_contents <<-EOF
      if predicate?
        puts 'Hello, World!'
      end
    EOF

    vim.search 'if'

    vim.switch
    assert_file_contents <<-EOF
      if true or (predicate?)
        puts 'Hello, World!'
      end
    EOF

    vim.switch
    assert_file_contents <<-EOF
      if false and (predicate?)
        puts 'Hello, World!'
      end
    EOF

    vim.switch
    assert_file_contents <<-EOF
      if predicate?
        puts 'Hello, World!'
      end
    EOF
  end

  specify "string type" do
    set_file_contents 'foo = "bar?"'

    vim.search('bar').switch
    assert_file_contents "foo = 'bar?'"

    vim.switch
    assert_file_contents "foo = :bar?"

    vim.switch
    assert_file_contents 'foo = "bar?"'
  end

  specify "short blocks" do
    set_file_contents 'do_something { |x| x.some_work! }.foo()'

    vim.switch
    assert_file_contents 'do_something(&:some_work!).foo()'

    vim.switch
    assert_file_contents 'do_something { |x| x.some_work! }.foo()'
  end

  specify "array shorthands (strings)" do
    set_file_contents "['e-mail', '3.14', '@var', 'snake_case', 'p@s$w0Rd!']"

    vim.search('[').switch
    assert_file_contents "%w(e-mail 3.14 @var snake_case p@s$w0Rd!)"

    vim.switch
    assert_file_contents "['e-mail', '3.14', '@var', 'snake_case', 'p@s$w0Rd!']"
  end

  specify "array shorthands (symbols)" do
    set_file_contents "[:pi, :@var, :snake_case, :@@klass]"

    vim.search('[').switch
    assert_file_contents "%i(pi @var snake_case @@klass)"

    vim.switch
    assert_file_contents "[:pi, :@var, :snake_case, :@@klass]"
  end

  specify "array shorthands (whitespace)" do
    set_file_contents "[ :pi, :@var,  :snake_cas, :@@klasse  ]"

    vim.search('[').switch
    assert_file_contents "%i(pi @var snake_cas @@klasse)"

    set_file_contents "%i( pi @var  snake_cas @@klasse  )"

    vim.switch
    assert_file_contents "[:pi, :@var, :snake_cas, :@@klasse]"

    set_file_contents "[  'e-mail', '3.14', '@var',  'snake_case', 'p@s$w0Rd!' ]"

    vim.search('[').switch
    assert_file_contents "%w(e-mail 3.14 @var snake_case p@s$w0Rd!)"

    set_file_contents "%w(  e-mail 3.14 @var  snake_case p@s$w0Rd! )"

    vim.switch
    assert_file_contents "['e-mail', '3.14', '@var', 'snake_case', 'p@s$w0Rd!']"
  end

  specify "fetch array access" do
    set_file_contents "foo['one']"

    vim.search('foo').switch
    assert_file_contents "foo.fetch('one')"

    vim.switch
    assert_file_contents "foo['one']"

    set_file_contents "%w[one]"

    vim.search('w').switch
    assert_file_contents "%w[one]"
  end

  specify "assert_nil" do
    set_file_contents "assert_nil SomeClass.some_method"

    vim.search('assert_nil').switch
    assert_file_contents "assert_equal nil, SomeClass.some_method"

    vim.switch
    assert_file_contents "assert_nil SomeClass.some_method"
  end

  describe "(overrides)" do
    specify "true/false overrides hash style" do
      set_file_contents <<-EOF
        foo = { :one => true }
      EOF

      vim.search('true').switch
      assert_file_contents <<-EOF
        foo = { :one => false }
      EOF

      vim.normal('u').search('one').switch
      assert_file_contents <<-EOF
        foo = { one: true }
      EOF
    end
  end
end
