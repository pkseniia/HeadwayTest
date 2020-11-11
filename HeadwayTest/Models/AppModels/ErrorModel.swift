//
//  ErrorModel.swift
//  HeadwayTest
//
//  Created by Kseniia Poternak on 11.11.2020.
//

import Foundation

protocol ErrorCreatable {
    init?(status: ErrorStatus, error: Error?)
}

enum ErrorStatus {
    case login
    case search
    
    var message: String {
        switch self {
        case .login: return "Wrong credentials"
        case .search: return "My bad 🥺"
        }
    }
}

struct ErrorModel: Error {

    var title: String = "Error"
    var message: String
}

extension ErrorModel: ErrorCreatable {
    init?(status: ErrorStatus, error: Error? = nil) {
        if let error = error as NSError? {
            self.message = error.code == -1009 ?
                "You are not connected to internet" : status.message
        } else {
            self.message = "Ooops.. Try again, please"
        }
    }
}
