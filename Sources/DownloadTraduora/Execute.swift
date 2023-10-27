//
//  File.swift
//  
//
//  Created by Rafael FERNANDEZ on 22/6/22.
//

import Foundation
//
//public struct Execute: ParsableCommand {
//    
//    @Option(help: "Locale key to download, add one param each locale needed separeted by ';'. | Example: es_ES;eu_ES") public var lang: String?
//    @Option(name: [.customShort("k"), .long], help: "Label used to filter the translations exported by modules.") public var label: String?
//    @Option(name: [.customShort("c"), .long], help: "Client_id api created in traduora.") public var clientId: String
//    @Option(name: [.customShort("s"), .long], help: "Client_secret api created in traduora.") public var clientSecret: String
//    @Option(name: [.customShort("i"), .long], help: "Project id from traduora") public var projectId: String
//    @Option(name: [.long], help: "Traduora domain server (For example: traduora.sdos.es") public var server: String?
//    
//    @Option(name: [.customShort("o"), .customLong("output-path")], help: "Desired output path for generated files.") public var output: String
//    @Option(name: [.customShort("f"), .customLong("output-file-name")], help: "Desired file name for generated files.") public var outputFileName: String
//    
//    public var authObject: AuthObject!
//    public var langs: [String] = [String]()
//    
//    public mutating func run() throws {
//        auth()
//        getLangs()
//        
//        langs.forEach {
//            downloadLang(language: $0)
//        }
//    }
//    
//    public func downloadLang(language: String) {
//        print("[SDOSTraduora] Descargando idioma \(language)...")
//        LangClass.shared.download(server: server, project: self.projectId, language: language, output: self.output, fileName: outputFileName, label: self.label)
//    }
//    
//    public mutating func getLangs() {
//        if let lang = lang {
//            self.langs = lang.components(separatedBy: ";")
//        }
//        
//        if self.langs.count == 0 {
//            LangClass.shared.langs(project: projectId, server: server)
//            if let langs = LangClass.shared.getAllLangs() {
//                self.langs = langs
//            }
//        }
//    }
//    
//    public mutating func auth() {
//        authObject = AuthObject(clientID: clientId, clientSecret: clientSecret)
//        AuthClass.shared.auth(authObject, server: server)
//    }
//    
//}
