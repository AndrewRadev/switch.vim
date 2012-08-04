require 'spec_helper'

describe "ruby definitions" do
  let(:filename) { 'test.rb' }

  specify "true/false" do
    set_file_contents 'flag = true'
    VIM.search('true')

    switch
    assert_file_contents 'flag = false'

    switch
    assert_file_contents 'flag = true'

    VIM.search('flag').switch
    assert_file_contents 'flag = true'
  end

  # TODO (2012-08-04) Vimrunner: fluid interface
  specify "hash style" do
    set_file_contents <<-EOF
      foo = {
        :one => 'two',
        :three => 4
      }
    EOF
    VIM.search('one').switch
    VIM.search('three').switch
    assert_file_contents <<-EOF
      foo = {
        one: 'two',
        three: 4
      }
    EOF

    VIM.search('one').switch
    VIM.search('three').switch
    assert_file_contents <<-EOF
      foo = {
        :one => 'two',
        :three => 4
      }
    EOF
  end
end
