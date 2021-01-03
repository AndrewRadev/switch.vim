require 'spec_helper'

describe "rust definitions" do
  let(:filename) { 'test.rs' }

  specify "void typecheck" do
    set_file_contents 'let value = complicated_expression()'

    vim.search('value').switch
    assert_file_contents 'let value: () = complicated_expression()'

    vim.switch
    assert_file_contents 'let value = complicated_expression()'
  end

  specify "turbofish" do
    set_file_contents 'let value = iterator.collect();'

    vim.search('collect').switch
    assert_file_contents 'let value = iterator.collect::<Todo>();'

    vim.switch
    assert_file_contents 'let value = iterator.collect();'
  end

  specify "struct shorthand" do
    set_file_contents 'let processor = Processor { input: input, output };'

    vim.search('input')
    vim.switch
    assert_file_contents 'let processor = Processor { input, output };'

    vim.search('output')
    vim.switch
    assert_file_contents 'let processor = Processor { input, output: output };'
  end

  specify "raw strings" do
    set_file_contents 'let hello = "Hello, World!";'
    vim.search('Hello')

    vim.switch
    assert_file_contents 'let hello = r"Hello, World!";'

    vim.switch
    assert_file_contents 'let hello = r#"Hello, World!"#;'

    vim.switch
    assert_file_contents 'let hello = "Hello, World!";'
  end

  specify "is_some/is_none" do
    set_file_contents 'if list.get(1).is_some() {'
    vim.search('is_some')

    vim.switch
    assert_file_contents 'if list.get(1).is_none() {'

    vim.switch
    assert_file_contents 'if list.get(1).is_some() {'
  end

  specify "assert_eq/assert_ne" do
    set_file_contents 'assert_eq!(foo, bar);'
    vim.search('assert_eq')

    vim.switch
    assert_file_contents 'assert_ne!(foo, bar);'

    vim.switch
    assert_file_contents 'assert_eq!(foo, bar);'
  end
end
