// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "swift-stubbable",
    platforms: [.macOS(.v15), .iOS(.v15), .tvOS(.v15), .watchOS(.v8), .macCatalyst(.v15)],
    products: [
        .library(
            name: "Stubbable",
            targets: ["Stubbable"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "601.0.0-latest"),
    ],
    targets: [
        .macro(
            name: "StubbableMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),
        .target(
            name: "Stubbable",
            dependencies: ["StubbableMacros"]
        ),
        .testTarget(
            name: "StubbableMacrosTests",
            dependencies: [
                "StubbableMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ]
        ),
    ]
)
