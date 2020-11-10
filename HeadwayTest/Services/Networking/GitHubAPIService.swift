//
//  GitHubAPI.swift
//  HeadwayTest
//
//  Created by Kseniia Poternak on 10.11.2020.
//

import Foundation
import RxSwift
import RxCocoa

protocol GitHubAPILoginProvider {
    func login(username: String, password: String) -> Observable<Bool>
}

protocol GitHubAPIRepositoryProvider {
    func searchRepositories(for query: String, page: Int) -> Observable<[RepositoryEntity]?>
}

protocol GitHubAPIProvider: GitHubAPILoginProvider, GitHubAPIRepositoryProvider { }

final class GitHubAPIService: GitHubAPIProvider {
    
    private let httpClient: HTTPClientProvider
    private let storage: UserDefaultsStorageProtocol
    
    init() {
        self.httpClient = HTTPClient()
        self.storage = UserDefaultsStorage()
    }
    
    func login(username: String, password: String) -> Observable<Bool> {
        let credentialData = "\(username):\(password)".data(using: String.Encoding.utf8)!
        let base64Credentials = credentialData.base64EncodedString(options: [])
        
        
        return httpClient.post(url: "https://api.github.com/authorizations",
                               params: ["scopes": ["repo", "read:user"], "note": ["test"], "fingerprint": ["\(UUID().uuidString)"]],
                               base64Credentials: base64Credentials)
            .map { (data) -> Bool in
                guard let data = data,
                      let response = try? JSONDecoder().decode(AuthTokenEntity.self, from: data) else {
                    return false
                }
                self.storage.saveToken(response.token ?? "", key: .token)
                return true
            }
            .catchError { (error) in
                throw error
            }
    }
    
    func searchRepositories(for query: String, page: Int) -> Observable<[RepositoryEntity]?> {
        return httpClient.get(url: "https://api.github.com/search/repositories?q=\(query)&sort=stars&page=\(page)", token: storage.getToken(key: .token) ?? "")
            .map { (data) -> [RepositoryEntity]? in
                guard let data = data,
                      let response = try? JSONDecoder().decode(RepositoriesSearchResult.self, from: data) else {
                    return nil
                }
                return response.items
            }
            .map { (repositories) -> [RepositoryEntity]? in
                return repositories
            }
    }
}

extension GitHubAPIService: StaticFactory {
    enum Factory {
        static let build: GitHubAPIProvider = GitHubAPIService()
    }
}



