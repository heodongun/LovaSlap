cask "lovaslap" do
  version "0.1.1"
  sha256 "a8f896b58237bfe0304b11d110d2c85087e0501c0a8153e8123d2fb9d145d94c"

  url "https://github.com/heodongun/LovaSlap/releases/download/v#{version}/MiyeonSlap.zip"
  name "MiyeonSlap"
  desc "Cute AppKit pixel slap-reactive mini visual novel"
  homepage "https://github.com/heodongun/LovaSlap"

  app "MiyeonSlap.app"
end
