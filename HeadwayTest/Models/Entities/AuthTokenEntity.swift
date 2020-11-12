//
//  AuthTokenEntity.swift
//  HeadwayTest
//
//  Created by Kseniia Poternak on 10.11.2020.
//

import Foundation

struct AuthTokenEntity: Decodable {
    let token: String?
    
    init(parameters: [String: Any]) {
        self.token = parameters["access_token"] as? String
    }
}
