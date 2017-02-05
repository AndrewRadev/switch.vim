require 'spec_helper'

describe "explicit definitions" do
  let(:filename) { 'test.txt' }

  specify "allows providing explicit definitions to the public function" do
    vim.command("let g:explicit_definitions = [{'foo_bar': 'foo'}]")

    set_file_contents 'foo_bar'
    vim.command('echo switch#Switch({"definitions": g:explicit_definitions})')
    vim.write

    assert_file_contents 'foo'
  end
end
