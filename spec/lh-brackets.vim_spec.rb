# encoding: UTF-8
require 'spec_helper'
require 'pp'

RSpec.describe "autoload/lh/map.vim" do
  # after(:all) do
    # vim.kill
  # end

  describe "Dependent plugins are available" do
      it "Has lh-vim-lib" do
          expect(vim.echo('&rtp')).to match(/lh-vim-lib/)
          expect(vim.echo('lh#option#is_unset(lh#option#unset())')).to eq "1"
          expect(vim.command("scriptnames")).to match(/autoload.lh.option\.vim/)
      end
      it "Has lh-dev" do
          expect(vim.echo('&rtp')).to match(/lh-dev/)
          expect(vim.echo('lh#dev#version()')).to be >= "135"
          expect(vim.command("scriptnames")).to match(/autoload.lh.dev\.vim/)
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
      it "Checks there is an imapping to (" do
          expect(vim.command("imap (")).to match(/lh#brackets#opener/)
      end
  end

  describe "Test bracket-pair insertions (and redo)" do
      it "Inserts foo(bar" do
          has_redo = vim.echo('has("patch-7.4.849")')
          vim.feedkeys('i(\<esc>')
          assert_line_contents <<-EOF
            ()«»
          EOF
          vim.feedkeys 'ofoo(bar\<esc>'
          assert_line_contents <<-EOF
            foo(bar)«»
          EOF
          if has_redo == "1"
              vim.type(".")
              expect(vim.echo('getline(".")')).to eq "foo(bar)«»"
          end
      end
      it "Inserts foo(bar)foo" do
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

      it "Inserts Brackets with newline" do
          vim.command('Brackets <+ +> -nl')

          vim.normal('ggdG')
          vim.feedkeys 'i<+\<esc>'
          assert_buffer_contents <<-EOF
              <+

              +>«»
          EOF

          vim.normal('ggdG')
          vim.feedkeys 'i<+foo\<esc>'
          assert_buffer_contents <<-EOF
              <+
              foo
              +>«»
          EOF

          vim.normal('ggdG')
          vim.feedkeys 'i<+foo!jump!bar\<esc>'
          assert_buffer_contents <<-EOF
              <+
              foo
              +>bar
          EOF
      end

      it "Surround with backets" do
          vim.normal('ggdG')
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
end

# vim:set sw=2:
