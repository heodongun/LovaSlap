// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MiyeonSlap",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "MiyeonSlap",
            targets: ["MiyeonSlap"]
        )
    ],
    targets: [
        .executableTarget(
            name: "MiyeonSlap"
        )
    ]
)
