require 'spec_helper'

describe "rust definitions" do
  let(:filename) { 'test.rs' }

  specify "void typecheck" do
    set_file_contents 'let value = complicated_expression()'
    vim.set 'filetype', 'rust'

    vim.search('value').switch
    assert_file_contents 'let value: () = complicated_expression()'

    vim.switch
    assert_file_contents 'let value = complicated_expression()'
  end
end
