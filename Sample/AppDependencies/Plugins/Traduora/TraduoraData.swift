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
///         "clientId": "a565aa78-7756-47a7-a35d-b88776dcadbd",
///         "clientSecret": "hRuejUMJ3R6DUJMPG6GH17PFABGsn40k",
///         "projectId": "01e23427-1a1f-4e9a-bd87-4de9e68eff40",
///         "server": "traduoralatest.sdos.es",
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
