# encoding: UTF-8
require 'spec_helper'
require 'pp'

RSpec.describe "C snippets", :c => true do
  let (:filename) { "test.c" }

  before :each do
    vim.runtime('plugin/misc_map.vim') # Inoreab
    vim.command('filetype plugin on')
    vim.set('ft=c')
    vim.runtime('after/ftplugin/c/c_brackets.vim') # Inoreab
    vim.set('expandtab')
    vim.set('sw=2')
    vim.command('SetMarker <+ +>')
    clear_buffer
    vim.command('call lh#style#clear()')
  end

  it "has loaded vim ftplugin", :deps => true do
    expect(/ftplugin.c.c_brackets\.vim/).to be_sourced
  end

  specify "surround on V", :surround => true do
    expect(vim.echo('lh#style#use({"indent_brace_style": "K&R"}, {"buffer": 1})')).to eq "1"
    expect(vim.echo('lh#style#use({"spacesbeforeparens": "control-statements"}, {"buffer": 1})')).to eq "1"
    vim.runtime('spec/support/c-snippets.vim') # Inoreab
    expect(vim.echo('&ft')).to eq "c"
    expect(vim.echo('&sw')).to eq "2"
    # Check indenting and surrounding
    set_buffer_contents <<-EOF
    void f() {
      instr1;
      instr2;
      instr3;
    }
    EOF
    vim.normal("ggj")
    vim.feedkeys('Vjµfoo\<esc>')
    vim.feedkeys('a\<esc>')
    # expect(vim.echo('input("pause")')).to eq ""
    assert_buffer_contents <<-EOF
    void f() {
      if (foo) {
        instr1;
        instr2;
      }<++>
      instr3;
    }
    EOF
  end

  specify "surround on v$ a badly indented code", :surround => true do
    expect(vim.echo('lh#style#use({"indent_brace_style": "K&R"}, {"buffer": 1})')).to eq "1"
    expect(vim.echo('lh#style#use({"spacesbeforeparens": "control-statements"}, {"buffer": 1})')).to eq "1"
    vim.runtime('spec/support/c-snippets.vim') # Inoreab
    expect(vim.echo('&ft')).to eq "c"
    expect(vim.echo('&sw')).to eq "2"
    # Check indenting and surrounding
    set_buffer_contents <<-EOF
    void f() {
      if (foo) {
                instr1;
      }<++>
      instr2;
      instr3;
    }
    EOF
    vim.normal("ggjj")
    vim.feedkeys('$v^µbar\<esc>')
    vim.feedkeys('a\<esc>')
    assert_buffer_contents <<-EOF
    void f() {
      if (foo) {
        if (bar) {
          instr1;
        }<++>
      }<++>
      instr2;
      instr3;
    }
    EOF
  end

end

# vim:set sw=2:


