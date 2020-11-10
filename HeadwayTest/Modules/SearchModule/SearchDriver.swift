//
//  SearchDriver.swift
//  HeadwayTest
//
//  Created by Kseniia Poternak on 10.11.2020.
//

import RxSwift
import RxCocoa
import RxSwiftExt

enum SearchState {
    case none
    case loading
    case searchResults([SearchResultItem])
    case showWatchedRepos([SearchResultItem]?)
}

protocol SearchDriverProtocol {
    var state: Driver<SearchState> { get }
    var didSelect: Driver<SearchResultItem> { get }
    
    func select(_ model: SearchResultItem)
    func search(_ query: String)
    func save(repositories: [SearchResultItem])
    func showWatchedRepos()
}

final class SearchDriver: SearchDriverProtocol {
    private var bag = DisposeBag()
    private let activityIndicator = ActivityIndicator()
    
    private let stateRelay = BehaviorRelay<SearchState>(value: .none)
    private let didSelectRelay = BehaviorRelay<SearchResultItem?>(value: nil)
    
    private var results: [RepositoryEntity]?
    
    private var searchResults: [SearchResultItem]? {
        didSet {
            if let repoItems = searchResults {
                stateRelay.accept(.searchResults(repoItems))
            }
        }
    }
    
    var state: Driver<SearchState> { stateRelay.asDriver() }
    var didSelect: Driver<SearchResultItem> { didSelectRelay.unwrap().asDriver() }
    
    private let api: GitHubAPIRepositoryProvider
    private let storage: UserDefaultsStorageProtocol
    
    init(api: GitHubAPIRepositoryProvider) {
        self.api = api
        self.storage = UserDefaultsStorage()
        bind()
    }
    
    func select(_ model: SearchResultItem) {
        didSelectRelay.accept(model)
    }
    
    func search(_ query: String) {
        let isValid = query.count >= 3
        
        guard isValid else { return }
        
        let searchResult: Observable<[SearchResultItem]>
        
        searchResult = api.searchRepositories(for: query, page: 0)
            .map({ $0 ?? [] })
            .mapMany(SearchResultItem.init)
        
        searchResult
            .trackActivity(activityIndicator)
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .bind(onNext: { [unowned self] in self[keyPath: \.searchResults] = $0 })
            .disposed(by: bag)
    }
    
    
    func save(repositories: [SearchResultItem]) {
        try? storage.saveData(repositories, key: .history)
    }
    
    func showWatchedRepos() {
        let repositories = try? storage.getData(key: .history,
                                                  castTo: [SearchResultItem].self)
        stateRelay.accept(.showWatchedRepos(repositories))
    }
    
    private func bind() {
        activityIndicator
            .filter({ $0 })
            .map({ _ in SearchState.loading })
            .drive(onNext: stateRelay.accept)
            .disposed(by: bag)
    }
}

extension SearchDriver: StaticFactory {
    enum Factory {
        static var build: SearchDriverProtocol {
            SearchDriver(api: GitHubAPIService.Factory.build)
        }
    }
}
