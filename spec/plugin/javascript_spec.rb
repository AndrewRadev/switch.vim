require 'spec_helper'

describe "javascript definitions" do
  let(:filename) { 'test.js' }

  specify "function definition" do
    set_file_contents <<-EOF
      function example(one, two) { }
    EOF

    vim.search('example').switch

    assert_file_contents <<-EOF
      const example = (one, two) => { }
    EOF

    vim.search('example').switch

    assert_file_contents <<-EOF
      function example(one, two) { }
    EOF
  end

  specify "async function definition" do
    set_file_contents <<-EOF
      async function example(one, two) { }
    EOF

    vim.search('example').switch

    assert_file_contents <<-EOF
      const example = async (one, two) => { }
    EOF

    vim.search('example').switch

    assert_file_contents <<-EOF
      async function example(one, two) { }
    EOF
  end

  specify "var function definition" do
    set_file_contents <<-EOF
      var example = function(one, two) { }
    EOF

    vim.search('example').switch

    assert_file_contents <<-EOF
      function example(one, two) { }
    EOF
  end

  specify "arrow functions (with no arguments)" do
    set_file_contents <<-EOF
      something.forEach(function() { });
    EOF

    vim.search('function').switch

    assert_file_contents <<-EOF
      something.forEach(() => { });
    EOF

    vim.search('()').switch

    assert_file_contents <<-EOF
      something.forEach(function() { });
    EOF
  end

  specify "arrow functions (with several arguments)" do
    set_file_contents <<-EOF
      something.forEach(function(one, two) { });
    EOF

    vim.search('function').switch

    assert_file_contents <<-EOF
      something.forEach((one, two) => { });
    EOF

    vim.search('one').switch

    assert_file_contents <<-EOF
      something.forEach(function(one, two) { });
    EOF
  end

  specify "arrow functions (with one argument)" do
    set_file_contents <<-EOF
      something.forEach(function(one) { });
    EOF

    vim.search('function').switch

    assert_file_contents <<-EOF
      something.forEach(one => { });
    EOF

    vim.search('one').switch

    assert_file_contents <<-EOF
      something.forEach(function(one) { });
    EOF
  end
end
