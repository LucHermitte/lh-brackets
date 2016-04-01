# encoding: UTF-8
require 'spec_helper'
require 'pp'

RSpec.describe "TeX snippets", :tex => true do
  let (:filename) { "test.tex" }

  before :each do
    vim.command('runtime plugin/misc_map.vim') # Inoreab
    vim.command('filetype plugin on')
    vim.set('ft=tex')
    vim.command('runtime after/ftplugin/tex/tex_brackets.vim') # Inoreab
    vim.set('expandtab')
    vim.set('sw=2')
    clear_buffer
  end

  it "has loaded tex ftplugin", :deps => true do
    expect(/ftplugin.tex.tex_brackets\.vim/).to be_sourced
  end

  specify "curly_bracket", :curly => true do
    expect(vim.echo('&ft')).to eq "tex"
    expect(vim.echo('&sw')).to eq "2"
    expect(vim.echo('maparg("{", "i")')).to eq 'lh#brackets#opener('"'{',1,"'"","{","}",0,' "'')"
    expect(vim.echo('maparg("\\\\", "i")')).to eq ''
    vim.feedkeys('i{\<esc>')
    assert_buffer_contents <<-EOF
      {}<++>
    EOF
    # If not everthing has been recorded in the buffer, the '\' won't be
    # correctly detected => introduce a pause with <esc>
    vim.feedkeys('o\\\\\<esc>a{\<esc>')
    assert_buffer_contents <<-EOF
      {}<++>
      \\{\\}<++>
    EOF
  end

  specify "test_with_backslash", :backslash => true do
    expect(vim.echo('&ft')).to eq "tex"
    expect(vim.echo('&sw')).to eq "2"
    vim.command('Brackets \\Q{ } -trigger=µ')
    vim.feedkeys('iµ\<esc>')
    assert_buffer_contents <<-EOF
      \\Q{}<++>
    EOF

    vim.feedkeys('osomeword\<esc>µ')
    assert_buffer_contents <<-EOF
      \\Q{}<++>
      \\Q{someword}
    EOF
  end

end

# vim:set sw=2:

