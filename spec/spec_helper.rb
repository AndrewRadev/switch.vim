require 'vimrunner'
require 'vimrunner/rspec'
require_relative 'support/vim'

Vimrunner::RSpec.configure do |config|
  config.reuse_server = true

  plugin_path = Pathname.new(File.expand_path('.'))

  config.start_vim do
    vim = Vimrunner.start_gvim
    vim.add_plugin(plugin_path, 'plugin/switch.vim')

    # Up-to-date filetype support:
    vim.prepend_runtimepath(plugin_path.join('spec/support/rust.vim'))
    vim.prepend_runtimepath(plugin_path.join('spec/support/vim-clojure-static'))

    # vim-repeat for testing dot-repetition:
    vim.prepend_runtimepath(plugin_path.join('spec/support/vim-repeat'))

    # bootstrap filetypes
    vim.command 'autocmd BufNewFile,BufRead *.rs set filetype=rust'
    vim.command 'autocmd BufNewFile,BufRead *.clj set filetype=clojure'

    def vim.switch
      command 'Switch'
      write
      self
    end

    def vim.switch_reverse
      command 'SwitchReverse'
      write
      self
    end

    vim
  end
end

RSpec.configure do |config|
  config.include Support::Vim
end
