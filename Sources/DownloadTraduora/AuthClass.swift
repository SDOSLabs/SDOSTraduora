//
//  File.swift
//  
//
//  Created by Oleg Tverdyy on 27/5/21.
//

import Foundation

final public class AuthClass {
    public static let shared = AuthClass()
    
    private init() { }
    
    private var authObject: AuthDTO?
    
    public func auth(_ form: AuthObject, server: String?) throws {
        
        guard let parameters = try? form.jsonData() else { throw TraduoraError.authenticationInvalidRequestData }
        
        let semaphore = DispatchSemaphore(value: 0)
        
        let request = NSMutableURLRequest(url: URL(string: "\(Constants.ws.getBaseUrl(server: server))\(Constants.ws.auth)")!,
                                          cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                          timeoutInterval: 15.0)
        request.httpMethod = Constants.ws.method.POST
        request.allHTTPHeaderFields = [
            Constants.ws.headers.contentType: Constants.ws.headers.value.json
        ]
        request.httpBody = parameters
        print("[SDOSTraduora] Request \(Constants.ws.getBaseUrl(server: server))\(Constants.ws.auth)")
        
        let session = Constants.session
        var errorWS: Error? = nil
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            guard error == nil, let data = data else {
                errorWS = TraduoraError.authentication(error!)
                semaphore.signal()
                return
            }

            if let auth = try? AuthDTO(data: data) {
                print("[SDOSTraduora] Success request \(request.url?.absoluteString ?? "")")
                print(String(data: data, encoding: .utf8) ?? "")
                self.authObject = auth
            } else {
                print("[SDOSTraduora] Failed request \(request.url?.absoluteString ?? "")")
                print(String(data: data, encoding: .utf8) ?? "")
                errorWS = TraduoraError.authenticationInvalidResponseData
            }
            
            semaphore.signal()
        })
        dataTask.resume()
        
        semaphore.wait()
        
        if let errorWS {
            throw errorWS
        }
    }
    
    func bearer() -> String {
        "Bearer \(authObject?.accessToken ?? "")"
    }
}
