cask "drogon" do
  arch arm: "arm64"

  version "0.1.0-rc.2"
  sha256 "81019f17414ba678a94ca37a957c2aebe227c5a52dc81c44920eac01aa3037cd"

  url "https://github.com/clioo/drogon/releases/download/v#{version}/Drogon-#{version}-darwin-arm64.zip"
  name "Drogon"
  desc "Desktop workspace for developers with coding agents and Git worktrees"
  homepage "https://github.com/clioo/drogon"

  livecheck do
    url :url
    # Every Drogon release is a prerelease, which both :github_latest and
    # the default :github_releases matching skip: match tags (including
    # prereleases, excluding drafts) with the rc-aware version pattern.
    regex(/v?(\d+(?:\.\d+)+(?:-rc\.\d+)?)/i)
    strategy :github_releases do |json, regex|
      json.reject { |release| release["draft"] }
          .map { |release| release["tag_name"]&.[](regex, 1) }
          .compact.uniq
    end
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
    This cask release is ad-hoc signed and not notarized.

    On Homebrew versions that support --no-quarantine, install with:

      brew install --cask --no-quarantine clioo/drogon/drogon

    Homebrew 6 removed --no-quarantine. On those versions, install normally,
    try to open Drogon.app, then choose Open Anyway in System Settings > Privacy & Security.

    Apple Silicon is supported; an Intel build is not currently published.
  EOS
end
