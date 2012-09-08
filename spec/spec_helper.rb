require 'tmpdir'
require 'vimrunner'
require_relative './support/vim'

RSpec.configure do |config|
  config.include Support::Vim

  # cd into a temporary directory for every example.
  config.around do |example|
    @vim = Vimrunner.start
    @vim.add_plugin(File.expand_path('.'), 'plugin/switch.vim')

    def @vim.switch
      command 'Switch'
      write
      self
    end

    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        @vim.command("cd #{dir}")
        example.call
      end
    end

    @vim.kill
  end
end
