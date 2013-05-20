require 'spec_helper'

describe "cpp" do
  let(:filename) { 'test.cpp' }

  specify "pointers" do
    set_file_contents 'Object* foo = bar->baz;'

    vim.search('bar')
    vim.switch
    assert_file_contents 'Object* foo = bar.baz;'

    vim.switch
    assert_file_contents 'Object* foo = bar->baz;'
  end
end
