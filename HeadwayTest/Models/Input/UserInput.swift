//
//  UserInput.swift
//  HeadwayTest
//
//  Created by Kseniia Poternak on 10.11.2020.
//

// 🐰
//import Foundation
//
//struct UserInput {
//
//    let credentials: String
//    let parameters: UserLoginParameters
//
//    init(name: String, pass: String) {
//        let credentialData = "\(name):\(pass)".data(using: String.Encoding.utf8)!
//        self.credentials = credentialData.base64EncodedString(options: [])
//        self.parameters = UserLoginParameters()
//    }
//}
//
//struct UserLoginParameters: Codable {
//
//    var scopes: [String] = ["repo", "read:user"]
//    var note: [String] = ["test"]
//    var fingerprint: [String] = [UUID().uuidString]
//
//    enum CodingKeys: String, CodingKey {
//        case scopes
//        case note
//        case fingerprint
//    }
//}
