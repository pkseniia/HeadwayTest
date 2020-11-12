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
    private let storage: HistoryStorage
    
    init(api: GitHubAPIRepositoryProvider) {
        self.api = api
        self.storage = UserDefaultsStorage()
        bind()
    }
    
    func addPage() {
        page += 2
        searchInZip(for: savedQuery)
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
    }
    
    private func searchInZip(for query: String) {
        let part1 = getSearchResult(query, page)
            .subscribeOn(ConcurrentDispatchQueueScheduler.init(qos: .utility))
        let part2 = getSearchResult(query, page + 1)
            .subscribeOn(ConcurrentDispatchQueueScheduler.init(qos: .utility))

        let result = Observable.zip(part1, part2) { return $0 + $1 }
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .map({ $0 })

        result
            .trackActivity(activityIndicator)
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .bind(onNext: { [unowned self] in self.saveResults($0) })
            .disposed(by: bag)
    }

    private func getSearchResult(_ query: String, _ page: Int) -> Observable<[SearchResultItem]> {
        api.searchRepositories(for: query, page: page)
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
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
