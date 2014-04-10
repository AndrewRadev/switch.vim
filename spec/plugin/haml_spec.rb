require 'spec_helper'

describe "haml definitions" do
  let(:filename) { 'test.haml' }

  specify "hash style" do
    set_file_contents <<-EOF
      %a{:href => '/example'}
    EOF
    vim.search('href').switch
    assert_file_contents <<-EOF
      %a{href: '/example'}
    EOF

    vim.search('href').switch
    assert_file_contents <<-EOF
      %a{:href => '/example'}
    EOF
  end

  specify "if-clauses" do
    set_file_contents <<-EOF
      - if predicate?
        Hello, World!
    EOF

    vim.search 'if'

    vim.switch
    assert_file_contents <<-EOF
      - if true or (predicate?)
        Hello, World!
    EOF

    vim.switch
    assert_file_contents <<-EOF
      - if false and (predicate?)
        Hello, World!
    EOF

    vim.switch
    assert_file_contents <<-EOF
      - if predicate?
        Hello, World!
    EOF
  end

  specify "tag type" do
    set_file_contents '= something'

    vim.switch; assert_file_contents '- something'
    vim.switch; assert_file_contents '-# something'
    vim.switch; assert_file_contents '= something'
  end
end
