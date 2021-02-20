require 'spec_helper'

describe "vim definitions" do
  let(:filename) { 'test.vim' }

  specify "script-local functions" do
    set_file_contents <<~EOF
      call s:TestFunction()
    EOF

    vim.search('TestFunction').switch
    assert_file_contents <<~EOF
      call <SID>TestFunction()
    EOF

    vim.switch
    assert_file_contents <<~EOF
      call s:TestFunction()
    EOF
  end
end
