cask "drogon" do
  arch arm: "arm64"

  version "0.1.0-rc.3"
  sha256 "e9032e75904b960c8db1e016acad21489b9e779d8c355ef9d995154d9ced9ce0"

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
end
