require 'minitest/autorun'
require 'tmpdir'
require 'fileutils'
require_relative '../cli/bundler'

class BundlerTest < Minitest::Test
  def setup
    @dir = Dir.mktmpdir('picodx-bundle')
  end

  def teardown
    FileUtils.remove_entry(@dir)
  end

  def write(path, content)
    full = File.join(@dir, path)
    FileUtils.mkdir_p(File.dirname(full))
    File.write(full, content)
    full
  end

  def bundle(entry = 'main.rb', **opts)
    @bundler = PicoDX::Bundler.new(**opts)
    code = @bundler.bundle(File.join(@dir, entry))
    assert_empty Prism.parse(code).errors, "bundle is not valid Ruby:\n#{code}"
    code
  end

  # Strips the generated comments so assertions can look at the code only.
  def code_lines(code)
    code.lines.map(&:strip).reject { |l| l.empty? || l.start_with?('#') }
  end

  def test_inlines_required_files_at_the_require_site
    write 'class/entity.rb', "class Entity; end\n"
    write 'class/enemy.rb', "require './class/entity.rb'\nclass Enemy < Entity; end\n"
    write 'main.rb', "require './class/enemy.rb'\nputs Enemy\n"

    assert_equal ['class Entity; end', 'class Enemy < Entity; end', 'puts Enemy'], code_lines(bundle)
    assert_equal %w[main.rb class/enemy.rb class/entity.rb],
                 @bundler.files.map { |f| f.delete_prefix("#{File.realpath(@dir)}/").delete_prefix("#{@dir}/") }
  end

  def test_keeps_code_between_requires_in_order
    write 'bgm.rb', "class Bgm; end\n"
    write 'goal.rb', "def goal; end\n"
    write 'main.rb', "require './bgm.rb'\nbgm = Bgm.new\nrequire './goal.rb'\n"

    assert_equal ['class Bgm; end', 'bgm = Bgm.new', 'def goal; end'], code_lines(bundle)
  end

  def test_each_file_is_inlined_only_once
    write 'entity.rb', "class Entity; end\n"
    write 'a.rb', "require './entity'\n"
    write 'b.rb', "require_relative 'entity'\n"
    write 'main.rb', "require './a'\nrequire './b'\nrequire './entity.rb'\n"

    assert_equal ['class Entity; end'], code_lines(bundle)
  end

  def test_require_relative_resolves_against_the_requiring_file
    write 'lib/sub/b.rb', "B = 1\n"
    write 'lib/a.rb', "require_relative 'sub/b'\n"
    write 'main.rb', "require_relative 'lib/a'\n"

    assert_equal ['B = 1'], code_lines(bundle)
  end

  def test_dot_slash_resolves_against_root_not_the_requiring_file
    write 'class/b.rb', "B = 1\n"
    write 'class/a.rb', "require './class/b.rb'\n"
    write 'main.rb', "require './class/a.rb'\n"

    assert_equal ['B = 1'], code_lines(bundle)
  end

  def test_bare_require_found_in_load_path_is_inlined
    write 'ranking.rb', "def ranking; end\n"
    write 'main.rb', "require 'ranking'\n"

    assert_equal ['def ranking; end'], code_lines(bundle)
  end

  def test_unknown_bare_require_is_kept_once_for_runtime
    write 'a.rb', "require 'js'\nA = 1\n"
    write 'main.rb', "require 'js'\nrequire './a'\n"

    assert_equal ["require 'js'", 'A = 1'], code_lines(bundle)
    assert_equal ['js'], @bundler.kept
  end

  def test_dxruby_is_ignored_by_default
    write 'main.rb', "require 'dxruby'\nWindow.loop {}\n"

    assert_equal ['Window.loop {}'], code_lines(bundle)
    assert_equal ['dxruby'], @bundler.ignored
  end

  def test_ignore_option
    write 'main.rb', "require 'set'\nrequire './ranking.rb'\nputs 1\n"

    assert_equal ['puts 1'], code_lines(bundle(ignore: %w[set ./ranking]))
    assert_equal %w[set ./ranking.rb], @bundler.ignored
  end

  def test_missing_local_file_is_an_error
    write 'main.rb', "\nrequire './ranking.rb'\n"

    error = assert_raises(PicoDX::Bundler::Error) { bundle }
    assert_match %r{main\.rb: cannot find "\./ranking\.rb"}, error.message
    assert_match(/--ignore/, error.message)
  end

  def test_accepts_parentheses_comments_and_no_space
    write 'a.rb', "A = 1\n"
    write 'b.rb', "B = 1\n"
    write 'c.rb', "C = 1\n"
    write 'main.rb', "require('./a') # first\nrequire\"./b.rb\"\nrequire_relative 'c'\n"

    assert_equal ['A = 1', 'B = 1', 'C = 1'], code_lines(bundle)
  end

  def test_backslash_paths
    write 'class/a.rb', "A = 1\n"
    write 'main.rb', "require '.\\class\\a.rb'\n"

    assert_equal ['A = 1'], code_lines(bundle)
  end

  def test_require_after_other_code_on_the_same_line_starts_a_new_line
    write 'a.rb', "A = 1\n"
    write 'main.rb', "x = 1; require './a'\n"

    code = bundle
    assert_equal ['x = 1;', 'A = 1'], code_lines(code)
  end

  def test_nested_require_is_left_alone_with_a_warning
    write 'main.rb', "def load_it\n  require './a'\nend\n"

    assert_equal ['def load_it', "require './a'", 'end'], code_lines(bundle)
    assert_equal 1, @bundler.warnings.size
    assert_match(/main\.rb:2: require is not at the top level/, @bundler.warnings.first.to_s)
  end

  def test_require_in_comments_and_strings_is_not_bundled
    write 'main.rb', <<~RUBY
      # require './a'
      =begin
      require './a'
      =end
      text = <<~TEXT
        require './a'
      TEXT
    RUBY

    code = bundle
    assert_includes code, "  require './a'\nTEXT"
    assert_equal 1, @bundler.files.size
  end

  def test_circular_require_is_skipped_with_a_warning
    write 'a.rb', "require './b'\nA = 1\n"
    write 'b.rb', "require './a'\nB = 1\n"
    write 'main.rb', "require './a'\n"

    assert_equal ['B = 1', 'A = 1'], code_lines(bundle)
    assert_match(/circular require of a\.rb/, @bundler.warnings.first.to_s)
  end

  def test_end_marker_and_data_are_dropped
    write 'a.rb', "A = 1\n__END__\nnot ruby at all\n"
    write 'main.rb', "require './a'\nputs A\n"

    assert_equal ['A = 1', 'puts A'], code_lines(bundle)
    assert_match(/__END__/, @bundler.warnings.first.to_s)
  end

  def test_syntax_error_reports_file_and_line
    write 'a.rb', "A = 1\ndef broken(\n"
    write 'main.rb', "require './a'\n"

    error = assert_raises(PicoDX::Bundler::Error) { bundle }
    assert_match(/\Aa\.rb:\d+: syntax error/, error.message)
  end

  def test_root_option
    write 'game/class/a.rb', "A = 1\n"
    write 'game/src/main.rb', "require './class/a.rb'\n"

    assert_equal ['A = 1'], code_lines(bundle('game/src/main.rb', root: File.join(@dir, 'game')))
  end

  def test_utf8_and_bom
    write 'a.rb', "﻿puts \"ヘルシーアドベンチャー\"\n"
    write 'main.rb', "require './a'\n"

    assert_equal ['puts "ヘルシーアドベンチャー"'], code_lines(bundle)
  end
end
