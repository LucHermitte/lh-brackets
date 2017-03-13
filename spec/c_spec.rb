# encoding: UTF-8
require 'spec_helper'
require 'pp'

RSpec.describe "C&C++ snippets", :c => true do
  let (:filename) { "test.c" }

  before :all do
    vim.command('runtime plugin/misc_map.vim') # Inoreab
  end

  before :each do
    vim.command('filetype plugin on')
    vim.set('ft=c')
    vim.command('runtime after/ftplugin/c/c_brackets.vim')
    vim.command('SetMarker <+ +>')
    vim.set('expandtab')
    vim.set('sw=2')
    clear_buffer
    sleep 1
    vim.feedkeys('i\<esc>') # pause
  end

  it "has loaded c ftplugin", :deps => true do
    expect(/ftplugin.c.c_brackets\.vim/).to be_sourced
  end


  specify "curly_bracket", :curly => true do
    expect(vim.echo('&ft')).to eq "c"
    expect(vim.echo('&sw')).to eq "2"
    expect(vim.echo('maparg("{", "i")')).to eq 'lh#brackets#opener("{",0,"",function(\'lh#cpp#brackets#close_curly\'),"}",0,' "'')"
    expect(vim.echo('maparg("\\\\", "i")')).to eq ''
    vim.feedkeys('i{\<esc>')
    sleep 1
    # vim.feedkeys('i\<esc>') # pause
    assert_buffer_contents <<-EOF
      {}<++>
    EOF
    # If not everthing has been recorded in the buffer, the '\' won't be
    # correctly detected => introduce a pause with <esc>
    vim.feedkeys('o\\\\\<esc>a{\<esc>')
    assert_buffer_contents <<-EOF
      {}<++>
      \\{}<++>
    EOF
  end

  specify "test_with_NL", :backslash => true do
    expect(vim.echo('&ft')).to eq "c"
    expect(vim.echo('&sw')).to eq "2"
    vim.command('Brackets #if\\ 0 #else!mark!\\n#endif -insert=0 -nl -trigger=µ')
    expect(vim.echo('maparg("µ", "v")')).to eq '<C-\\><C-N>@=lh#map#surround("#if 0!cursorhere!", "#else!mark!\\n#endif!mark!", 1, 1, \'\', 1, "µ")<CR>'
    set_buffer_contents <<-EOF
        instr1;
        instr2;
        instr3;
    EOF
    vim.normal("2gg")
    vim.feedkeys('µ\<esc>')
    assert_buffer_contents <<-EOF
        instr1;
        #if 0
        instr2;
        #else<++>
        #endif<++>
        instr3;
    EOF
  end

end

# vim:set sw=2:
