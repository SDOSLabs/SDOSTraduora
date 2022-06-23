//
//  File.swift
//  
//
//  Created by Rafael FERNANDEZ on 22/6/22.
//

import Foundation
import PackagePlugin

@main
struct GenerateTraduora: CommandPlugin {
    func performCommand(context: PackagePlugin.PluginContext, arguments: [String]) async throws {
//        try "Prueba".write(toFile: "Prueba.txt", atomically: true, encoding: .utf8)
//        var executor = ExecuteTraduora(clientId: "fc36f2cc-0dce-4b77-ad27-8abe224357c3",clientSecret: "f6jjQvgzDv7VlVDnHhYbt989X9opbq64", projectId: "9b05d269-cfd9-4cf5-91c5-dc840343dc42", server: "traduoralatest.sdos.es", output: context.pluginWorkDirectory.string, outputFileName: "Localizable.generated.strings")
//        print(try context.tool(named: "SDOSTraduora").path)
//        try executor.run()
//        let result = try packageManager.build(.product("SDOSTraduora"), parameters: .init())
//        guard result.succeeded else {
//            fatalError("couldn't build product")
//        }
//        guard let executable = result.builtArtifacts.first(where : { $0.kind == .executable }) else {
//            fatalError("couldn't find executable")
//        }
//
        let process = Process()
//        process.executableURL = URL(fileURLWithPath: "\(executable.path)")
        process.executableURL = URL(fileURLWithPath: "\(try context.tool(named: "SDOSTraduora").path)")
        process.arguments = [
            "--client-id", "fc36f2cc-0dce-4b77-ad27-8abe224357c3",
            "--server", "traduoralatest.sdos.es",
            "--client-secret", "f6jjQvgzDv7VlVDnHhYbt989X9opbq64",
            "--project-id", "9b05d269-cfd9-4cf5-91c5-dc840343dc42",
            "--output-path", "\(context.pluginWorkDirectory)",
            "--output-file-name", "Localizable.generated.strings"
        ]
        try process.run()
        process.waitUntilExit()
        
        if process.terminationReason == .exit && process.terminationStatus == 0 {
            print("Success")
        }
        else {
            let problem = "\(process.terminationReason):\(process.terminationStatus)"
            Diagnostics.error("Traduora failed: \(problem)")
        }
    }


}

//struct GenerateTraduora: BuildToolPlugin {
//    func createBuildCommands(context: PackagePlugin.PluginContext, target: PackagePlugin.Target) async throws -> [PackagePlugin.Command] {
//        guard let target = target as? SourceModuleTarget else { return [] }
//        return [.prebuildCommand(displayName: "Generate Traduora", executable: try context.tool(named: "SDOSTraduora").path, arguments: [
//            "--server \"traduoralatest.sdos.es\"",
//            "--client-id fc36f2cc-0dce-4b77-ad27-8abe224357c3",
//            "--client-secret f6jjQvgzDv7VlVDnHhYbt989X9opbq64",
//            "--project-id 9b05d269-cfd9-4cf5-91c5-dc840343dc42",
//            "--output-path \"\(context.pluginWorkDirectory)\"",
//            "--output-file-name \"Localizable.generated.strings\""
//        ], outputFilesDirectory: context.pluginWorkDirectory.appending("ca.lproj"))
//        ]
//        
//        //--server "traduoralatest.sdos.es" --client-id ${CLIENT_ID} --client-secret ${CLIENT_SECRET} --project-id ${PROJECT_ID} --output-path "${SRCROOT}/main/ui/localization/strings" --output-file-name "Localizable.generated.strings"
//    }
//    
//    
//    
//}
