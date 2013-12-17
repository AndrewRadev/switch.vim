require 'spec_helper'

describe "scala definitions" do
  let(:filename) { 'test.scala' }

  specify "true/false" do
    set_file_contents 'val flag = true'
    vim.set 'filetype', 'scala'

    vim.search('true').switch
    assert_file_contents 'val flag = false'

    vim.switch
    set_file_contents 'val flag = true'

    vim.search('flag').switch
    set_file_contents 'val flag = true'
  end

  specify "string type" do
    set_file_contents 'val foo = "bar"'
    vim.set 'filetype', 'scala'

    vim.search('bar').switch
    assert_file_contents 'val foo = s"bar"'

    vim.switch
    assert_file_contents 'val foo = f"bar"'

    vim.switch
    assert_file_contents 'val foo = """bar"""'

    vim.switch
    assert_file_contents 'val foo = s"""bar"""'

    vim.switch
    assert_file_contents 'val foo = f"""bar"""'

    vim.switch
    assert_file_contents 'val foo = "bar"'
  end
end
