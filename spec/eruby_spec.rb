require 'spec_helper'

describe "eruby definitions" do
  let(:filename) { 'test.erb' }

  specify "true/false" do
    set_file_contents '<% flag = true %>'

    VIM.search('true').switch
    assert_file_contents '<% flag = false %>'

    VIM.switch
    assert_file_contents '<% flag = true %>'
  end

  specify "hash style" do
    set_file_contents <<-EOF
      <% foo = {
        :one => 'two',
        :three => 4
      } %>
    EOF
    VIM.search('one').switch
    VIM.search('three').switch
    assert_file_contents <<-EOF
      <% foo = {
        one: 'two',
        three: 4
      } %>
    EOF

    VIM.search('one').switch
    VIM.search('three').switch
    assert_file_contents <<-EOF
      <% foo = {
        :one => 'two',
        :three => 4
      } %>
    EOF
  end

  specify "if-clauses" do
    set_file_contents <<-EOF
      <% if predicate? %>
        <%= 'Hello, World!' %>
      <% end %>
    EOF

    VIM.search '<% if'

    VIM.switch
    assert_file_contents <<-EOF
      <% if true or (predicate?) %>
        <%= 'Hello, World!' %>
      <% end %>
    EOF

    VIM.switch
    assert_file_contents <<-EOF
      <% if false and (predicate?) %>
        <%= 'Hello, World!' %>
      <% end %>
    EOF

    VIM.switch
    assert_file_contents <<-EOF
      <% if predicate? %>
        <%= 'Hello, World!' %>
      <% end %>
    EOF
  end

  specify "tag type" do
    set_file_contents '<%= something %>'

    VIM.switch; assert_file_contents '<% something %>'
    VIM.switch; assert_file_contents '<%# something %>'
    VIM.switch; assert_file_contents '<%=raw something %>'
    VIM.switch; assert_file_contents '<%= something %>'

    set_file_contents '<% something -%>'

    VIM.switch; assert_file_contents '<%# something %>'
  end
end
