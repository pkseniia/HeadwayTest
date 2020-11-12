//
//  HistoryDriver.swift
//  HeadwayTest
//
//  Created by Kseniia Poternak on 10.11.2020.
//

import RxSwift
import RxCocoa

protocol HistoryDriverProtocol {
    var data: Driver<[SearchResultItem]> { get }
    var didClose: Driver<Void> { get }
    var didSelect: Driver<SearchResultItem> { get }
    
    func close()
    func select(_ model: SearchResultItem)
}

final class HistoryDriver: HistoryDriverProtocol {
    private let closeRelay = PublishRelay<Void>()
    private let dataRelay = BehaviorRelay<[SearchResultItem]?>(value: nil)
    private let didSelectRelay = BehaviorRelay<SearchResultItem?>(value: nil)
    
    var data: Driver<[SearchResultItem]> { dataRelay.unwrap().asDriver() }
    var didClose: Driver<Void> { closeRelay.asDriver() }
    var didSelect: Driver<SearchResultItem> { didSelectRelay.unwrap().asDriver() }
    
    init(repositories: [SearchResultItem]?) {
        dataRelay.accept(repositories)
    }
    
    func close() {
        closeRelay.accept(())
    }
    
    func select(_ model: SearchResultItem) {
        didSelectRelay.accept(model)
    }
}

extension HistoryDriver: StaticFactory {
    enum Factory {
        static func build(repositories: [SearchResultItem]?) -> HistoryDriverProtocol {
            HistoryDriver(repositories: repositories)
        }
    }
}
