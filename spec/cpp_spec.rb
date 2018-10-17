# encoding: UTF-8
require 'spec_helper'
require 'pp'

RSpec.describe "C snippets", :c => true do
  let (:filename) { "test.c" }

  before :each do
    vim.runtime('plugin/misc_map.vim') # Inoreab
    vim.command('filetype plugin on')
    vim.set('ft=c')
    vim.runtime('after/ftplugin/c/c_brackets.vim') # default bracket mappings
    vim.set('expandtab')
    vim.set('sw=2')
    vim.command('SetMarker <+ +>')
    clear_buffer
    vim.command('call lh#style#clear()')
    expect(vim.echo('lh#style#use({"indent_brace_style": "K&R"}, {"buffer": 1})')).to eq "1"
    expect(vim.echo('lh#style#use({"spacesbeforeparens": "control-statements"}, {"buffer": 1})')).to eq "1"
    vim.runtime('spec/support/c-snippets.vim') # Inoreab if, xnoremap µ
  end

  it "has loaded C ftplugin", :deps => true do
    expect(/ftplugin.c.c_brackets\.vim/).to be_sourced
  end

  describe "insert a multi-lines 'if' snippet", :i_snippet => true do
    specify "tabs are expanded", :expandtab => true do
      vim.set('expandtab')
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
      vim.feedkeys('oif foo\<esc>')
      assert_buffer_contents <<-EOF
      void f() {
        instr1;
        if (foo) {
          <++>
        }<++>
        instr2;
        instr3;
      }
      EOF
    end
    specify "tabs are not expanded (sw=16)", :noexpandtab => true do
      vim.set('noexpandtab')
      vim.set('sw=16')
      expect(vim.echo('&ft')).to eq "c"
      expect(vim.echo('&sw')).to eq "16"
      # Check indenting and surrounding
      set_buffer_contents <<-EOF
      void f() {
		instr1;
		instr2;
		instr3;
      }
      EOF
      vim.normal("ggj")
      vim.feedkeys('oif foo\<esc>')
	assert_buffer_contents <<-EOF
	void f() {
			instr1;
			if (foo) {
					<++>
			}<++>
			instr2;
			instr3;
	}
	EOF
    end
    specify "tabs are not expanded (sw=8)", :noexpandtab => true do
      vim.set('noexpandtab')
      vim.set('sw=8')
      expect(vim.echo('&ft')).to eq "c"
      expect(vim.echo('&sw')).to eq "8"
      # Check indenting and surrounding
      set_buffer_contents <<-EOF
      void f() {
	instr1;
	instr2;
	instr3;
      }
      EOF
      vim.normal("ggj")
      vim.feedkeys('oif foo\<esc>')
	assert_buffer_contents <<-EOF
	void f() {
		instr1;
		if (foo) {
			<++>
		}<++>
		instr2;
		instr3;
	}
	EOF
    end
    specify "tabs are not expanded (sw=4)", :noexpandtab => true do
      vim.set('noexpandtab')
      vim.set('sw=4')
      expect(vim.echo('&ft')).to eq "c"
      expect(vim.echo('&sw')).to eq "4"
      # Check indenting and surrounding
      set_buffer_contents <<-EOF
      void f() {
          instr1;
          instr2;
          instr3;
      }
      EOF
      vim.normal("ggj")
      vim.feedkeys('oif foo\<esc>')
assert_buffer_contents <<-EOF
void f() {
    instr1;
    if (foo) {
	<++>
    }<++>
    instr2;
    instr3;
}
EOF
    end
  end

  describe "insert a multi-lines 'if' snippet after MB characters", :i_snippet => true, :MB => true do
    specify "tabs are expanded", :expandtab => true do
      vim.set('expandtab')
      expect(vim.echo('&ft')).to eq "c"
      expect(vim.echo('&sw')).to eq "2"
      # Check indenting and surrounding
      set_buffer_contents <<-EOF
      void f() {
        instr1;
        /*«»*/
        instr2;
        instr3;
      }
      EOF
      vim.normal("ggjj")
      vim.feedkeys('A if foo\<esc>')
      assert_buffer_contents <<-EOF
      void f() {
        instr1;
        /*«»*/ if (foo) {
          <++>
        }<++>
        instr2;
        instr3;
      }
      EOF
    end
    specify "tabs are not expanded (sw=16)", :noexpandtab => true do
      vim.set('noexpandtab')
      vim.set('sw=16')
      expect(vim.echo('&ft')).to eq "c"
      expect(vim.echo('&sw')).to eq "16"
      # Check indenting and surrounding
      set_buffer_contents <<-EOF
      void f() {
		instr1;
        	/*«»*/
		instr2;
		instr3;
      }
      EOF
      vim.normal("ggjj")
      vim.feedkeys('A if foo\<esc>')
	assert_buffer_contents <<-EOF
	void f() {
			instr1;
			/*«»*/ if (foo) {
					<++>
			}<++>
			instr2;
			instr3;
	}
	EOF
    end
    specify "tabs are not expanded (sw=8)", :noexpandtab => true do
      vim.set('noexpandtab')
      vim.set('sw=8')
      expect(vim.echo('&ft')).to eq "c"
      expect(vim.echo('&sw')).to eq "8"
      # Check indenting and surrounding
      set_buffer_contents <<-EOF
      void f() {
	instr1;
        /*«»*/
	instr2;
	instr3;
      }
      EOF
      vim.normal("ggjj")
      vim.feedkeys('A if foo\<esc>')
	assert_buffer_contents <<-EOF
	void f() {
		instr1;
		/*«»*/ if (foo) {
			<++>
		}<++>
		instr2;
		instr3;
	}
	EOF
    end
    specify "tabs are not expanded (sw=4)", :noexpandtab => true do
      vim.set('noexpandtab')
      vim.set('sw=4')
      expect(vim.echo('&ft')).to eq "c"
      expect(vim.echo('&sw')).to eq "4"
      # Check indenting and surrounding
      set_buffer_contents <<-EOF
      void f() {
          instr1;
          /*«»*/
          instr2;
          instr3;
      }
      EOF
      vim.normal("ggjj")
      vim.feedkeys('A if foo\<esc>')
assert_buffer_contents <<-EOF
void f() {
    instr1;
    /*«»*/ if (foo) {
	<++>
    }<++>
    instr2;
    instr3;
}
EOF
    end
  end

  describe "surround on V", :surround => true do
    specify "tabs are expanded", :expandtab => true do
      vim.set('expandtab')
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
    specify "tabs are not expanded (sw=16)", :noexpandtab => true do
      vim.set('noexpandtab')
      vim.set('sw=16')
      expect(vim.echo('&ft')).to eq "c"
      expect(vim.echo('&sw')).to eq "16"
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
    specify "tabs are not expanded (sw=8)", :noexpandtab => true do
      vim.set('noexpandtab')
      vim.set('sw=8')
      expect(vim.echo('&ft')).to eq "c"
      expect(vim.echo('&sw')).to eq "8"
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
    specify "tabs are not expanded (sw=4)", :noexpandtab => true do
      vim.set('noexpandtab')
      vim.set('sw=4')
      expect(vim.echo('&ft')).to eq "c"
      expect(vim.echo('&sw')).to eq "4"
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

  end

  describe "surround on v$ a badly indented code", :surround => true do
    specify "tabs are expanded", :expandtab => true do
      vim.set('expandtab')
      vim.runtime('spec/support/c-snippets.vim') # vmap µ
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

end

# vim:set sw=2:


