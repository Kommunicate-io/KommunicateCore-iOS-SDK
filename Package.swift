// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "KommunicateCore-iOS-SDK",
    defaultLocalization: "en",
    platforms: [.iOS(.v12)],
    products: [
        .library(
            name: "KommunicateCore-iOS-SDK",
            targets: ["KommunicateCore-iOS-SDK"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "KommunicateCore-iOS-SDK",
            dependencies: [],
            path: "Sources/KommunicateCore-iOS-SDK/Classes",
            exclude: ["Info.plist",
                      "MQTT/MQTTClient-Prefix.pch"],
            resources: [
                .process("push/TSMessagesDefaultDesign.json"),
                .process("database/AppLozic.xcdatamodeld"),
                .process("MQTT/MQTTClient.xcdatamodeld"),

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
