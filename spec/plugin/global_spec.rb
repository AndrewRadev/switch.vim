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
end
