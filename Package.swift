// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "Coordinator",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "Coordinator",
            targets: ["Coordinator"]
        )
    ],
    targets: [
        .target(name: "Coordinator"),
        .testTarget(
            name: "CoordinatorTests",
            dependencies: ["Coordinator"]
        )
    ]
)
