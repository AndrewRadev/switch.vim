require 'spec_helper'

describe "Cargo.toml definitions" do
  let(:filename) { 'Cargo.toml' }

  specify "dependency versions" do
    pending "TOML is not a built-in filetype" if ENV['TRAVIS_CI']

    set_file_contents <<-EOF
      package-name = "> 0.3.15 <= 0.3.39"
    EOF
    vim.command('set filetype=toml')
    vim.switch

    assert_file_contents <<-EOF
      package-name = { version = "> 0.3.15 <= 0.3.39" }
    EOF

    vim.switch
    assert_file_contents <<-EOF
      package-name = "> 0.3.15 <= 0.3.39"
    EOF
  end
end
