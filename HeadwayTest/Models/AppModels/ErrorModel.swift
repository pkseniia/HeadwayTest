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
        case .login:    return AppConstants.Errors.wrongCredentials
        case .search:   return AppConstants.Errors.mayBad
        }
    }
}

struct ErrorModel: Error {

    var title: String = AppConstants.Errors.error
    var message: String
}

extension ErrorModel: ErrorCreatable {
    init?(status: ErrorStatus, error: Error? = nil) {
        if let error = error as NSError? {
            self.message = error.code == -1009 ?
                AppConstants.Errors.noInternet : status.message
        } else {
            self.message = AppConstants.Errors.oops
        }
    }
}
