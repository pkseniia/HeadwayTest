//
//  SearchInput.swift
//  HeadwayTest
//
//  Created by Kseniia Poternak on 11.11.2020.
//

import Foundation

struct SearchInput: Codable {

    let query: String
    var sort: String = "stars"
    let page: String
    var perPage: String = "15"
    
    let token: String

    init(query: String, page: Int, token: String) {
        self.query = query
        self.page = String(page)
        self.token = token
    }
}

extension SearchInput {
    var queryItems: [URLQueryItem] {
        [
            .init(name: "q", value: query),
            .init(name: "sort", value: sort),
            .init(name: "page", value: page),
            .init(name: "per_page", value: perPage)
        ]
    }
}
