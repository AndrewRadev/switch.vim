require 'spec_helper'

describe "Git rebase definitions" do
  let(:filename) { 'git-rebase-todo' }

  specify "interactive commands" do
    set_file_contents <<-EOF
      pick 37b52fc Use SVG badge
      pick f6cde6d Make vim-speeddating works with switch.vim
      pick 97cd2db Some minor clarifications

      # Rebasage de 04c6c3a..97cd2db sur 04c6c3a (3 commandes)
    EOF
    vim.command('set filetype=gitrebase')

    vim.switch
    assert_file_contents <<-EOF
      fixup 37b52fc Use SVG badge
      pick f6cde6d Make vim-speeddating works with switch.vim
      pick 97cd2db Some minor clarifications

      # Rebasage de 04c6c3a..97cd2db sur 04c6c3a (3 commandes)
    EOF

    vim.switch
    assert_file_contents <<-EOF
      reword 37b52fc Use SVG badge
      pick f6cde6d Make vim-speeddating works with switch.vim
      pick 97cd2db Some minor clarifications

      # Rebasage de 04c6c3a..97cd2db sur 04c6c3a (3 commandes)
    EOF

    vim.switch
    assert_file_contents <<-EOF
      edit 37b52fc Use SVG badge
      pick f6cde6d Make vim-speeddating works with switch.vim
      pick 97cd2db Some minor clarifications

      # Rebasage de 04c6c3a..97cd2db sur 04c6c3a (3 commandes)
    EOF

    vim.switch
    assert_file_contents <<-EOF
      squash 37b52fc Use SVG badge
      pick f6cde6d Make vim-speeddating works with switch.vim
      pick 97cd2db Some minor clarifications

      # Rebasage de 04c6c3a..97cd2db sur 04c6c3a (3 commandes)
    EOF

    vim.switch
    assert_file_contents <<-EOF
      exec 37b52fc Use SVG badge
      pick f6cde6d Make vim-speeddating works with switch.vim
      pick 97cd2db Some minor clarifications

      # Rebasage de 04c6c3a..97cd2db sur 04c6c3a (3 commandes)
    EOF

    vim.switch
    assert_file_contents <<-EOF
      break 37b52fc Use SVG badge
      pick f6cde6d Make vim-speeddating works with switch.vim
      pick 97cd2db Some minor clarifications

      # Rebasage de 04c6c3a..97cd2db sur 04c6c3a (3 commandes)
    EOF

    vim.switch
    assert_file_contents <<-EOF
      drop 37b52fc Use SVG badge
      pick f6cde6d Make vim-speeddating works with switch.vim
      pick 97cd2db Some minor clarifications

      # Rebasage de 04c6c3a..97cd2db sur 04c6c3a (3 commandes)
    EOF

    vim.switch
    assert_file_contents <<-EOF
      label 37b52fc Use SVG badge
      pick f6cde6d Make vim-speeddating works with switch.vim
      pick 97cd2db Some minor clarifications

      # Rebasage de 04c6c3a..97cd2db sur 04c6c3a (3 commandes)
    EOF

    vim.switch
    assert_file_contents <<-EOF
      reset 37b52fc Use SVG badge
      pick f6cde6d Make vim-speeddating works with switch.vim
      pick 97cd2db Some minor clarifications

      # Rebasage de 04c6c3a..97cd2db sur 04c6c3a (3 commandes)
    EOF

    vim.switch
    assert_file_contents <<-EOF
      merge 37b52fc Use SVG badge
      pick f6cde6d Make vim-speeddating works with switch.vim
      pick 97cd2db Some minor clarifications

      # Rebasage de 04c6c3a..97cd2db sur 04c6c3a (3 commandes)
    EOF

    vim.switch
    assert_file_contents <<-EOF
      pick 37b52fc Use SVG badge
      pick f6cde6d Make vim-speeddating works with switch.vim
      pick 97cd2db Some minor clarifications

      # Rebasage de 04c6c3a..97cd2db sur 04c6c3a (3 commandes)
    EOF
  end
end
