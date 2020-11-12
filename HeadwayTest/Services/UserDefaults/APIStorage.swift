//
//  APIStorage.swift
//  HeadwayTest
//
//  Created by Kseniia Poternak on 11.11.2020.
//

import Foundation

protocol APIStorage: AnyObject {
    var token: String? { get set }
}

extension UserDefaultsStorage: APIStorage {
    
    enum APIStorageKey: String, DefaultsKey {
        case token
    }
    
    var token: String? {
        get { get(key: APIStorageKey.token) }
        set { save(value: newValue, key: APIStorageKey.token) }
    }
}
