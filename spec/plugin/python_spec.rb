require 'spec_helper'

describe "python definitions" do
  let(:filename) { 'test.py' }

  specify "string type" do
    set_file_contents 'foo = "bar?"'

    vim.search('bar').switch
    assert_file_contents 'foo = f"bar?"'

    vim.switch
    assert_file_contents "foo = 'bar?'"

    vim.switch
    assert_file_contents 'foo = "bar?"'
  end

  specify "fetch array access" do
    set_file_contents "foo['one']"

    vim.search('foo').switch
    assert_file_contents "foo.get('one')"

    vim.switch
    assert_file_contents "foo['one']"
  end

  specify "dict style" do
    set_file_contents "data = {'foo': 'bar', 'bar': 'baz'}"

    vim.search('{').switch
    assert_file_contents "data = dict(foo='bar', bar='baz')"

    vim.switch
    assert_file_contents "data = {'foo': 'bar', 'bar': 'baz'}"
  end
end
