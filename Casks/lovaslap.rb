cask "lovaslap" do
  version "0.1.0"
  sha256 "633accf5e98bad8823a9aaa34dd70199494c636d5688c1cabf1db5e0e836565e"

  url "https://github.com/heodongun/LovaSlap/releases/download/v#{version}/MiyeonSlap.zip"
  name "MiyeonSlap"
  desc "Cute AppKit pixel slap-reactive mini visual novel"
  homepage "https://github.com/heodongun/LovaSlap"

  app "MiyeonSlap.app"
end
