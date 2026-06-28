// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "KhenshinSecureMessage",
    platforms: [.iOS(.v12), .macOS(.v10_15)],
    products: [
        .library(name: "KhenshinSecureMessage", targets: ["KhenshinSecureMessage"])
    ],
    dependencies: [
        .package(url: "https://github.com/khipu/tweetnacl-swiftwrap.git", from: "1.1.5"),
        .package(url: "https://github.com/Quick/Quick.git", "6.0.0"..<"7.0.0"),
        .package(url: "https://github.com/Quick/Nimble.git", "11.2.0"..<"13.0.0")
    ],
    targets: [
        .target(
            name: "KhenshinSecureMessage",
            dependencies: [.product(name: "TweetNacl", package: "tweetnacl-swiftwrap")],
            path: "KhenshinSecureMessage/Classes"
        ),
        .testTarget(
            name: "KhenshinSecureMessageTests",
            dependencies: ["KhenshinSecureMessage", "Quick", "Nimble"],
            path: "Example/Tests",
            exclude: ["Info.plist"]
        )
    ]
)
