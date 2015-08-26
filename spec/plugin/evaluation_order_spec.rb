require 'spec_helper'

describe "evaluation order" do
  let(:filename) { 'test.txt' }

  specify "targets smallest match" do
    vim.command("let g:switch_custom_definitions = [{'foo_bar': 'foo'}, {'foo': 'foo_bar'}]")

    set_file_contents 'foo_bar'
    vim.switch
    assert_file_contents 'foo_bar_bar'
  end

  context "with in-order execution" do
    before do
      vim.command("let g:switch_find_smallest_match = 0")
    end

    after do
      vim.command("let g:switch_find_smallest_match = 1")
    end

    specify "respects definition order" do
      vim.command("let g:switch_custom_definitions = [{'foo_bar': 'foo'}, {'foo': 'foo_bar'}]")

      set_file_contents 'foo_bar'
      vim.switch
      assert_file_contents 'foo'
    end

    specify "respects in-definition order for lists" do
      vim.command("let g:switch_custom_definitions = [['* Y', '* N', '*']]")

      set_file_contents '* Y'
      vim.switch
      assert_file_contents '* N'
    end
  end
end
