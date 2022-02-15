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
            path: "Sources/KommunicateCore-iOS-SDK",
            exclude: ["Classes/Info.plist",
                      "Classes/MQTT/MQTTClient-Prefix.pch"],
            resources: [
                .copy("Classes/push/TSMessagesDefaultDesign.json"),
                    .copy("Classes/MQTT/MQTTClient-Prefix.pch")
            ],
            cSettings: [
                .headerSearchPath(""),
                .headerSearchPath("Assets"),
                .headerSearchPath("Classes"),
                .headerSearchPath("include"),
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
                .headerSearchPath("KommunicateCore-iOS-SDK"),
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
