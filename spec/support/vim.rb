module Support
  module Vim
    def set_file_contents(string)
      write_file(filename, string)
      vim.edit(filename)
    end

    def file_contents
      IO.read(filename).strip
    end

    def assert_file_contents(string)
      file_contents.should eq normalize_string_indent(string)
    end
  end
end
