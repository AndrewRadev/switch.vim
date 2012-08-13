require 'spec_helper'

describe "ruby definitions" do
  let(:filename) { 'test.rb' }

  specify "true/false" do
    set_file_contents 'flag = true'

    VIM.search('true').switch
    assert_file_contents 'flag = false'

    VIM.switch
    assert_file_contents 'flag = true'

    VIM.search('flag').switch
    assert_file_contents 'flag = true'
  end

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

  specify "rspec should/should_not" do
    set_file_contents '1.should eq 1'

    VIM.search('should').switch
    assert_file_contents '1.should_not eq 1'

    VIM.switch
    assert_file_contents '1.should eq 1'
  end

  specify "if-clauses" do
    set_file_contents <<-EOF
      if predicate?
        puts 'Hello, World!'
      end
    EOF

    VIM.search 'if'

    VIM.switch
    assert_file_contents <<-EOF
      if true or (predicate?)
        puts 'Hello, World!'
      end
    EOF

    VIM.switch
    assert_file_contents <<-EOF
      if false and (predicate?)
        puts 'Hello, World!'
      end
    EOF

    VIM.switch
    assert_file_contents <<-EOF
      if predicate?
        puts 'Hello, World!'
      end
    EOF
  end

  describe "(overrides)" do
    specify "true/false overrides hash style" do
      set_file_contents <<-EOF
        foo = { :one => true }
      EOF

      VIM.search('true').switch
      assert_file_contents <<-EOF
        foo = { :one => false }
      EOF

      VIM.normal('u').search('one').switch
      assert_file_contents <<-EOF
        foo = { one: true }
      EOF
    end
  end
end
