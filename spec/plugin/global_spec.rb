require 'spec_helper'

describe "global definitions" do
  let(:filename) { 'test.txt' }

  specify "&&/||" do
    set_file_contents 'foo && bar'
    vim.search '&&'

    vim.switch
    assert_file_contents 'foo || bar'

    vim.switch
    assert_file_contents 'foo && bar'
  end

  specify "true/false" do
    set_file_contents 'flag = true'
    vim.search 'true'

    vim.switch
    assert_file_contents 'flag = false'

    vim.switch
    assert_file_contents 'flag = true'
  end

  specify "falsey" do
    set_file_contents 'flag = "falsey"'
    vim.search 'false'

    vim.switch
    assert_file_contents 'flag = "falsey"'
  end

  specify "repeatability with vim-repeat" do
    set_file_contents 'flag = true'
    vim.search 'true'

    vim.switch
    assert_file_contents 'flag = false'

    vim.feedkeys('.')
    vim.write
    assert_file_contents 'flag = true'
  end
end
