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

  specify "rspec should/should_not" do
    set_file_contents '1.should eq 1'

    vim.search('should').switch
    assert_file_contents '1.should_not eq 1'

    vim.switch
    assert_file_contents '1.should eq 1'
  end

  specify "rspec be_true/be_false" do
    set_file_contents 'value.should be_true'

    vim.search('be_true').switch
    assert_file_contents 'value.should be_false'

    vim.switch
    assert_file_contents 'value.should be_true'

    vim.search('value').switch
    assert_file_contents 'value.should be_true'
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

  specify "tap" do
    set_file_contents 'bar = user.comments.map(&:author).name'

    vim.search('comments').switch
    assert_file_contents 'bar = user.tap { |o| puts o.inspect }.comments.map(&:author).name'

    vim.switch
    assert_file_contents 'bar = user.comments.map(&:author).name'

    set_file_contents 'bar = user.tap { |o| puts o.to_sql }.comments.map(&:author).name'
    vim.search('tap').switch
    assert_file_contents 'bar = user.comments.map(&:author).name'
  end

  specify "string type" do
    set_file_contents 'foo = "bar"'

    vim.search('bar').switch
    assert_file_contents "foo = 'bar'"

    vim.switch
    assert_file_contents "foo = :bar"

    vim.switch
    assert_file_contents 'foo = "bar"'
  end

  specify "short blocks" do
    set_file_contents 'do_something { |x| x.some_work! }'

    vim.switch
    assert_file_contents 'do_something(&:some_work!)'

    vim.switch
    assert_file_contents 'do_something { |x| x.some_work! }'
  end

  specify "array shorthands" do
    set_file_contents "['one', 'two']"

    vim.search('[').switch
    assert_file_contents "%w(one two)"

    vim.switch
    assert_file_contents "['one', 'two']"
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
