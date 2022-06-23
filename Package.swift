// swift-tools-version:5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SDOSTraduora",
    products: [
        .plugin(name: "Traduora", targets: ["Traduora"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.0.5")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .executableTarget(
            name: "SDOSTraduora",
            dependencies: ["DownloadTraduora"]),
        .target(
            name: "DownloadTraduora",
            dependencies: [.product(name: "ArgumentParser", package: "swift-argument-parser")]),
        .testTarget(
            name: "SDOSTraduoraTests",
            dependencies: ["SDOSTraduora"]),
        .plugin(name: "Traduora",
                capability:
                .command(
                    intent: .custom(verb: "generate-localizable-strings",
                                    description: "SDOSTraduora es un script que genera los ficheros `.strings` a partir de un proyecto creado en un portal derivado de https://github.com/ever-co/ever-traduora. Esta plataforma permite definir los strings de un proyecto en varios idiomas y permite su acceso a través de API, por lo que puede ser usada para aplicaicones iOS y Android."),
                    permissions: [.writeToPackageDirectory(reason: "Generación de strings")]),
                dependencies: ["SDOSTraduora"]
               )
//            .plugin(name: "Traduora", capability: .buildTool(), dependencies: ["SDOSTraduora"])
    ]
)
