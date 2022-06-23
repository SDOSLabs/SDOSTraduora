//
//  File.swift
//  
//
//  Created by Oleg Tverdyy on 27/5/21.
//

import Foundation
// MARK: - AuthObject
public struct AuthObject: Codable {
    public var grantType: String = "client_credentials" //Need this value hardoced
    public var username: String = "ios@alten.es" //Need this value hardoced
    public var password: String = "-------------"
    public let clientID: String
    public let clientSecret: String

    public enum CodingKeys: String, CodingKey {
        case grantType = "grant_type"
        case clientID = "client_id"
        case clientSecret = "client_secret"
    }
    
    public init(clientID: String, clientSecret: String) {
        self.clientID = clientID
        self.clientSecret = clientSecret
    }
}

// MARK: AuthObject convenience initializers and mutators

extension AuthObject {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(AuthObject.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        clientID: String? = nil,
        clientSecret: String? = nil
    ) -> AuthObject {
        return AuthObject(
            clientID: clientID ?? self.clientID,
            clientSecret: clientSecret ?? self.clientSecret
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
