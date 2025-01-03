// swift-tools-version:6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "crypto_sdk",
    platforms: [.iOS(.v15)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "crypto_sdk",
            targets: ["crypto_sdk"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .binaryTarget(name: "openssl", path: "OpenSSL/openssl.xcframework"),
        .target(
            name: "sdk-crypto-objc",
            dependencies: ["openssl"],
            path: "crypto-sdk/crypto",
            publicHeadersPath: "include",
            cSettings: [
                .headerSearchPath("include")
            ]),
        .target(
            name: "crypto_sdk",
            dependencies: ["sdk-crypto-objc"],
            path: "crypto-sdk/swift-wrapper"),
        .testTarget(
            name: "sdk-crypto-tests",
            dependencies: [
                .target(name: "crypto_sdk"),
            ],
            path: "crypto-tests",
            exclude: ["Info.plist"],
            resources: [.copy("data"), .copy("files"), .copy("sdks")])
    ],
    swiftLanguageModes: [.v6]
)
