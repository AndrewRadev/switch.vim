# encoding: utf-8

require 'spec_helper'

describe "multibyte support" do
  let(:filename) { 'test.txt' }

  specify "doesn't get confused by multibyte characters on the line" do
    set_file_contents '是; flag = true'
    vim.search 'true'
    vim.switch
    assert_file_contents '是; flag = false'
  end

  specify "works for multibyte replacements (simple case)" do
    set_file_contents '是'
    vim.command("let b:switch_definitions = [['是', '否']]")
    vim.switch
    assert_file_contents '否'

    set_file_contents '|是'
    vim.command("let b:switch_definitions = [['是', '否']]")
    vim.normal 'l'
    vim.switch
    assert_file_contents '|否'

    set_file_contents '是|'
    vim.command("let b:switch_definitions = [['是', '否']]")
    vim.switch
    assert_file_contents '否|'
  end

  specify "works for multibyte replacements (nested case)" do
    set_file_contents '是是-是是'
    vim.command <<-EOF
      let b:switch_definitions = [{'是.*是': {'是': '否'}}]"
    EOF

    vim.switch
    assert_file_contents '否否-否否'
  end
end
