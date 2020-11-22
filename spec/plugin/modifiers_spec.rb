require 'spec_helper'

describe "Modifiers" do
  let(:filename) { 'test.txt' }

  specify "normalized case" do
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

  specify "word boundaries" do
    set_file_contents "one\nPhonetics"
    vim.command("let b:switch_custom_definitions = [switch#Words(['one', 'two'])]")

    vim.search '\<one\>'
    vim.switch
    assert_file_contents "two\nPhonetics"

    vim.search 'Ph\zsonetics'
    vim.switch
    assert_file_contents "two\nPhonetics"
  end

  specify "normalized case with word boundaries" do
    set_file_contents "ONE\nPHONETICS"
    vim.command("let b:switch_custom_definitions = [switch#NormalizedCaseWords(['one', 'two'])]")

    vim.search '\<ONE\>'
    vim.switch
    assert_file_contents "TWO\nPHONETICS"

    vim.search 'PH\zsONETICS'
    vim.switch
    assert_file_contents "TWO\nPHONETICS"
  end
end
