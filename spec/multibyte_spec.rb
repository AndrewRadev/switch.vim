# encoding: utf-8

require 'spec_helper'

describe "multibyte support" do
  let(:filename) { 'test.txt' }
  let(:vim) { @vim }

  specify "doesn't get confused by multibyte characters on the line" do
    set_file_contents '是; flag = true'
    vim.search 'true'
    vim.switch
    assert_file_contents '是; flag = false'
  end

  specify "works for multibyte replacements" do
    vim.command("let g:switch_definitions = [['是', '否']]")

    set_file_contents '是'
    vim.switch
    assert_file_contents '否'

    set_file_contents '是|'
    vim.switch
    assert_file_contents '否|'
  end
end
