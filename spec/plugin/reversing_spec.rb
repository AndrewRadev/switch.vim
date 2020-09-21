require 'spec_helper'

describe "Reversed definitions" do
  let(:filename) { 'test.txt' }

  specify "works for lists" do
    set_file_contents 'one'
    vim.command("let b:switch_custom_definitions = [['one', 'two', 'three']]")

    vim.switch
    assert_file_contents 'two'

    vim.switch_reverse
    assert_file_contents 'one'
  end

  specify "doesn't works for hashes" do
    set_file_contents 'one'
    vim.command("let b:switch_custom_definitions = [{'one': 'two', 'two': 'three'}]")

    vim.switch
    assert_file_contents 'two'

    vim.switch_reverse
    assert_file_contents 'three'
  end

  specify "repeatability with vim-repeat" do
    set_file_contents 'three'
    vim.command("let b:switch_custom_definitions = [['one', 'two', 'three']]")

    vim.switch_reverse
    assert_file_contents 'two'

    vim.feedkeys('.')
    vim.write
    assert_file_contents 'one'
  end
end
