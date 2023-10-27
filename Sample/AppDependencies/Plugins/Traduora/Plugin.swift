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
