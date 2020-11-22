require 'spec_helper'

describe "clojure definitions" do
  let(:filename) { 'test.clj' }

  specify "true/false" do
    set_file_contents '(def flag true)'
    vim.set 'filetype', 'clojure'

    vim.search('true').switch
    assert_file_contents '(def flag false)'

    vim.switch
    set_file_contents '(def flag true)'

    vim.search('flag').switch
    set_file_contents '(def flag true)'
  end

  specify "if-clauses" do
    set_file_contents <<-EOF
      (if predicate?
        (prn "Hello, world!")
        (prn "oh..."))
    EOF
    vim.set 'filetype', 'clojure'

    vim.search 'if'

    vim.switch
    assert_file_contents <<-EOF
      (if (or true predicate?)
        (prn "Hello, world!")
        (prn "oh..."))
    EOF

    vim.switch
    assert_file_contents <<-EOF
      (if (and false predicate?)
        (prn "Hello, world!")
        (prn "oh..."))
    EOF

    vim.switch
    assert_file_contents <<-EOF
      (if predicate?
        (prn "Hello, world!")
        (prn "oh..."))
    EOF
  end

  specify "string type" do
    set_file_contents '(def foo "bar")'
    vim.set 'filetype', 'clojure'

    vim.search('bar').switch
    assert_file_contents "(def foo 'bar)"

    vim.switch
    assert_file_contents "(def foo :bar)"

    vim.switch
    assert_file_contents '(def foo "bar")'
  end

  specify "string type" do
    set_file_contents '(def foo "ba-r!")'
    vim.set 'filetype', 'clojure'

    vim.search('ba-r').switch
    assert_file_contents "(def foo 'ba-r!)"

    vim.switch
    assert_file_contents "(def foo :ba-r!)"

    vim.switch
    assert_file_contents '(def foo "ba-r!")'
  end
end
