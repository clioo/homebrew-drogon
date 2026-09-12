# frozen_string_literal: true

require "minitest/autorun"
require "open3"
require "tmpdir"

SCRIPT = File.expand_path("update-cask.rb", __dir__)

class UpdateCaskTest < Minitest::Test
  CASK = <<~RUBY
    cask "drogon" do
      version "0.1.0-rc.1"
      sha256 "#{"a" * 64}"

      caveats <<~EOS
        old caveat
      EOS
    end
  RUBY

  def with_cask
    Dir.mktmpdir do |dir|
      path = File.join(dir, "drogon.rb")
      File.write(path, CASK)
      yield path
    end
  end

  def update(path, *args)
    Open3.capture3({ "DROGON_CASK_PATH" => path }, RbConfig.ruby, SCRIPT, *args)
  end

  def test_notarized_releases_remove_the_ad_hoc_caveat
    with_cask do |path|
      stdout, stderr, status = update(path, "0.1.0-rc.2", "b" * 64, "developer-id-notarized")
      assert status.success?, "#{stdout}\n#{stderr}"
      text = File.read(path)
      assert_includes text, 'version "0.1.0-rc.2"'
      assert_includes text, %(sha256 "#{"b" * 64}")
      refute_includes text, "caveats"
    end
  end

  def test_ad_hoc_releases_restore_the_caveat
    with_cask do |path|
      update(path, "0.1.0-rc.2", "c" * 64, "developer-id-notarized")
      stdout, stderr, status = update(path, "0.1.0-rc.3", "d" * 64, "local-ad-hoc-not-notarized")
      assert status.success?, "#{stdout}\n#{stderr}"
      text = File.read(path)
      assert_equal 1, text.scan("caveats").length
      assert_includes text, "--no-quarantine"
    end
  end

  def test_bad_digest_is_rejected_without_writing
    with_cask do |path|
      before = File.read(path)
      _stdout, _stderr, status = update(path, "0.1.0-rc.2", "not-a-digest", "local-ad-hoc-not-notarized")
      refute status.success?
      assert_equal before, File.read(path)
    end
  end
end
