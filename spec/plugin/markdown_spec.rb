require 'spec_helper'

describe "markdown" do
  let(:filename) { 'test.md' }

  specify "tasklist checkboxes" do
    set_file_contents <<-EOF
      - [ ] one
      - [x] two three
      - [ ] true
    EOF

    vim.search('one').switch

    assert_file_contents <<-EOF
      - [x] one
      - [x] two three
      - [ ] true
    EOF

    vim.search('two').switch

    assert_file_contents <<-EOF
      - [x] one
      - [ ] two three
      - [ ] true
    EOF

    vim.search('true').switch

    assert_file_contents <<-EOF
      - [x] one
      - [ ] two three
      - [ ] false
    EOF

    vim.search('- \[\zs \] false').switch

    assert_file_contents <<-EOF
      - [x] one
      - [ ] two three
      - [x] false
    EOF
  end
end
