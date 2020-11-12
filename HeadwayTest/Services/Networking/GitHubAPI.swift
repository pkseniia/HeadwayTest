//
//  GitHubAPI.swift
//  HeadwayTest
//
//  Created by Kseniia Poternak on 11.11.2020.
//

import UIKit

enum GitHubAPI {
    case deprecatedLogin(model: UserInput)
    case deprecatedSearch(model: SearchInput)
    case search(model: SearchInput)
}

extension GitHubAPI {

    var domainComponents: URLComponents {
        var components = URLComponents()
        components.scheme = "https"
        components.host = AppConstants.URLs.api
        components.path = path
        return components
    }

    var url: URL? {
        var components = domainComponents
        switch self {
        case .search(let input), .deprecatedSearch(let input):
            components.queryItems = input.queryItems
        default: break
        }
        return components.url
    }

    var path: String {
        switch self {
        case .deprecatedLogin:
            return "/authorizations"
        case .deprecatedSearch, .search:
            return "/search/repositories"
        }
    }

    var headers: [String: String]? {
        var internalHeaders: [String: String] = [:]
        switch self {
        case .deprecatedLogin(let input):
            internalHeaders["Authorization"] = "Basic \(input.credentials)"
            internalHeaders["Content-Type"] = "application/json"
        case .deprecatedSearch(model: let input):
            internalHeaders["Authorization"] = "Token \(input.token)"
            internalHeaders["Content-Type"] = "application/json"
        case .search(let input):
            internalHeaders["Authorization"] = "Bearer \(input.token)"
            internalHeaders["Accept"] = "application/vnd.github.v3+json"
        }
        return internalHeaders
    }

    var httpMethod: String {
        switch self {
        case .deprecatedLogin:              return "POST"
        case .deprecatedSearch, .search:    return "GET"
        }
    }

    var body: Data? {
        switch self {
        case .deprecatedLogin(let input):
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
