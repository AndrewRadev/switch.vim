require 'spec_helper'

describe "Normalized case mapping" do
  let(:filename) { 'test.txt' }

  specify "a single word" do
    set_file_contents 'one'
    vim.command("let b:switch_custom_definitions = [switch#NormalizedCase(['one', 'two'])]")

    vim.switch
    assert_file_contents 'two'

    set_file_contents 'One'
    vim.switch
    assert_file_contents 'Two'

    set_file_contents 'ONE'
    vim.switch
    assert_file_contents 'TWO'
  end
end
