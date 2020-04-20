// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "shell-kit",
    products: [
        .library(name: "ShellKit", targets: ["ShellKit"]),
        .library(name: "ShellKitDynamic", type: .dynamic, targets: ["ShellKit"])
    ],
    targets: [
        .target(name: "ShellKit", dependencies: []),
        .testTarget(name: "ShellKitTests", dependencies: ["ShellKit"]),
    ]
)
