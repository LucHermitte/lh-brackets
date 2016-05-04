# encoding: UTF-8
require 'spec_helper'
require 'pp'

RSpec.describe "Vim snippets", :vim => true do
  let (:filename) { "test.vim" }

  before :each do
    vim.runtime('plugin/misc_map.vim') # Inoreab
    vim.command('filetype plugin on')
    vim.set('ft=vim')
    vim.runtime('after/ftplugin/vim/vim_brackets.vim') # Inoreab
    vim.set('expandtab')
    vim.set('sw=2')
    vim.command('SetMarker <+ +>')
    clear_buffer
  end

  it "has loaded vim ftplugin", :deps => true do
    expect(/ftplugin.vim.vim_brackets\.vim/).to be_sourced
  end

  specify "surround on V", :surround => true do
    vim.runtime('spec/support/vim-snippets.vim') # Inoreab
    expect(vim.echo('&ft')).to eq "vim"
    expect(vim.echo('&sw')).to eq "2"
    # Check indenting and surrounding
    set_buffer_contents <<-EOF
function! lh#map#_goto_mark(...) abort
  let crt_indent = indent(s:goto_lin)
  let s:fix_indent = s:old_indent - crt_indent
  call s:Verbose('fix indent <- %1 (old_indent:%2 - crt_indent:%3)', s:fix_indent, s:old_indent, crt_indent)
endfunction
    EOF
    vim.normal("ggjj")
    vim.feedkeys('Vj,iffoo\<esc>')
    vim.feedkeys('a\<esc>')
    assert_buffer_contents <<-EOF
function! lh#map#_goto_mark(...) abort
  let crt_indent = indent(s:goto_lin)
  if foo
    let s:fix_indent = s:old_indent - crt_indent
    call s:Verbose('fix indent <- %1 (old_indent:%2 - crt_indent:%3)', s:fix_indent, s:old_indent, crt_indent)
  endif<++>
endfunction
    EOF
  end

  specify "surround on v$", :surround => true do
    vim.runtime('spec/support/vim-snippets.vim') # Inoreab
    expect(vim.echo('&ft')).to eq "vim"
    expect(vim.echo('&sw')).to eq "2"
    # Check indenting and surrounding
    set_buffer_contents <<-EOF
function! lh#map#_goto_mark(...) abort
  let crt_indent = indent(s:goto_lin)
  let s:fix_indent = s:old_indent - crt_indent
  call s:Verbose('fix indent <- %1 (old_indent:%2 - crt_indent:%3)', s:fix_indent, s:old_indent, crt_indent)
endfunction
    EOF
    vim.normal("ggjj")
    vim.feedkeys('^v$,iffoo\<esc>')
    vim.feedkeys('a\<esc>')
    assert_buffer_contents <<-EOF
function! lh#map#_goto_mark(...) abort
  let crt_indent = indent(s:goto_lin)
  if foo
    let s:fix_indent = s:old_indent - crt_indent
  endif<++>
  call s:Verbose('fix indent <- %1 (old_indent:%2 - crt_indent:%3)', s:fix_indent, s:old_indent, crt_indent)
endfunction
    EOF
  end

end

# vim:set sw=2:

