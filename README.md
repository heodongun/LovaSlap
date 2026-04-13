# LovaSlap

LovaSlap은 macOS용 AppKit 기반 도트 감성 미니 미연시 **MiyeonSlap** 저장소입니다.

이 앱은 이제 **클릭으로 반응하지 않고**, **실제로 맥북 본체를 쳤을 때만** 반응하도록 맞춰져 있습니다.

## 특징

- AppKit 기반 macOS 앱
- 귀엽고 따뜻한 톤의 도트 스타일 화면
- 한 장면 중심의 미니 미연시 구성
- Apple Silicon 맥북에서 실제 본체 충격을 감지해 반응

## 요구 사항

- macOS 13 이상
- Apple Silicon MacBook

실제 맥북을 쳤을 때 반응하는 기능은 Apple Silicon 하드웨어 경로에 의존합니다.

## 다운로드

최신 릴리즈는 여기에서 받을 수 있습니다.

- https://github.com/heodongun/LovaSlap/releases

배포 파일 이름은 `MiyeonSlap.zip` 입니다.

## Homebrew로 설치

아래처럼 탭을 추가한 뒤 설치하면 됩니다.

```bash
brew tap heodongun/LovaSlap https://github.com/heodongun/LovaSlap
brew install --cask heodongun/LovaSlap/lovaslap
```

## 직접 실행

릴리즈 ZIP을 직접 받았다면:

```bash
unzip MiyeonSlap.zip
```

이 앱은 현재 **정식 Developer ID 서명 / notarization 이 적용되지 않은 배포본**입니다. 그래서 브라우저로 받은 ZIP을 바로 풀고 `open MiyeonSlap.app` 만 실행하면 macOS가 차단할 수 있습니다.

직접 다운로드한 경우에는 아래 순서로 실행하는 것을 기준 경로로 생각하면 됩니다.

```bash
unzip MiyeonSlap.zip
xattr -dr com.apple.quarantine MiyeonSlap.app
open MiyeonSlap.app
```

## 우회 / 주의 사항

이 앱의 실제 맥북 충격 반응은 Apple Silicon의 `AppleSPUHIDDevice` 센서 경로를 사용합니다. 이 방식은 **공식적으로 안정성이 보장된 공개 macOS API가 아닙니다.**

즉, 아래 사항을 알고 있어야 합니다.

- 실제 본체를 쳤을 때 반응하는 기능은 Apple Silicon 맥북에서만 기대할 수 있습니다.
- macOS 업데이트에 따라 동작이 바뀌거나 깨질 수 있습니다.
- 다운로드한 앱은 Gatekeeper 또는 quarantine 속성 때문에 바로 실행되지 않을 수 있습니다.
- 즉, **직접 다운로드 경로에서는 quarantine 제거가 사실상 필요할 수 있습니다.**

앱 실행이 막히면 아래처럼 quarantine 속성을 제거한 뒤 다시 실행하면 됩니다.

```bash
xattr -dr com.apple.quarantine MiyeonSlap.app
open MiyeonSlap.app
```

또한 기기별로 충격 감도 차이가 있을 수 있습니다. 센서 동작 특성상 어떤 맥북에서는 더 세게 쳐야 반응할 수도 있습니다.

## 소스에서 빌드

```bash
swift build
swift run
```

## 앱 아이콘 생성

```bash
swift scripts/generate_app_icon.swift
```

## Finder에서 바로 열 수 있는 앱 번들 생성

```bash
zsh scripts/build_app_bundle.sh
```

## 릴리즈용 ZIP 만들기

```bash
zsh scripts/package_release_zip.sh
```

생성 결과:

- `MiyeonSlap.app`
- `dist/MiyeonSlap.zip`

## 저장소 구조

- `Sources/MiyeonSlap/` — AppKit 앱 소스
- `Assets/AppIcon/` — 생성된 앱 아이콘 리소스
- `Casks/lovaslap.rb` — Homebrew cask 파일
- `scripts/` — 아이콘 생성, 앱 번들 생성, 릴리즈 패키징 스크립트
