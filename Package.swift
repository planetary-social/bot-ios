// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Bot",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Bot",
            targets: ["Bot"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(name: "Moderator",
                 url: "https://github.com/planetary-social/moderator-ios",
                 from: "0.0.3"),
        .package(name: "Logger",
                 url: "https://github.com/planetary-social/logger-ios",
                 from: "0.0.3"),
        .package(url: "https://github.com/stephencelis/SQLite.swift.git",
                 from: "0.13.1"),
        .package(name: "Monitor",
                 url: "https://github.com/planetary-social/monitor-ios",
                 from: "0.0.1"),
        .package(name: "Analytics",
                 url: "https://github.com/planetary-social/analytics-ios",
                 from: "0.0.3"),
        .package(name: "SSB",
                 url: "https://github.com/planetary-social/ssb-ios",
                 from: "0.0.4"),
        .package(name: "Blocked",
                 url: "https://github.com/planetary-social/blocked-ios",
                 from: "0.0.1"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Bot",
            dependencies: ["Moderator",
                           "SSB",
                           "Logger",
                           "Analytics",
                           "Monitor",
                           "Blocked",
                            .product(name: "SQLite", package: "SQLite.swift")],
            resources: [.copy("Resources/ViewDatabaseSchema.sql")]),
        .testTarget(
            name: "BotTests",
            dependencies: ["Bot"]),
    ]
)
