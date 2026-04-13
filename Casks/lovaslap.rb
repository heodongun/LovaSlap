cask "lovaslap" do
  version "0.1.2"
  sha256 "695abbcfa9791afc463573373718d764065e9f37e195661d493a5f340c11bf7f"

  url "https://github.com/heodongun/LovaSlap/releases/download/v#{version}/MiyeonSlap.zip"
  name "MiyeonSlap"
  desc "Cute AppKit pixel slap-reactive mini visual novel"
  homepage "https://github.com/heodongun/LovaSlap"

  app "MiyeonSlap.app"
end
