module Support
  module Vim
    def set_file_contents(string)
      string = normalize_string(string)
      File.open(filename, 'w') { |f| f.write(string) }
      @vim.edit filename
    end

    def file_contents
      IO.read(filename).strip
    end

    def assert_file_contents(string)
      file_contents.should eq normalize_string(string)
    end

    private

    def normalize_string(string)
      whitespace = string.scan(/^\s*/).first
      string.split("\n").map { |line| line.gsub /^#{whitespace}/, '' }.join("\n").strip
    end
  end
end
