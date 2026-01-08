// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BatteryToolkit",
    platforms: [
        .macOS(.v11)
    ],
    products: [
        .library(
            name: "BatteryToolkit",
            targets: ["BatteryToolkit"] 
        ),
        .executable(
            name: "batterytoolkitd",
            targets: ["BTDaemon"] 
        ),

        .executable(
            name: "BatteryToolkitService",
            targets: ["BTService"]
        )
    ],
    dependencies: [],
    targets: [
        // C/Objective-C Modules
        .target(
            name: "BTPreprocessor",
            path: "Sources/Modules/BTPreprocessor",
            publicHeadersPath: ".",
            cSettings: [
                .define("BT_APP_ID_", to: "\"me.mhaeuser.BatteryToolkit\""),
                .define("BT_SERVICE_ID_", to: "\"me.mhaeuser.BatteryToolkitService\""),
                .define("BT_DAEMON_ID_", to: "\"me.mhaeuser.batterytoolkitd\""),
                .define("BT_DAEMON_CONN_", to: "\"EMH49F8A2Y.me.mhaeuser.batterytoolkitd\""),
                .define("BT_AUTOSTART_ID_", to: "\"me.mhaeuser.BatteryToolkitAutostart\""),
                .define("BT_CODESIGN_CN_", to: "\"Apple Development: Marvin Häuser (87DYA6FH9K)\""),
            ]
        ),
        .systemLibrary(
            name: "IOPMPrivate",
            path: "Sources/Modules/IOPMPrivate"
        ),
        .target(
            name: "MachTaskSelf",
            path: "Sources/Modules/MachTaskSelf",
            publicHeadersPath: "."
        ),
        .target(
            name: "NSXPCConnectionAuditToken",
            dependencies: ["MachTaskSelf"],
            path: "Sources/Modules/NSXPCConnection+AuditToken",
            exclude: ["module.modulemap"],
            publicHeadersPath: "."
        ),
        .target(
            name: "SecCodeEx",
            path: "Sources/Modules/SecCodeEx",
            publicHeadersPath: "."
        ),
        .target(
            name: "SMCParamStruct",
            path: "Sources/Modules/SMCParamStruct",
            publicHeadersPath: "."
        ),
        
        // Swift Libraries
        .target(
            name: "CSIdentification",
            path: "Sources/CSIdentification"
        ),
        .target(
            name: "SMCComm",
            dependencies: ["SMCParamStruct", "MachTaskSelf"],
            path: "Sources/SMCComm"
        ),
        .target(
            name: "PowerEvents",
            dependencies: ["IOPMPrivate"],
            path: "Sources/PowerEvents"
        ),
        .target(
            name: "SimpleAuth",
            dependencies: ["BTPreprocessor"],
            path: "Sources/SimpleAuth"
        ),

        // Common Logic
        .target(
            name: "BTShared",
            dependencies: [
                "BTPreprocessor",
                "SMCComm",
                "NSXPCConnectionAuditToken",
                "SecCodeEx",
                "SMCParamStruct"
            ],
            path: "Sources/BTShared"
        ),

        // Daemon
        .executableTarget(
            name: "BTDaemon",
            dependencies: [
                "BTShared",
                "PowerEvents",
                "SMCComm",
                "NSXPCConnectionAuditToken",
                "SecCodeEx",
                "SimpleAuth",
                "CSIdentification"
            ],
            path: "Sources/BTDaemon",
            exclude: [
                "launchd.plist",
                "me.mhaeuser.batterytoolkitd.plist"
            ]
        ),
        
        // XPC Service
        .executableTarget(
            name: "BTService",
            dependencies: ["BTShared", "SimpleAuth"],
            path: "Sources/BTService"
        ),
        
        // Main App-facing Library
        .target(
            name: "BatteryToolkit",
            dependencies: [
                "BTShared",
                "SimpleAuth",
                "CSIdentification"
            ],
            path: "Sources/BatteryToolkit"
        )
    ]
)