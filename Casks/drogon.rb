cask "drogon" do
  arch arm: "arm64"

  version "0.1.0-rc.4"
  sha256 "19cac2617f13fb86513d82ce6ff888e13ef88a614b767be839b1189f1875a3ad"

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
end
