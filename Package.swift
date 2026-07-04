// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MapCache",
    platforms: [
        .iOS(.v11), .macOS(.v10_13)
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "MapCache",
            targets: ["MapCache"]),
        ],
    dependencies: [
        .package(url: "https://github.com/Quick/Quick.git", from: "3.1.2"),
        .package(url: "https://github.com/Quick/Nimble.git", from: "9.2.0"),
        .package(url: "https://github.com/AliSoftware/OHHTTPStubs.git", from: "9.1.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "MapCache",
            dependencies: [],
            path: "MapCache/Classes"),
        .testTarget(
            name: "MapCacheTests",
            dependencies: [
                "MapCache",
                .product(name: "Quick", package: "Quick"),
                .product(name: "Nimble", package: "Nimble"),
                .product(name: "OHHTTPStubs", package: "OHHTTPStubs"),
                .product(name: "OHHTTPStubsSwift", package: "OHHTTPStubs"),
            ],
            path: "Example/Tests"),
        ],
    swiftLanguageVersions: [ .v5 ]
)
