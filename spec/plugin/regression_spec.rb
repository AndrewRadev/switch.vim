require 'spec_helper'

describe "regression fixes" do
  let(:filename) { 'test.txt' }

  it "is not affected by &whichwrap" do
    set_file_contents <<-EOF
      foo = true
      bar
    EOF

    vim.set 'whichwrap', 'l'

    vim.search 'true'
    vim.switch
    assert_file_contents <<-EOF
      foo = false
      bar
    EOF

    vim.set 'whichwrap&vim'
  end

  specify "limits subpatterns" do
    def filename
      'test.rb'
    end

    set_file_contents "['zero'] + ['one', 'two']"

    vim.search("['one").switch
    assert_file_contents "['zero'] + %w(one two)"

    vim.switch
    assert_file_contents "['zero'] + ['one', 'two']"
  end

  specify "verymagic patterns" do
    set_file_contents "xyz = abc;"

    vim.command <<-EOF
      let b:switch_definitions = [ {'\\vabc': 'def'} ]
    EOF

    vim.search("abc").switch
    assert_file_contents "xyz = def;"
  end
end
