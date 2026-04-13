# LovaSlap

LovaSlap packages **MiyeonSlap**, a cute AppKit-based pixel-art slap-reactive mini visual novel for macOS.

It supports two reaction paths:

- **in-window slap** by clicking Miyeon
- **real MacBook motion slap detection** through Apple Silicon `AppleSPUHIDDevice` sensor access

The app is intentionally small: one scene, one heroine, one dialogue panel, and one shared slap reaction pipeline.

## Requirements

- macOS 13+
- Apple Silicon MacBook for the real-device slap path

## Download

Download the latest release from:

- https://github.com/heodongun/LovaSlap/releases

The release artifact is `MiyeonSlap.zip`.

## Homebrew install

You can install the app directly from this repository's cask file:

```bash
brew install --cask https://raw.githubusercontent.com/heodongun/LovaSlap/main/Casks/lovaslap.rb
```

## Run manually

If you download the ZIP yourself:

```bash
unzip MiyeonSlap.zip
open MiyeonSlap.app
```

## Private API / workaround notes

The real MacBook slap path uses Apple Silicon `AppleSPUHIDDevice` sensor access through IOKit HID. This is **not a public stable macOS API**.

What that means in practice:

- the click-to-slap path works as the normal baseline interaction
- the real-device slap path is Apple Silicon specific
- future macOS updates may break the hardware path
- unsigned local builds or downloaded releases may need Gatekeeper quarantine removal before launch

If macOS blocks launch after download, run:

```bash
xattr -dr com.apple.quarantine MiyeonSlap.app
open MiyeonSlap.app
```

If the hardware slap path does not react strongly enough on your machine, the app itself still opens and works with click slaps. The hardware path depends on private sensor behavior and may require threshold tuning per machine or OS version.

## Build from source

```bash
swift build
swift run
```

To generate the app icon assets:

```bash
swift scripts/generate_app_icon.swift
```

To build a Finder-openable app bundle:

```bash
zsh scripts/build_app_bundle.sh
```

## Release packaging

To build the app bundle and zip it for release:

```bash
zsh scripts/package_release_zip.sh
```

This creates:

- `MiyeonSlap.app`
- `dist/MiyeonSlap.zip`

## Repository layout

- `Sources/MiyeonSlap/` — AppKit app source
- `Assets/AppIcon/` — generated app icon assets
- `Casks/lovaslap.rb` — Homebrew cask for release installs
- `scripts/` — icon generation, bundle building, and release packaging
