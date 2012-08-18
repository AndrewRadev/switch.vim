require 'spec_helper'

describe "cpp" do
  let(:filename) { 'test.cpp' }

  specify "pointers" do
    set_file_contents 'Object* foo = bar->baz;'

    VIM.search('bar')
    VIM.switch
    assert_file_contents 'Object* foo = bar.baz;'

    VIM.switch
    assert_file_contents 'Object* foo = bar->baz;'
  end
end
