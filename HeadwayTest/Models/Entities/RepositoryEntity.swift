//
//  RepositoryEntity.swift
//  HeadwayTest
//
//  Created by Kseniia Poternak on 10.11.2020.
//

import Foundation

struct RepositoryEntity: Codable {
    let id: Int
    let fullName: String?
    let owner: Owner?
    let htmlURL: String?
//    let stargazersCount: Int 🐰

    enum CodingKeys: String, CodingKey {
        case id, owner
        case fullName = "full_name"
        case htmlURL = "html_url"
//        case stargazersCount = "stargazers_count"
    }
}
