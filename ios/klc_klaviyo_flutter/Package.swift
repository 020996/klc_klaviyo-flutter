// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "klc_klaviyo_flutter",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        .library(name: "klc-klaviyo-flutter", targets: ["klc_klaviyo_flutter"])
    ],
    dependencies: [
        .package(url: "https://github.com/klaviyo/klaviyo-swift-sdk", from: "5.1.1")
    ],
    targets: [
        .target(
            name: "klc_klaviyo_flutter",
            dependencies: [
                .product(name: "KlaviyoSwift", package: "klaviyo-swift-sdk"),
                .product(name: "KlaviyoForms", package: "klaviyo-swift-sdk")
            ],
            resources: [
                .process("PrivacyInfo.xcprivacy")
            ]
        )
    ]
)
