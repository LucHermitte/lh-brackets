# encoding: UTF-8
require 'vimrunner'

# vim = Vimrunner.start
vim = Vimrunner.start_gvim
vim_brackets_path = File.expand_path('../..', __FILE__)
vim_lib_path      = File.expand_path('../../../lh-vim-lib', __FILE__)
vim_dev_path      = File.expand_path('../../../lh-dev', __FILE__)

vim.append_runtimepath(vim_lib_path)
vim.append_runtimepath(vim_dev_path)
vim.add_plugin(vim_lib_path, 'plugin/let.vim')
vim.add_plugin(vim_brackets_path, 'plugin/common_brackets.vim')
vim.add_plugin(vim_brackets_path, 'plugin/bracketing.base.vim')
vim.add_plugin(vim_brackets_path, 'autoload/lh/map.vim')

RSpec.describe "autoload/lh/map.vim" do
  after(:all) do
    vim.kill
  end

  describe "Dependent plugins are available" do
      it "Has lh-vim-lib" do
          expect(vim.echo('&rtp')).to match(/lh-vim-lib/)
      end
      it "Has lh-dev" do
          expect(vim.echo('&rtp')).to match(/lh-dev/)
      end
  end

  describe "lh#map#version" do
      it "returns the current script version" do
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
      it "inserts foo(bar" do
          vim.feedkeys('i(\<esc>')
          expect(vim.echo('getline(".")')).to eq "()«»"
          vim.feedkeys 'ofoo(bar\<esc>'
          expect(vim.echo('getline(".")')).to eq "foo(bar)«»"
          vim.type(".")
          expect(vim.echo('getline(".")')).to eq "foo(bar)«»"
      end
      it "inserts foo(bar)foo" do
          vim.feedkeys('ofoo(bar)foo\<esc>')
          expect(vim.echo('getline(".")')).to eq "foo(bar)foo"
          vim.type(".")
          expect(vim.echo('getline(".")')).to eq "foo(bar)foo"
          # vim.echo('input("pause")')
      end
  end
end
