require 'spec_helper'

describe "coffee" do
  let(:filename) { 'test.coffee' }

  specify "pointers" do
    set_file_contents 'functionCall (foo) ->'
    VIM.set 'filetype', 'coffee'

    VIM.switch
    assert_file_contents 'functionCall (foo) =>'

    VIM.switch
    assert_file_contents 'functionCall (foo) ->'
  end
end
