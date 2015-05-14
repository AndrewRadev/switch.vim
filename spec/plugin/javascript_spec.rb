require 'spec_helper'

describe "javascript definitions" do
  let(:filename) { 'test.js' }

  specify "function definition" do
    set_file_contents <<-EOF
      function example(one, two) { }
    EOF

    vim.search('example').switch

    assert_file_contents <<-EOF
      var example = function(one, two) { }
    EOF

    vim.search('example').switch

    assert_file_contents <<-EOF
      function example(one, two) { }
    EOF
  end
end
