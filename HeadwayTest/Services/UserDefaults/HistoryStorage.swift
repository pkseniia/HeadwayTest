//
//  HistoryStorage.swift
//  HeadwayTest
//
//  Created by Kseniia Poternak on 11.11.2020.
//

import Foundation

protocol HistoryStorage: AnyObject {
    func saveData<Data>(_ data: Data) throws where Data: Encodable
    func getData<Data>(castTo type: Data.Type) throws -> Data where Data: Decodable
    func deleteData()
}

extension UserDefaultsStorage: HistoryStorage {
    
    enum HistoryStorageKey: String, DefaultsKey {
        case history
    }
    
    func saveData<Data>(_ data: Data) throws where Data: Encodable {
        try saveData(data, key: HistoryStorageKey.history)
    }
    
    func getData<Data>(castTo type: Data.Type) throws -> Data where Data: Decodable {
        try getData(key: HistoryStorageKey.history, castTo: type)
    }
    
    func deleteData() {
        deleteData(for: HistoryStorageKey.history)
    }
}
