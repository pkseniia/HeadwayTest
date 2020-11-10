//
//  SearchResultItem.swift
//  HeadwayTest
//
//  Created by Kseniia Poternak on 10.11.2020.
//

import Foundation

struct SearchResultItem: Codable {
    let id: Int
    let url: String
    let name: String
    let imageUrl: String?
    
    init() {
        self.id = 0
        self.url = ""
        self.name = ""
        self.imageUrl = ""
    }
}

extension SearchResultItem {
    init(repo: RepositoryEntity) {
        self.id = repo.id
        self.url = repo.htmlURL ?? ""
        self.name = repo.fullName ?? ""
        self.imageUrl = repo.owner?.avatarURL.flatMap { $0 }
    }
}
