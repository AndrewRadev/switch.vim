require 'spec_helper'

describe "coffee" do
  let(:filename) { 'test.coffee' }

  specify "arrows" do
    set_file_contents 'functionCall (foo) ->'
    vim.set 'filetype', 'coffee'

    vim.switch
    assert_file_contents 'functionCall (foo) =>'

    vim.switch
    assert_file_contents 'functionCall (foo) ->'
  end

  specify "dictionary shorthand" do
    set_file_contents 'foo = {one, two}'
    vim.set 'filetype', 'coffee'

    vim.search('one')
    vim.switch
    assert_file_contents 'foo = {one: one, two}'

    vim.search('two')
    vim.switch
    assert_file_contents 'foo = {one: one, two: two}'

    vim.switch
    assert_file_contents 'foo = {one: one, two}'

    vim.search('one')
    vim.switch
    assert_file_contents 'foo = {one, two}'
  end

  specify "dictionary shorthand (multiline)" do
    set_file_contents <<~EOF
      foo = {
        one,
        two
      }
    EOF
    vim.set 'filetype', 'coffee'

    vim.search('one')
    vim.switch
    assert_file_contents <<~EOF
      foo = {
        one: one,
        two
      }
    EOF

    vim.search('one')
    vim.switch

    assert_file_contents <<~EOF
      foo = {
        one,
        two
      }
    EOF
  end
end
