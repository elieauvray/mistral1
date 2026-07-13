// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "SafePaste",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(
            name: "SafePaste",
            targets: ["SafePaste"]
        )
    ],
    targets: [
        .executableTarget(
            name: "SafePaste",
            dependencies: [],
            path: "Sources"
        )
    ]
)
