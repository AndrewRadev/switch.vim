require 'spec_helper'

describe "elixir definitions" do
  let(:filename) { 'test.ex' }

  specify "string type" do
    set_file_contents 'foo = "bar?"'
    vim.set 'filetype', 'elixir'

    vim.search('bar').switch
    assert_file_contents "foo = 'bar?'"

    vim.switch
    assert_file_contents "foo = :bar?"

    vim.switch
    assert_file_contents 'foo = "bar?"'
  end

  specify "list shorthands" do
    set_file_contents '["one", "two"]'
    vim.set 'filetype', 'elixir'

    vim.search('[').switch
    assert_file_contents "~w(one two)"

    vim.switch
    assert_file_contents '["one", "two"]'

    set_file_contents "[:one, :two]"

    vim.search('[').switch
    assert_file_contents "~w(one two)a"

    vim.switch
    assert_file_contents "[:one, :two]"
  end
end
