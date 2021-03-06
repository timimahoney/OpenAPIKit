// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "OpenAPIKit",
    platforms: [
        .macOS(.v10_10),
        .iOS(.v11)
    ],
    products: [
        .library(
            name: "OpenAPIKit30",
            targets: ["OpenAPIKit30"]),
        .library(
            name: "OpenAPIKit",
            targets: ["OpenAPIKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/jpsim/Yams.git", from: "4.0.0"), // just for tests
        .package(url: "https://github.com/omochi/FineJSON.git", from: "1.14.0") // just for tests
    ],
    targets: [
        .target(
            name: "OpenAPIKitCore",
            dependencies: []),
        .testTarget(
            name: "OpenAPIKitCoreTests",
            dependencies: ["OpenAPIKitCore"]),
        .testTarget(
            name: "EitherTests",
            dependencies: ["OpenAPIKitCore"]),
        .testTarget(
            name: "OrderedDictionaryTests",
            dependencies: ["OpenAPIKitCore", "Yams", "FineJSON"]),
        .testTarget(
            name: "AnyCodableTests",
            dependencies: ["OpenAPIKitCore"]),

        .target(
            name: "OpenAPIKit30",
            dependencies: ["OpenAPIKitCore"]),
        .testTarget(
            name: "OpenAPIKit30Tests",
            dependencies: ["OpenAPIKit30", "Yams", "FineJSON"]),
        .testTarget(
            name: "OpenAPIKit30CompatibilitySuite",
            dependencies: ["OpenAPIKit30", "Yams"]),
        .testTarget(
            name: "OpenAPIKit30ErrorReportingTests",
            dependencies: ["OpenAPIKit30", "Yams"]),

        .target(
            name: "OpenAPIKit",
            dependencies: ["OpenAPIKitCore"]),
        .testTarget(
            name: "OpenAPIKitTests",
            dependencies: ["OpenAPIKit", "Yams", "FineJSON"]),
        .testTarget(
            name: "OpenAPIKitCompatibilitySuite",
            dependencies: ["OpenAPIKit", "Yams"]),
        .testTarget(
            name: "OpenAPIKitErrorReportingTests",
            dependencies: ["OpenAPIKit", "Yams"])
    ],
    swiftLanguageVersions: [ .v5 ]
)
