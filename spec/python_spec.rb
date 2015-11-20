# encoding: UTF-8
require 'spec_helper'
require 'pp'

RSpec.describe "python snippets", :python => true do
  let (:filename) { "test.py" }

  before :each do
    vim.command('runtime plugin/misc_map.vim') # Inoreab
    vim.command('filetype plugin on')
    vim.set('ft=python')
    vim.set('expandtab')
    vim.set('sw=2')
    clear_buffer
  end

  it "has loaded python ftplugin", :deps => true do
    expect(/ftplugin.python.python_snippets\.vim/).to be_sourced
  end

  specify "if_clause", :if => true do
    expect(vim.echo('&sw')).to eq "2"
    vim.feedkeys('iif test\<m-del>action\<esc>')
    assert_buffer_contents <<-EOF
      if test:
        action
    EOF
    vim.feedkeys('oif test2\<m-del>action2\<esc>')
    assert_buffer_contents <<-EOF
      if test:
        action
        if test2:
          action2
    EOF
  end

  specify "if_elif_else_clause", :if => true, :else => true, :elif => true do
    expect(vim.echo('&sw')).to eq "2"
    vim.feedkeys 'iif test1\<m-del>action1\<cr>action2\<cr>'
    vim.feedkeys 'elif test2\<m-del>action3\<cr>else action4\<esc>'
    assert_buffer_contents <<-EOF
      if test1:
        action1
        action2
      elif test2:
        action3
      else:
        action4
    EOF
  end

  specify "for_clause", :for => true do
    vim.feedkeys('ifor test\<m-del>action\<esc>')
    assert_buffer_contents <<-EOF
      for test:
        action
    EOF
    vim.feedkeys('ofor test2\<m-del>action2\<esc>')
    assert_buffer_contents <<-EOF
      for test:
        action
        for test2:
          action2
    EOF
  end

  specify "for_in_list", :for => true do
    vim.feedkeys('i[v for v in mylist\<m-del>\<del>')
    assert_line_contents '[v for v in mylist]'
  end

  specify "while_clause", :while => true do
    vim.feedkeys('iwhile test\<m-del>action\<esc>')
    assert_buffer_contents <<-EOF
      while test:
        action
    EOF
    vim.feedkeys('owhile test2\<m-del>action2\<esc>')
    assert_buffer_contents <<-EOF
      while test:
        action
        while test2:
          action2
    EOF
  end

end

# vim:set sw=2:
