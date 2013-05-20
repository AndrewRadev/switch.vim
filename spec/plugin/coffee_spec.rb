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
end
