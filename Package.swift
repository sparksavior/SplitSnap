// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SplitSnap",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "SplitSnap",
            targets: ["SplitSnap"]
        ),
    ],
    targets: [
        .target(
            name: "SplitSnap",
            dependencies: [],
            path: "Sources"
        ),
    ]
)
