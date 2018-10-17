# encoding: UTF-8
require 'spec_helper'
require 'pp'
require 'support/vim_matchers'

RSpec.describe "autoload/lh/map.vim" do
  # after(:all) do
    # vim.kill
  # end

  describe "Checks dependent plugins are available", :deps => true do
      it "has lh-vim-lib" do
          expect(vim.echo('&rtp')).to match(/lh-vim-lib/)
          expect(vim.echo('lh#option#is_unset(lh#option#unset())')).to eq "1"
          expect(/autoload.lh.option\.vim/).to be_sourced
      end
      it "Has lh-style" do
          expect(vim.echo('&rtp')).to match(/lh-style/)
          expect(vim.echo('lh#style#version()')).to be >= "100"
          expect(/autoload.lh.style\.vim/).to be_sourced
      end
  end

  describe "lh#map#version is >= 2.3.2" do
      it "Checks the current script version" do
          expect(vim.echo('lh#map#version()')).to be >= ('232')
      end
  end

  describe "Brackets definitions are loaded" do
      it "Checks :Brackets exists" do
          expect(vim.command("command Brackets")).to match(/lh#brackets#define/)
      end
      it "Checks brackets are activated" do
          expect(vim.echo("lh#option#get('cb_no_default_brackets', 0)")).to eq "0"
      end
      it "has an imapping to (" do
          expect(vim.command("imap (")).to match(/lh#brackets#opener/)
      end
  end

  describe "Test bracket-pair insertions (and redo)", :brackets, :usemarks => true do
      before :all do
          vim.command('SetMarker « »')
      end

      before :each do
          clear_buffer
          vim.set('ft=')
      end

      specify "Inserts foo(bar", :redo, :paren => true do
          vim.feedkeys('i(\<esc>')
          assert_line_contents <<-EOF
            ()«»
          EOF
          vim.feedkeys 'ofoo(bar\<esc>'
          assert_line_contents <<-EOF
            foo(bar)«»
          EOF
          has_redo = vim.echo('has("patch-7.4.849")')
          if has_redo == "1"
              vim.type(".")
              expect(vim.echo('getline(".")')).to eq "foo(bar)«»"
          end
          # vim.echo('input("pause")')
      end
      specify "Inserts foo(bar)foo", :redo, :paren => true do
          has_redo = vim.echo('has("patch-7.4.849")')
          vim.feedkeys('ofoo(bar)foo\<esc>')
          assert_line_contents <<-EOF
            foo(bar)foo
          EOF
          if has_redo == "1"
              vim.type(".")
              assert_line_contents <<-EOF
                foo(bar)foo
              EOF
          end
      end

      specify "Inserts foo\"bar", :redo, :quote => true do
          has_redo = vim.echo('has("patch-7.4.849")')
          vim.feedkeys('i"\<esc>')
          assert_line_contents <<-EOF
            ""«»
          EOF
          vim.feedkeys 'ofoo"bar\<esc>'
          assert_line_contents <<-EOF
            foo"bar"«»
          EOF
          if has_redo == "1"
              vim.type(".")
              expect(vim.echo('getline(".")')).to eq "foo\"bar\"«»"
          end
      end
      specify "Inserts foo\"bar\"foo", :redo, :quote => true do
          has_redo = vim.echo('has("patch-7.4.849")')
          vim.feedkeys('ofoo"bar"foo\<esc>')
          assert_line_contents <<-EOF
            foo"bar"foo
          EOF
          if has_redo == "1"
              vim.type(".")
              assert_line_contents <<-EOF
                foo"bar"foo
              EOF
          end
      end

      specify "Inserts Brackets with newline", :newline => true do
          vim.command('Brackets <+ +> -nl')

          vim.feedkeys 'i<+\<esc>'
          assert_buffer_contents <<-EOF
              <+

              +>«»
          EOF

          clear_buffer
          vim.feedkeys 'i<+foo\<esc>'
          assert_buffer_contents <<-EOF
              <+
              foo
              +>«»
          EOF

          clear_buffer
          vim.feedkeys 'i<+foo!jump!bar\<esc>'
          assert_buffer_contents <<-EOF
              <+
              foo
              +>bar
          EOF
      end

      specify "Surround with brackets", :surround => true do
          vim.insert('foo bar foo<esc>')
          assert_buffer_contents <<-EOF
            foo bar foo
          EOF
          vim.normal('^')
          vim.feedkeys('viw(')
          assert_buffer_contents <<-EOF
            (foo) bar foo
          EOF
          vim.normal('^')
          vim.feedkeys('\<m-b>xw(')
          assert_buffer_contents <<-EOF
            foo (bar) foo
          EOF
          vim.feedkeys('V(')
          assert_buffer_contents <<-EOF
            (foo (bar) foo)
          EOF
          # vim.echo('input("pause")')
      end
  end

  # ======================================================================

  describe "Test bracket-pair insertions (and redo) without placeholder", :brackets, :nomarks => true do
      before :all do
          vim.command('SetMarker « »')
          vim.command('let b:usemarks = 0')
      end

      after :all do
          vim.command('unlet b:usemarks')
      end

      before :each do
          clear_buffer
      end

      specify "Inserts foo(bar", :redo, :paren => true do
          has_redo = vim.echo('has("patch-7.4.849")')
          vim.feedkeys('i(\<esc>')
          assert_line_contents <<-EOF
            ()
          EOF
          vim.feedkeys 'ofoo(bar\<esc>'
          assert_line_contents <<-EOF
            foo(bar)
          EOF
          if has_redo == "1"
              vim.type(".")
              expect(vim.echo('getline(".")')).to eq "foo(bar)"
          end
      end
      specify "Inserts foo(bar)foo", :redo, :paren => true do
          has_redo = vim.echo('has("patch-7.4.849")')
          vim.feedkeys('ofoo(bar)foo\<esc>')
          assert_line_contents <<-EOF
            foo(bar)foo
          EOF
          if has_redo == "1"
              vim.type(".")
              assert_line_contents <<-EOF
                foo(bar)foo
              EOF
          end
      end

      specify "Inserts foo\"bar", :redo, :quote => true do
          has_redo = vim.echo('has("patch-7.4.849")')
          vim.feedkeys('i"\<esc>')
          assert_line_contents <<-EOF
            ""
          EOF
          vim.feedkeys 'ofoo"bar\<esc>'
          assert_line_contents <<-EOF
            foo"bar"
          EOF
          if has_redo == "1"
              vim.type(".")
              expect(vim.echo('getline(".")')).to eq "foo\"bar\""
          end
      end
      specify "Inserts foo\"bar\"foo", :redo, :quote => true do
          has_redo = vim.echo('has("patch-7.4.849")')
          vim.feedkeys('ofoo"bar"foo\<esc>')
          assert_line_contents <<-EOF
            foo"bar"foo
          EOF
          if has_redo == "1"
              vim.type(".")
              assert_line_contents <<-EOF
                foo"bar"foo
              EOF
          end
      end

      specify "Inserts Brackets with newline", :newline => true do
          # <++> has a special meaning for :Brackets command, using <##>
          # instead of <++>
          vim.command('Brackets <# #> -nl')

          vim.feedkeys 'i<#\<esc>'
          assert_buffer_contents <<-EOF
              <#

              #>
          EOF

          clear_buffer
          vim.feedkeys 'i<#foo\<esc>'
          assert_buffer_contents <<-EOF
              <#
              foo
              #>
          EOF

          # Jumping after a closing sequence of characters without a
          # placeholder is close to impossible.
          # clear_buffer
          # vim.feedkeys 'i<#foo!jump!bar\<esc>'
          # assert_buffer_contents <<-EOF
              # <#
              # foo
              # #>bar
          # EOF
      end

      specify "Surround with brackets", :surround => true do
          vim.insert('foo bar foo<esc>')
          assert_buffer_contents <<-EOF
            foo bar foo
          EOF
          vim.normal('^')
          vim.feedkeys('viw(')
          assert_buffer_contents <<-EOF
            (foo) bar foo
          EOF
          vim.normal('^')
          vim.feedkeys('\<m-b>xw(')
          assert_buffer_contents <<-EOF
            foo (bar) foo
          EOF
          vim.feedkeys('V(')
          assert_buffer_contents <<-EOF
            (foo (bar) foo)
          EOF
          # vim.echo('input("pause")')
      end
  end
  # ======================================================================
  describe "Test context-sensitive expansion", :context => true do
    let (:filename) { "test.cpp" }
    before :each do
      vim.command('let g:load_doxygen_syntax = 1')
      vim.set('ft=cpp')
      vim.runtime('after/ftplugin/c/c_brackets.vim') # default bracket mappings
      vim.set('expandtab')
      vim.set('sw=2')
      vim.command('SetMarker <+ +>')
      clear_buffer
      vim.command('call lh#style#clear()')
      expect(vim.echo('lh#style#use({"indent_brace_style": "K&R"}, {"buffer": 1})')).to eq "1"
      expect(vim.echo('lh#style#use({"spacesbeforeparens": "control-statements"}, {"buffer": 1})')).to eq "1"
      vim.runtime('spec/support/c-snippets.vim') # Inoreab if
    end

    specify "Expands from normal context" do
      set_buffer_contents <<-EOF
      void f() {
      }
      EOF
      vim.normal("ggj")
      expect(vim.echo('lh#syntax#name_at(line("."), col("$")-2,1)')).not_to match(/Comment|doxygen/)
      vim.feedkeys('Oif foo\<esc>')
      assert_buffer_contents <<-EOF
      void f() {
        if (foo) {
          <++>
        }<++>
      }
      EOF
    end

    specify "Doesn't expand from C++ // context" do
      set_buffer_contents <<-EOF
      void f() {
        //
      }
      EOF
      vim.normal("ggj")
      expect(vim.echo('lh#syntax#name_at(line("."), col("$")-2,1)')).to match(/Comment/)
      vim.feedkeys('Aif foo\<esc>')
      assert_buffer_contents <<-EOF
      void f() {
        //if foo
      }
      EOF
    end
    specify "Doesn't expand from C /* context" do
      set_buffer_contents <<-EOF
      void f() {
        /*
      }
      EOF
      vim.normal("ggj")
      expect(vim.echo('lh#syntax#name_at(line("."), col("$")-2,1)')).to match(/Comment/)
      vim.feedkeys('Aif foo\<esc>')
      assert_buffer_contents <<-EOF
      void f() {
        /*if foo
      }
      EOF
    end
    specify "Doesn't expand from C /** context" do
      set_buffer_contents <<-EOF
      void f() {
        /**
      }
      EOF
      vim.normal("ggj")
      expect(vim.echo('lh#syntax#name_at(line("."), col("$")-2,1)')).to match(/doxygen/)
      vim.feedkeys('Aif foo\<esc>')
      assert_buffer_contents <<-EOF
      void f() {
        /**if foo
      }
      EOF
    end
    specify "Expands after C /**/ context (known bug)" do
      skip "Known bug..."
      set_buffer_contents <<-EOF
      void f() {
        /**/
      }
      EOF
      vim.normal("ggj")
      # expect(vim.echo('lh#syntax#name_at(line("."), col("$")-1,1)')).not_to match(/Comment/)
      # Expected bug. See autoload/lh/syntax.vim comments
      vim.feedkeys('Aif foo\<esc>')
      assert_buffer_contents <<-EOF
      void f() {
        /**/if (foo) {
          <++>
        }<++>
      }
      EOF
    end
    specify "Expands after C /**/ context (workaround)" do
      set_buffer_contents <<-EOF
      void f() {
        /**/
      }
      EOF
      vim.normal("ggj")
      # expect(vim.echo('lh#syntax#name_at(line("."), col("$")-1,1)')).not_to match(/Comment/)
      # Expected bug. See autoload/lh/syntax.vim comments
      vim.feedkeys('A if foo\<esc>')
      assert_buffer_contents <<-EOF
      void f() {
        /**/ if (foo) {
          <++>
        }<++>
      }
      EOF
    end
  end
end

# vim:set sw=2:
