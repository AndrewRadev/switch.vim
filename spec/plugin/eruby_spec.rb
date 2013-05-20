require 'spec_helper'

describe "eruby definitions" do
  let(:filename) { 'test.erb' }

  specify "true/false" do
    set_file_contents '<% flag = true %>'

    vim.search('true').switch
    assert_file_contents '<% flag = false %>'

    vim.switch
    assert_file_contents '<% flag = true %>'
  end

  specify "hash style" do
    set_file_contents <<-EOF
      <% foo = {
        :one => 'two',
        :three => 4
      } %>
    EOF
    vim.search('one').switch
    vim.search('three').switch
    assert_file_contents <<-EOF
      <% foo = {
        one: 'two',
        three: 4
      } %>
    EOF

    vim.search('one').switch
    vim.search('three').switch
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

    vim.search '<% if'

    vim.switch
    assert_file_contents <<-EOF
      <% if true or (predicate?) %>
        <%= 'Hello, World!' %>
      <% end %>
    EOF

    vim.switch
    assert_file_contents <<-EOF
      <% if false and (predicate?) %>
        <%= 'Hello, World!' %>
      <% end %>
    EOF

    vim.switch
    assert_file_contents <<-EOF
      <% if predicate? %>
        <%= 'Hello, World!' %>
      <% end %>
    EOF
  end

  specify "tag type" do
    set_file_contents '<%= something %>'

    vim.switch; assert_file_contents '<% something %>'
    vim.switch; assert_file_contents '<%# something %>'
    vim.switch; assert_file_contents '<%=raw something %>'
    vim.switch; assert_file_contents '<%= something %>'

    set_file_contents '<% something -%>'

    vim.switch; assert_file_contents '<%# something %>'
  end

  specify "string type" do
    set_file_contents '<% foo = "bar" %>'

    vim.search('bar').switch
    assert_file_contents "<% foo = 'bar' %>"

    vim.switch
    assert_file_contents "<% foo = :bar %>"

    vim.switch
    assert_file_contents '<% foo = "bar" %>'
  end

  describe "(overrides)" do
    specify "true/false overrides if-clauses" do
      set_file_contents <<-EOF
        <% if false and (predicate?) %>
          <%= 'Hello, World!' %>
        <% end %>
      EOF

      vim.search('false').switch
      assert_file_contents <<-EOF
        <% if true and (predicate?) %>
          <%= 'Hello, World!' %>
        <% end %>
      EOF

      vim.normal('u').search('if').switch
      assert_file_contents <<-EOF
        <% if predicate? %>
          <%= 'Hello, World!' %>
        <% end %>
      EOF
    end

    specify "true/false overrides hash style" do
      set_file_contents <<-EOF
        <% foo = { :one => true } %>
      EOF

      vim.search('true').switch
      assert_file_contents <<-EOF
        <% foo = { :one => false } %>
      EOF

      vim.normal('u').search('one').switch
      assert_file_contents <<-EOF
        <% foo = { one: true } %>
      EOF
    end

    specify "true/false overrides tag type" do
      set_file_contents '<% true %>'

      vim.search('true').switch
      assert_file_contents '<% false %>'

      vim.normal('u').search('<%').switch
      assert_file_contents '<%# true %>'
    end

    specify "hash style overrides tag type" do
      set_file_contents '<% {:one => two} %>'

      vim.search('one').switch
      assert_file_contents '<% {one: two} %>'

      vim.normal('u').search('<%').switch
      assert_file_contents '<%# {:one => two} %>'
    end

    specify "if-clauses override tag type" do
      set_file_contents <<-EOF
        <% if predicate? %>
      EOF

      vim.switch
      assert_file_contents <<-EOF
        <% if true or (predicate?) %>
      EOF
    end
  end
end
