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

  specify "turbofish" do
    set_file_contents 'let value = iterator.collect();'
    vim.set 'filetype', 'rust'

    vim.search('collect').switch
    assert_file_contents 'let value = iterator.collect::<Todo>();'

    vim.switch
    assert_file_contents 'let value = iterator.collect();'
  end

  specify "struct shorthand" do
    set_file_contents 'let processor = Processor { input: input, output };'
    vim.set 'filetype', 'rust'

    vim.search('input')
    vim.switch
    assert_file_contents 'let processor = Processor { input, output };'

    vim.search('output')
    vim.switch
    assert_file_contents 'let processor = Processor { input, output: output };'
  end
end
