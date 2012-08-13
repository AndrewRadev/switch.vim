require 'spec_helper'

describe "global definitions" do
  let(:filename) { 'test.txt' }

  specify "&&/||" do
    set_file_contents 'foo && bar'
    VIM.search '&&'

    VIM.switch
    assert_file_contents 'foo || bar'

    VIM.switch
    assert_file_contents 'foo && bar'
  end

  specify "true/false" do
    set_file_contents 'flag = true'
    VIM.search 'true'

    VIM.switch
    assert_file_contents 'flag = false'

    VIM.switch
    assert_file_contents 'flag = true'
  end
end
