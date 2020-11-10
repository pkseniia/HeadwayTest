//
//  RepositoriesSearchResult.swift
//  HeadwayTest
//
//  Created by Kseniia Poternak on 10.11.2020.
//

import Foundation

struct RepositoriesSearchResult: Codable {
    let totalCount: Int?
    let incompleteResults: Bool?
    let items: [RepositoryEntity]?
    let message: String?

    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case incompleteResults = "incomplete_results"
        case items
        case message
    }
}
