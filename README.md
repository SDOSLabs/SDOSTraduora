- [SDOSTraduora](#sdostraduora)
  - [Introducción](#introducción)
  - [Instalación](#instalación)
    - [Añadir al proyecto](#añadir-al-proyecto)
    - [Como dependencia en Package.swift](#como-dependencia-en-packageswift)
  - [Cómo se usa](#cómo-se-usa)
    - [Ejecutar el script por línea de comandos](#ejecutar-el-script-por-línea-de-comandos)
  - [Ejecutar el script a través de un plugins de Swift Package Manager](#ejecutar-el-script-a-través-de-un-plugins-de-swift-package-manager)
    - [Plugin.swift](#pluginswift)
    - [TraduoraData.swift](#traduoradataswift)
    - [Textos en traduora](#textos-en-traduora)
    - [Parámetros del script](#parámetros-del-script)

# SDOSTraduora
- Changelog: https://github.com/SDOSLabs/SDOSTraduora/blob/master/CHANGELOG.md

## Introducción
SDOSTraduora es un script que genera los ficheros `.strings` a partir de un proyecto creado en un portal derivado de https://github.com/ever-co/ever-traduora. Esta plataforma permite definir los strings de un proyecto en varios idiomas y permite su acceso a través de API, por lo que puede ser usada para aplicaciones iOS y Android.

## Instalación

### Añadir al proyecto

Abrir Xcode y e ir al apartado `File > Add Packages...`. En el cuadro de búsqueda introducir la url del respositorio y seleccionar la versión:
```
https://github.com/SDOSLabs/SDOSTraduora.git
```
Para ejecutar el script por línea de comandos no es necesario que la dependencia se debe añadir a ningún target

### Como dependencia en Package.swift

``` swift
dependencies: [
    .package(url: "https://github.com/SDOSLabs/SDOSTraduora.git", .upToNextMajor(from: "2.1.0"))
]
```

Para ejecutar el script por línea de comandos no es necesario que la dependencia se debe añadir a ningún target

## Cómo se usa

### Ejecutar el script por línea de comandos

Hay que lanzar un script durante antes de la compilación que generará los ficheros `.strings` configurados en el proyecto de traduora indicado. Estos ficheros deberán añadirse en el proyecto. Para la ejecución del script hay que seguir los siguientes pasos:

1. En Xcode: Pulsar sobre `File > New > Target...`, elegir la opción `Cross-platform`, seleccionar `Aggregate` e indicar el nombre `Traduora`
2. Seleccionar el proyecto, elegir el TARGET que acabamos de crear, seleccionar la pestaña de `Build Phases` y pulsar en añadir `New Run Script Phase` en el icono de **`+`** arriba a la izquierda
3. Renombrar el script a `Traduora`
4. Copiar el siguiente script:
    ```sh
    "${BUILD_DIR%/Build/*}/SourcePackages/checkouts/SDOSTraduora/src/Scripts/SDOSTraduora" --server "${TRADUORA_SERVER}" --client-id "${TRADUORA_CLIENT_ID}" --client-secret "${TRADUORA_SECRET}" --project-id "${TRADUORA_PROJECT_ID}" --output-path "${SRCROOT}/${TRADUORA_OUTPUT_FOLDER}" --output-file-name "Localizable.generated.strings"
    ```
    > Los valores del script `${TRADUORA_SERVER}`, `${TRADUORA_CLIENT_ID}`, `${TRADUORA_SECRET}`, `${TRADUORA_PROJECT_ID}` y `${TRADUORA_OUTPUT_FOLDER}` deben ser sustituidos por los valores correspondientes a cada proyecto (ver el apartado [Parámetros del script](#parámetros-del-script))
5. Compilar el target `Traduora` para genere los ficheros `Localizable.generated.strings`
6. Al compilar se generararán los ficheros en la ruta `${SRCROOT}/${TRADUORA_OUTPUT_FOLDER}` y deberán ser incluidos en el proyecto. **Hay que añadir los fichero `.strings`, no las carpetas**


## Ejecutar el script a través de un plugins de Swift Package Manager

Para ejecutar el script de traduora a través de un plugin de Swift Package Manager hay que crear un Package local que tendremos que añadir al proyecto.

```swift
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
        .package(url: "https://github.com/SDOSLabs/SDOSTraduora.git", .upToNextMajor(from: "2.1.0"))
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

```

Este Package incluye un plugin de tipo comando que nos permitirá ejecutar la descarga de literales desde Xcode

```swift
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
```

Este plugin contiene la implementación en la carpeta `Plugins/Traduora` con los siguientes ficheros:

### Plugin.swift
```swift
//
//  Plugin.swift
//
//  Copyright © 2023 ALTEN. All rights reserved.
//

import Foundation
import PackagePlugin

/// Este plugin sólo funciona al ejecutarse desde Xcode.
/// Para su ejecución es necesario hacer click derecho sobre el fichero del proyecto y pulsar la opción "Generate Traduora Strings".
/// Después se mostrará un menu donde tendremos que seleccionar en que target queremos ejecutarlo. La función `performCommand` se ejecutará
/// para cada target seleccionado. Para cada uno de los targets se usa una ruta única relativa al project donde se usa el nombre del propio target
/// y a partir de la cual se buscará el fichero de configuración `traduora.json`
///
/// Por ejemplo, para el target llamado `{{cookiecutter.app_name}}` la ruta base será `targets/{{cookiecutter.app_name}}/`.
/// En este caso el fichero de configuración deberá estar en la ruta `targets/{{cookiecutter.app_name}}/scripts/traduora.json`
/// El output de los strings que se generen también serán relativos a la ruta `targets/{{cookiecutter.app_name}}/`
/// Las claves aceptadas en el fichero de configuracón`traduora.json` son las definidas en el objeto `TraduoraData`
@main
struct GenerateTraduora: CommandPlugin {
    func performCommand(context: PackagePlugin.PluginContext, arguments: [String]) async throws {
        // Command not work in Packages
    }
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension GenerateTraduora: XcodeCommandPlugin {
    func performCommand(context: XcodePluginContext, arguments: [String]) throws {
        
        for target in context.xcodeProject.targets where arguments.contains([target.displayName]) {
            let configFilePath = context.xcodeProject.directory.string + "/targets/" + target.displayName + "/scripts/traduora.json"
            print("Search \"traduora.json\" for target \"\(target.displayName)\" in path \"\(configFilePath)\"")
            let url = URL(fileURLWithPath: configFilePath)
            let jsonData = try Data(contentsOf: url)
            let traduoraData = try JSONDecoder().decode(TraduoraData.self, from: jsonData)
            
            print("Success load \"traduora.json\" for target \"\(target.displayName)\" in path \"\(configFilePath)\"")
            print(String(data: jsonData, encoding: .utf8) ?? "")
            
            let errorPipe = Pipe()
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "\(try context.tool(named: "SDOSTraduora").path)")
            process.arguments = traduoraData.generateComandArguments(
                target: target,
                xcodeProjectDirectory: context.xcodeProject.directory.string)
            .reduce(into: [String]()) { result, element in
                result.append(element.key)
                result.append(element.value)
            }
            process.standardError = errorPipe
            try process.run()
            process.waitUntilExit()
            
            if process.terminationReason == .exit && process.terminationStatus == 0 {
                print("Traduora success for \(target.displayName)")
            } else {
                let problem = "\(String(data: errorPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? "")"
                Diagnostics.error("Traduora failed for \(target.displayName): \(problem)")
            }
        }
    }
}
#endif
```

### TraduoraData.swift

```swift
//
//  TraduoraData.swift
//  
//  Copyright © 2023 ALTEN. All rights reserved.
//

import Foundation
#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

/// Objeto que representa el json que puede recibir el plugin. Este json se llamará `traduora.json` y se debe colocar en la carpeta `scripts` del target en el que se quieran generar los localizables
/// Si suponemos que el target se llama `{{cookiecutter.app_name}}` el fichero estará en la ruta `targets/{{cookiecutter.app_name}}/scripts/traduora.json`
/// Un json completo sería similar al siguiente:
///
///     {
///         "clientId": "a565aa78-7756-47a7-a35d-3999bca92",
///         "clientSecret": "hRuejUMJ3R6DUJMPG6FIPBV53Dn40k",
///         "projectId": "01e23427-1a1f-36ad-bd87-4de9e68eff40",
///         "server": "traduora.es",
///         "outputPath": "code/localization/strings",
///         "outputFileName": "Localizable.generated.strings",
///         "lang": "es_ES",
///         "label": "news"
///     }
struct TraduoraData: Codable {
    let clientId: String?
    let clientSecret: String?
    let projectId: String?
    let server: String?
    let outputPath: String?
    let outputFileName: String?
    let lang: String?
    let label: String?
    
    func generateComandArguments(target: XcodeTarget, xcodeProjectDirectory directory: String) -> [String: String] {
        var arguments: [String: String] = [:]
        if let lang {
            arguments["--lang"] = lang
        }
        if let label {
            arguments["--label"] = label
        }
        if let clientId {
            arguments["--client-id"] = clientId
        }
        if let clientSecret {
            arguments["--client-secret"] = clientSecret
        }
        if let projectId {
            arguments["--project-id"] = projectId
        }
        if let server {
            arguments["--server"] = server
        }
        if let outputPath {
            arguments["--output-path"] = directory + "/targets/" + target.displayName + "/" + outputPath
        }
        if let outputFileName {
            arguments["--output-file-name"] = outputFileName
        }
        
        return arguments
    }
}
#endif
```

El funcionamiento del plugin requiere que el proyecto contenga un fichero `traduora.json` en la ruta `targets/<Nombre del target>/traduora.json`. Este json contendrá todos los valores necesarios para crear un objeto de tipo `TraduoraData`. Tendrá una estructura similar al siguiente

```json
{
    "clientId": "a565aa78-7756-47a7-a35d-3999bca92",
    "clientSecret": "hRuejUMJ3R6DUJMPG6FIPBV53Dn40k",
    "projectId": "01e23427-1a1f-36ad-bd87-4de9e68eff40",
    "server": "traduora.es",
    "outputPath": "code/resources/strings",
    "outputFileName": "Localizable.generated.strings"
}
```

Se puede encontrar un ejemplo de esté Package [aquí](Sample/AppDependencies)

Una vez incluido el plugin al proyecto y colocado el json `traduora.json`, podremos ejecutar traduora desde el menu contextual de Xcode al pulsar con el botón derecho sobre el proyecto y seleccionando el target o targets sorbre el que queramos ejecutarlo.

![](Sample/Plugin%20execution.gif)


### Textos en traduora

Los textos que pongamos en la plataforma traduora permiten las siguientes adaptaciones a la hora de indicar parámetros para su compatibilidad con Android:

- Para añadir un parámetro de tipo `string` debemos mantener el siguiente formato:
  ```
  {{$<posición>;string}}
  ```
    > Ejemplo: `"Hola, {{$1;string}} y {{$2;string}}"` da como salida `"Hola, %@ y %@"`

- Para añadir un parámetro de tipo `int` debemos mantener el siguiente formato:
  ```
  {{$<posición>;number}}
  ```
    > Ejemplo: `"Hola, tengo {{$1;number}} años."` da como salida `"Hola, tengo %ld años."`

- Para añadir un parámetro de tipo `float` debemos mantener uno de los siguientes formatos:
  ```
  {{$<posición>;decimal}} -- Sin especificar número de decimales a mostrar
  {{$<posición>;decimal;<decimales>}} -- Especificando el número de decimales a mostrar
  ```
  La variable `<decimales>` será el número de decimales que se quieren mostrar. Es opcional y no tiene porque indicarse.
    > Ejemplo: `"Valor del número Pi: {{$1;decimal}}"` da como salida `"Valor del número Pi: %f"`
    > Ejemplo: `"Valor del número Pi con 4 decimales: {{$1;decimal;4}}"` da como salida `"Valor del número Pi con 4 decimales: %.4f"`

---
En todos los casos vistos la variable `<posición>` es la posición que ocupa el parámetro en la cadena de texto, empezando desde 1. Cada nuevo parámetro aumentará este valor en 1.

  > Ejemplo: `"Hola, {{$1;string}} y {{$2;string}}. Tengo {{$3;number}} años y el número Pi tiene un valor de {{$4;decimal;8}}"` da como salida `"Hola, %@ y %@. Tengo %ld años y el número Pi tiene un valor de %.8f"`

### Parámetros del script

Al llamar al script SDOSTraduora podemos usar los siguientes parámetros

|Parámetro|Obligatorio|Descripción|Ejemplo|
|---------|-----------|-----------|-----------|
|`--lang [valor]`||Locales a descargar separados por `;`. Si no se indica se descargan todos los locales disponibles en el proyecto|`es_ES;eu_ES`|
|`--client-id [valor]`|[x]| `client id` del proyecto creado en traduora. Se obtiene del apartado `API Keys` del proyecto en traduora| `6d7bdab2-9bf4-4207-8f9b-8b4fc092715c`|
|`--client-secret [valor]`|[x]|`client secret` del proyecto creado en traduora. Se obtiene del apartado `API Keys` del proyecto en traduora|`bXTaRO6ilBLtNykwXsuvaAbXtllbAwla`|
|`--project-id [valor]`|[x]|Identificador del proyecto de traduora. Se puede obtener de la propia url al entrar un proyecto de traduora|`f2413d5a-71b6-48ce-b27d-64a82dd71899`|
|`--server [valor]`|[x]|Dominio del servidor de traduora donde se deberá conectar para realizar la descarga de los ficheros|`traduora.myinstance.com`|
|`--output-path [valor]`|[x]|Carpeta de destino donde se descargaran las traduciones de traduora|`${SRCROOT}/main/resources/generated`|
|`--output-file-name [valor]`|[x]|Nombre de los ficheros descargados desde traduora|`Localizable.generated.strings`|
