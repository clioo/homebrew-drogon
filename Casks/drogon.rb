cask "drogon" do
  arch arm: "arm64"

  version "0.1.0-rc.1"
  sha256 "0e7e93d2a59544c06d921f02381a2d993e0d070685864f0b795a584c03ff0afa"

  url "https://github.com/clioo/drogon/releases/download/v#{version}/Drogon-#{version}-darwin-arm64.zip"
  name "Drogon"
  desc "Desktop workspace for developers with coding agents and Git worktrees"
  homepage "https://github.com/clioo/drogon"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on macos: :sonoma

  app "Drogon.app"
  binary "#{appdir}/Drogon.app/Contents/Resources/bin/drogon-cli"

  uninstall quit:   "ai.clioo.drogon",
            script: {
              executable: "#{appdir}/Drogon.app/Contents/Resources/bin/drogon-stop-daemon",
            }

  zap trash: [
    "~/Applications/.drogon-builds",
    "~/Library/Application Support/Drogon",
    "~/Library/Caches/Drogon",
    "~/Library/Logs/Drogon",
    "~/Library/Preferences/ai.clioo.drogon.plist",
    "~/Library/Saved Application State/ai.clioo.drogon.savedState",
  ]

  caveats <<~EOS
    This cask release is ad-hoc signed and not notarized. Install with --no-quarantine:

      brew install --cask --no-quarantine clioo/drogon/drogon

    Apple Silicon is supported; an Intel build is not currently published.
  EOS
end
