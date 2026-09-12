#!/usr/bin/env ruby
# frozen_string_literal: true

SEMVER = /\A\d+\.\d+\.\d+(?:-[0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*)?(?:\+[0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*)?\z/
SHA256 = /\A[0-9a-f]{64}\z/
CAVEAT = /\n  caveats <<~EOS\n.*?\n  EOS\n/m

AD_HOC_CAVEAT = "\n  caveats <<~EOS\n    This cask release is ad-hoc signed and not notarized. Install with --no-quarantine:\n\n      brew install --cask --no-quarantine clioo/drogon/drogon\n\n    Apple Silicon is supported; an Intel build is not currently published.\n  EOS\n"

version, sha256, signed = ARGV
abort "usage: update-cask.rb VERSION SHA256 SIGNED" unless version && sha256
abort "invalid semantic version: #{version}" unless SEMVER.match?(version)
abort "invalid SHA-256: #{sha256}" unless SHA256.match?(sha256)
abort "invalid signing status: #{signed}" unless [nil, "local-ad-hoc-not-notarized", "developer-id-notarized", "false"].include?(signed)

path = ENV["DROGON_CASK_PATH"] || File.expand_path("../Casks/drogon.rb", __dir__)
text = File.read(path)
text = text.sub(/^  version "[^"]+"$/, %(  version "#{version}"))
text = text.sub(/^  sha256 "[^"]+"$/, %(  sha256 "#{sha256}"))
abort "cask version stanza not found" unless text.include?(%(  version "#{version}"))
abort "cask sha256 stanza not found" unless text.include?(%(  sha256 "#{sha256}"))

case signed
when "developer-id-notarized"
  text = text.sub(CAVEAT, "")
when "local-ad-hoc-not-notarized", "false"
  if text.match?(CAVEAT)
    text = text.sub(CAVEAT, AD_HOC_CAVEAT)
  else
    text = text.sub(/\nend\n?\z/, "\n#{AD_HOC_CAVEAT}end\n")
  end
end

File.write(path, text)
puts "updated #{path}: #{version} #{sha256} #{signed || "signing status unchanged"}"
