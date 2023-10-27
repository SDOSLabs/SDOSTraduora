//
//  File.swift
//  
//
//  Created by Rafael FERNANDEZ on 25/10/23.
//

import Foundation

public enum TraduoraError: RawRepresentable, Error {
    case authentication(Error)
    case authenticationInvalidResponseData
    case authenticationInvalidRequestData
    case langRequest(Error)
    case langRequestInvalidResponseData
    case downloadLangRequest(Error)
    case downloadLangCreateFolders(String, Error)
    case downloadLangParser(String, String?)
    
    public init?(rawValue: String) {
        return nil
    }
    
    public var rawValue: String {
        switch self {
        case .authentication(let error):
            return "[SDOSTraduora] Error al autenticarse: \(error)"
        case .authenticationInvalidResponseData:
            return "[SDOSTraduora] Datos recibidos al autenticarse no válidos"
        case .authenticationInvalidRequestData:
            return "[SDOSTraduora] Datos usados para autenticarse no válidos"
        case .langRequest(let error):
            return "[SDOSTraduora] Error al recuperar los lenguajes de las traducciones. Error: \(error.localizedDescription)"
        case .langRequestInvalidResponseData:
            return "[SDOSTraduora] Datos recibidos al recuperar los localizables no válidos"
        case .downloadLangRequest(let error):
            return "[SDOSTraduora] Error al recuperar las traducciones. Error: \(error.localizedDescription)"
        case .downloadLangCreateFolders(let directoryName, let error):
            return "[SDOSTraduora] Error al crear la carpeta para las traduciones \(directoryName). Error: \(error.localizedDescription)"
        case .downloadLangParser(let language, let json):
            if let json {
                return "[SDOSTraduora] Error al parsear el JSON para el idioma \(language). JSON: \(json)"
            } else {
                return "[SDOSTraduora] Error al parsear el JSON para el idioma \(language)"
            }
        }
    }
}
