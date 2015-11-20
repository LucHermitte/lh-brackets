require 'tmpdir'
require 'vimrunner'
require 'vimrunner/rspec'
require 'support/vim'
require 'rspec/expectations'
# require 'simplecov'

# SimpleCov.start

Vimrunner::RSpec.configure do |config|
  config.reuse_server = true

  vim_plugin_path = File.expand_path('.')
  vim_flavor_path   = ENV['HOME']+'/.vim/flavors'

  config.start_vim do
    vim = Vimrunner.start_gvim
    # vim = Vimrunner.start_vim
    vim.add_plugin(vim_flavor_path, 'bootstrap.vim')
    vim.prepend_runtimepath(vim_plugin_path)

    vim_UT_path      = File.expand_path('../../../vim-UT', __FILE__)
    vim.add_plugin(vim_UT_path, 'plugin/UT.vim')

    # pp vim_flavor_path
    # LetIfUndef
    vim_lib_path      = File.expand_path('../lh-vim-lib', __FILE__)
    vim.add_plugin(vim_lib_path, 'plugin/let.vim')
    # :Brackets
    vim.add_plugin(vim_plugin_path, 'plugin/common_brackets.vim')
    # !mark!
    vim.add_plugin(vim_plugin_path, 'plugin/bracketing.base.vim')
    pp vim.echo('&rtp')

    has_redo = vim.echo('has("patch-7.4.849")')
    if has_redo != "1"
      puts "WARNING: this flavor of vim won't permit lh-brackets to support redo"
    end
    vim
  end
end

RSpec.configure do |config|
  config.include Support::Vim

  def write_file(filename, contents)
    dirname = File.dirname(filename)
    FileUtils.mkdir_p dirname if not File.directory?(dirname)

    File.open(filename, 'w') { |f| f.write(contents) }
  end

  # Execute each example in its own temporary directory that is automatically
  # destroyed after every run.
  config.around do |example|
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        example.call
      end
    end
  end
end

# vim:set sw=2:
