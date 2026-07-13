// swift-tools-version:5.9
import PackageDescription

@main
struct SafePastePackage: Package {
    let name = "SafePaste"
    
    var platforms: [SupportedPlatform] {
        [.macOS(.v12)]
    }
    
    var products: [Product] {
        [
            .app(
                name: "SafePaste",
                targets: ["SafePaste"]
            )
        ]
    }
    
    var targets: [Target] {
        [
            .target(
                name: "SafePaste",
                dependencies: [],
                path: "Sources",
                resources: [
                    .process("Resources")
                ],
                swiftSettings: [
                    .unsafeFlags(["-parse-as-library"])
                ]
            )
        ]
    }
}
