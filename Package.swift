// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MrDefault",
    platforms: [
        .macOS(.v13)
    ],
    targets: [
        .executableTarget(
            name: "MrDefault",
            path: "MrDefault",
            exclude: ["Info.plist"],
            resources: [
                .process("Assets.xcassets")
            ]
        )
    ]
)
