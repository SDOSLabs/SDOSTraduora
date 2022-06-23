//
//  File.swift
//  
//
//  Created by Rafael FERNANDEZ on 22/6/22.
//

import Foundation

public struct ExecuteTraduora {
    
    public var lang: String?
    public var label: String?
    public var clientId: String
    public var clientSecret: String
    public var projectId: String
    public var server: String?
    public var output: String
    public var outputFileName: String
    
    public var authObject: AuthObject!
    public var langs: [String] = [String]()
    
    public init(clientId: String,
                clientSecret: String,
                projectId: String,
                server: String?,
                output: String,
                outputFileName: String) {
        self.clientId = clientId
        self.clientSecret = clientSecret
        self.projectId = projectId
        self.server = server
        self.output = output
        self.outputFileName = outputFileName
    }
    
    public mutating func run() throws {
        auth()
        getLangs()
        
        langs.forEach {
            downloadLang(language: $0)
        }
    }
    
    public func downloadLang(language: String) {
        print("[SDOSTraduora] Descargando idioma \(language)...")
        LangClass.shared.download(server: server, project: self.projectId, language: language, output: self.output, fileName: outputFileName, label: self.label)
    }
    
    public mutating func getLangs() {
        if let lang = lang {
            self.langs = lang.components(separatedBy: ";")
        }
        
        if self.langs.count == 0 {
            LangClass.shared.langs(project: projectId, server: server)
            if let langs = LangClass.shared.getAllLangs() {
                self.langs = langs
            }
        }
    }
    
    public mutating func auth() {
        authObject = AuthObject(clientID: clientId, clientSecret: clientSecret)
        AuthClass.shared.auth(authObject, server: server)
    }
    
}
