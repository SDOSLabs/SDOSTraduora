// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AppDependencies",
    platforms: [.iOS(.v15)],
    products: [
        .plugin(
            name: "Generate Traduora Strings",
            targets: ["Generate Traduora Strings"]),
    ],
    dependencies: [
        .package(url: "https://github.com/SDOSLabs/SDOSTraduora.git", revision: "29082aced1dbeedeb4fef89f8637c7c3840ad8bf"),
    ],
    targets: [
        .plugin(
            name: "Generate Traduora Strings",
            capability:
                    .command(
                        intent: .custom(
                            verb: "generate-localizable-strings",
                            description: "SDOSTraduora es un script que genera los ficheros `.strings` a partir de un proyecto creado en un portal derivado de https://github.com/ever-co/ever-traduora. Esta plataforma permite definir los strings de un proyecto en varios idiomas y permite su acceso a través de API, por lo que puede ser usada para aplicaciones iOS y Android."
                        ),
                        permissions: [
                            .writeToPackageDirectory(reason: "Generación de los ficheros .strings"),
                            .allowNetworkConnections(scope: .all(ports: [80, 443]), reason: "Descargar los strings de traduora de su API")
                        ]
                    ),
            dependencies: [
                .product(name: "SDOSTraduora", package: "SDOSTraduora")
            ],
            path: "Plugins/Traduora"
        )
    ]
)
