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
    case pagination
    case searchResults([SearchResultItem])
    case showWatchedRepos([SearchResultItem]?)
    case failure(Error?)
}

protocol SearchDriverProtocol {
    var state: Driver<SearchState> { get }
    var didSelect: Driver<SearchResultItem> { get }
    
    func select(_ model: SearchResultItem)
    func search(_ query: String)
    func save(repositories: [SearchResultItem])
    func showWatchedRepos()
    func addPage()
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
    
    var savedQuery: String = ""
    var page: Int = 1
    
    private let api: GitHubAPIRepositoryProvider
    private let storage: Storages
    
    init(api: GitHubAPIRepositoryProvider) {
        self.api = api
        self.storage = UserDefaultsStorage()
        bind()
    }
    
    func addPage() {
        page += 2
        search(savedQuery)
    }
    
    func select(_ model: SearchResultItem) {
        didSelectRelay.accept(model)
    }

    func search(_ query: String) {
        bag = DisposeBag()
        let isValid = query.count > 2
        
        guard isValid else {
            page = 1
            stateRelay.accept(.searchResults([]))
            return
        }
        
        if savedQuery != query { page = 1 }
        savedQuery = query
        
        searchInZip(for: query)
            .trackActivity(activityIndicator)
            .catchError({ error in Observable.empty()
                                    .do(onCompleted: { [weak self] in self?.stateRelay.accept(.failure(error)) })
            })
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .bind(onNext: { [unowned self] in self.saveResults($0) })
            .disposed(by: bag)
    }
    
    private func searchInZip(for query: String) -> Observable<[SearchResultItem]> {
        let part1 = getSearchResult(query, page)
            .subscribeOn(ConcurrentDispatchQueueScheduler.init(qos: .utility))
        let part2 = getSearchResult(query, page + 1)
            .subscribeOn(ConcurrentDispatchQueueScheduler.init(qos: .utility))

        let result = Observable.zip(part1, part2) { return $0 + $1 }
            .map({ $0 })
        return result
    }

    private func getSearchResult(_ query: String, _ page: Int) -> Observable<[SearchResultItem]> {
        api.searchRepositories(for: query, page: page)
            .map({ $0 ?? [] })
            .mapMany(SearchResultItem.init)
    }
    
    private func saveResults(_ results: [SearchResultItem]) {
        page == 1 ? searchResults = results : searchResults?.append(contentsOf: results)
    }
    
    func save(repositories: [SearchResultItem]) {
        try? storage.saveData(repositories)
    }
    
    func showWatchedRepos() {
        let repositories = try? storage.getData(castTo: [SearchResultItem].self)
        stateRelay.accept(.showWatchedRepos(repositories))
    }
    
    private func bind() {
        
        storage.token = nil
        storage.deleteData()
        
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
