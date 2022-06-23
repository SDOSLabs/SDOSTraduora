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
    
    public func auth(_ form: AuthObject, server: String?) {
        
        guard let parameters = try? form.jsonData() else { return }
        
        let semaphore = DispatchSemaphore(value: 0)
        
        let request = NSMutableURLRequest(url: URL(string: "\(Constants.ws.getBaseUrl(server: server))\(Constants.ws.auth)")!,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 15.0)
        request.httpMethod = Constants.ws.method.POST
        request.allHTTPHeaderFields = [
            Constants.ws.headers.contentType: Constants.ws.headers.value.json
        ]
        request.httpBody = parameters
        print("\(Constants.ws.getBaseUrl(server: server))\(Constants.ws.auth)")
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            guard error == nil, let data = data else {
                print("[SDOSTraduora] Error al autenticarse. Error: \(error!.localizedDescription)")
                semaphore.signal()
                exit(9)
            }

            if let auth = try? AuthDTO(data: data) {
                self.authObject = auth
            }
            
            semaphore.signal()
        })
        
        dataTask.resume()
        
        semaphore.wait()
    }
    
    func bearer() -> String {
        "Bearer \(authObject?.accessToken ?? "")"
    }
}
