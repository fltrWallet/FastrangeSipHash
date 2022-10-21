// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "FastrangeSipHash",
    products: [
        .library(
            name: "FastrangeSipHash",
            targets: ["FastrangeSipHash"]),
    ],
    dependencies: [
        
    ],
    targets: [
        .target(
            name: "FastrangeSipHash",
            dependencies: [ "Cfastrange",
                            "CSipHash" ]),
        .target(
            name: "Cfastrange",
            dependencies: [],
            sources: [ "fastrange.c" ],
            publicHeadersPath: ".",
            cSettings: [ .headerSearchPath("."), ]),
        .target(
            name: "CSipHash",
            dependencies: [],
            exclude: [ "README.md",
                       "LICENSE",
                       "makefile",
                       "halfsiphash.c",
                       "test.c",
                       "testmain.c"],
            sources: [ "siphash.c", ],
            publicHeadersPath: ".",
            cSettings: [ .headerSearchPath("."), ]),
        .testTarget(
            name: "FastrangeSipHashTests",
            dependencies: ["FastrangeSipHash"]),
    ]
)
