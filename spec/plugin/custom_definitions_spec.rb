require 'spec_helper'

describe "Custom definitions" do
  let(:filename) { 'test.txt' }

  specify 'by setting a buffer-local variable' do
    set_file_contents 'one'
    vim.command("let b:switch_custom_definitions = [['one', 'two']]")

    vim.switch
    assert_file_contents 'two'

    vim.command("let b:switch_custom_definitions = [['two', 'three']]")
    vim.switch
    assert_file_contents 'three'
  end

  specify 'by setting a global variable' do
    set_file_contents 'one'
    vim.command("let g:switch_custom_definitions = [['one', 'two']]")

    vim.switch
    assert_file_contents 'two'

    vim.command("let g:switch_custom_definitions = [['two', 'three']]")
    vim.switch
    assert_file_contents 'three'
  ensure
    vim.command("unlet g:switch_custom_definitions")
  end

  describe ":SwitchExtend" do
    specify "defaults to copying global definitions" do
      set_file_contents 'one'
      vim.command("let g:switch_custom_definitions = [['two', 'three']]")
      vim.command("SwitchExtend {'one': 'two'}")

      vim.switch
      assert_file_contents 'two'

      vim.switch
      assert_file_contents 'three'
    ensure
      vim.command("unlet g:switch_custom_definitions")
    end

    specify "allows defining multiple definitions with commas" do
      set_file_contents 'one'
      vim.command("SwitchExtend {'one': 'two'}, ['two', 'three']")

      vim.switch
      assert_file_contents 'two'

      vim.switch
      assert_file_contents 'three'
    end

    specify "only applies to buffer" do
      set_file_contents 'one'
      vim.command("SwitchExtend ['one', 'two']")

      vim.switch
      assert_file_contents 'two'

      write_file 'other.txt', 'one'
      vim.edit 'other.txt'

      vim.switch
      # no change
      expect(IO.read('other.txt').strip).to eq 'one'
    end
  end
end
