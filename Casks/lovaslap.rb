cask "lovaslap" do
  version "0.1.2"
  sha256 "b9fc28a0b70cd24bc7f460aa9370920d16ddd0cf0e6482caa1c2f214fa40493d"

  url "https://github.com/heodongun/LovaSlap/releases/download/v#{version}/MiyeonSlap.zip"
  name "MiyeonSlap"
  desc "Cute AppKit pixel slap-reactive mini visual novel"
  homepage "https://github.com/heodongun/LovaSlap"

  app "MiyeonSlap.app"
end
