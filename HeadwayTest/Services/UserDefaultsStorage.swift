//
//  UserDefaultsStorage.swift
//  HeadwayTest
//
//  Created by Kseniia Poternak on 10.11.2020.
//

import Foundation

protocol DefaultsKey {
    var rawStringValue: String { get }
}

protocol SaveDataProtocol {
    func saveData<Data>(_ data: Data, key: StorageKey) throws where Data: Encodable
    func getData<Data>(key: StorageKey, castTo type: Data.Type) throws -> Data where Data: Decodable
}

protocol SaveTokenProtocol {
    func saveToken(_ token: String, key: StorageKey)
    func getToken(key: StorageKey) -> String?
}

enum StorageKey: String, DefaultsKey {
    case history
    case token
}

protocol UserDefaultsStorageProtocol: SaveDataProtocol, SaveTokenProtocol {}

enum UserDefaultsError: String, LocalizedError {
    case encodeError = "Encode error"
    case noData = "No data found"
    case decodeError = "Decode error"
    
    var errorDescription: String? {
        rawValue
    }
}

class UserDefaultsStorage: UserDefaultsStorageProtocol {
    
    let defaults: UserDefaults
    
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }
    
    func save<Value>(value: Value?, key: StorageKey) {
        if let value = value {
            defaults.setValue(value, forKey: key.rawStringValue)
        } else {
            defaults.removeObject(forKey: key.rawStringValue)
        }
    }
    
    func get<Value>(key: StorageKey) -> Value? {
        guard let value = defaults.value(forKey: key.rawStringValue) as? Value else { return nil }
        return value
    }
    
    
    func saveData<Data>(_ data: Data, key: StorageKey) throws where Data: Encodable {
        let encoder = JSONEncoder()
        do {
            let encodedData = try encoder.encode(data)
            UserDefaults.standard.set(encodedData, forKey: key.rawStringValue)
        } catch {
            throw UserDefaultsError.encodeError
        }
    }
    
    func getData<Data>(key: StorageKey, castTo type: Data.Type) throws -> Data where Data: Decodable {
        guard let data = UserDefaults.standard.data(forKey: key.rawStringValue) else {
            throw UserDefaultsError.noData
        }
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(type, from: data)
            return decodedData
        } catch {
            throw UserDefaultsError.decodeError
        }
    }
    
    func saveToken(_ token: String, key: StorageKey) {
        UserDefaults.standard.set(token, forKey: key.rawValue)
    }
    
    func getToken(key: StorageKey) -> String? {
        return UserDefaults.standard.string(forKey: key.rawValue)
    }
}

extension String: DefaultsKey {
    
    var rawStringValue: String { self }
    
}

extension RawRepresentable where RawValue == String {

    var rawStringValue: String { rawValue }

}
