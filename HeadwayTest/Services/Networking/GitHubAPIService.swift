//
//  GitHubAPIService.swift
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
    
    private let storage: APIStorage
    
    init() {
        self.storage = UserDefaultsStorage()
    }
    
    func performRequest(api: GitHubAPI) -> Observable<Data?> {
        guard let url = api.url else { return Observable.empty() }
        var request = URLRequest(url: url)
        request.httpMethod = api.httpMethod
        let headers = api.headers
        headers?.forEach {
            request.addValue($0.value, forHTTPHeaderField: $0.key)
        }
        request.httpBody = api.body
        return URLSession.shared.rx.data(request: request)
            .map { Optional.init($0) }
            .catchError { (error) -> Observable<Data?> in
                throw error
            }
    }
}

extension GitHubAPIService: GitHubAPILoginProvider {
    
    func login(username: String, password: String) -> Observable<Bool> {
        let api: GitHubAPI = .login(model: UserInput(name: username, pass: password))
        
        return performRequest(api: api)
            .map { (data) -> Bool in
                guard let data = data,
                      let response = try? JSONDecoder().decode(AuthTokenEntity.self, from: data) else {
                    return false
                }
                self.storage.token = response.token
                return true
            }
            .catchError { (error) in
                throw error
            }
    }
}

extension GitHubAPIService: GitHubAPIRepositoryProvider {
    
    func searchRepositories(for query: String, page: Int) -> Observable<[RepositoryEntity]?> {
        guard let token = storage.token else { return .empty() }
        let api: GitHubAPI = .search(model: SearchInput(query: query, page: page, token: token))
        return performRequest(api: api)
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
            .catchError { (error) in
                throw error
            }
    }
}

extension GitHubAPIService: StaticFactory {
    enum Factory {
        static let build: GitHubAPIProvider = GitHubAPIService()
    }
}
