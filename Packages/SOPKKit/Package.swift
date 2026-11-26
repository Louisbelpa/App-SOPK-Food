// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "SOPKKit",
    defaultLocalization: "fr",
    platforms: [.iOS(.v18), .macOS(.v15)],
    products: [
        .library(name: "SOPKKit", targets: ["SOPKKit"])
    ],
    targets: [
        .target(
            name: "SOPKKit",
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "SOPKKitTests",
            dependencies: ["SOPKKit"]
        )
    ]
)
