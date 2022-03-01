// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "KommunicateCoreiOSSDK",
    defaultLocalization: "en",
    platforms: [.iOS(.v12)],
    products: [
        .library(
            name: "KommunicateCoreiOSSDK",
            targets: ["KommunicateCoreiOSSDK"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "KommunicateCoreiOSSDK",
            dependencies: [],
            path: "Sources",
            exclude: ["Info.plist",
                      "MQTT/MQTTClient-Prefix.pch"],
            resources: [
                .process("Resources")
            ],
            cSettings: [
                .headerSearchPath(""),
                .headerSearchPath("account"),
                .headerSearchPath("applozickit"),
                .headerSearchPath("channel"),
                .headerSearchPath("commons"),
                .headerSearchPath("conversation"),
                .headerSearchPath("database"),
                .headerSearchPath("JWT"),
                .headerSearchPath("message"),
                .headerSearchPath("MQTT"),
                .headerSearchPath("networkcommunication"),
                .headerSearchPath("notification"),
                .headerSearchPath("prefrence"),
                .headerSearchPath("push"),
                .headerSearchPath("sync"),
                .headerSearchPath("user"),
                .headerSearchPath("utilities")
            ],
            linkerSettings: [
                .linkedFramework("Foundation"),
                .linkedFramework("SystemConfiguration"),
                .linkedFramework("UIKit", .when(platforms: [.iOS]))
            ]
        )
    ],
    swiftLanguageVersions: [.v5]
)
