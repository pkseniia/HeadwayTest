//
//  GitHubAPI.swift
//  HeadwayTest
//
//  Created by Kseniia Poternak on 11.11.2020.
//

import UIKit

enum GitHubAPI {
    case login(model: UserInput)
    case search(model: SearchInput)
}

extension GitHubAPI {

    var domainComponents: URLComponents {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.github.com"
        components.path = path
        return components
    }

    var url: URL? {
        var components = domainComponents
        switch self {
        case .search(let input):
            components.queryItems = input.queryItems
        default: break
        }
        return components.url
    }

    var path: String {
        switch self {
        case .login:
            return "/authorizations"
        case .search:
            return "/search/repositories"
        }
    }

    var headers: [String: String]? {
        var internalHeaders = [
            "Content-Type": "application/json"
        ]

        switch self {
        case .login(let input):
            internalHeaders["Authorization"] = "Basic \(input.credentials)"
        case .search(let input):
            internalHeaders["Authorization"] = "Token \(input.token)"
        }
        return internalHeaders
    }

    var httpMethod: String {
        switch self {
        case .login:    return "POST"
        case .search:   return "GET"
        }
    }

    var body: Data? {
        switch self {
        case .login(let input):
            return input.parameters.encoded
        default: return nil
        }
    }
}

extension Encodable {
    var encoded: Data? {
        return try? JSONEncoder().encode(self)
    }
}
