// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SimpleEntertainmentList",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "SimpleEntertainmentList",
            path: "Sources/SimpleEntertainmentList"
        )
    ]
)
