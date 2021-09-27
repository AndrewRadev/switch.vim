require 'spec_helper'

describe "Funcref replacement" do
  let(:filename) { 'test.txt' }

  specify "function call" do
    set_file_contents 'one'
    vim.command("function! Custom(match) \n return a:match[0] . '1' \n endfunction")
    vim.command("let b:switch_custom_definitions = [{ 'one': funcref('Custom') }]")

    vim.switch
    assert_file_contents 'one1'
  end

  specify "lambda" do
    set_file_contents 'two'
    vim.command("let b:switch_custom_definitions = [{ 'two': {m -> m[0].'2'} }]")

    vim.switch
    assert_file_contents 'two2'
  end
end
