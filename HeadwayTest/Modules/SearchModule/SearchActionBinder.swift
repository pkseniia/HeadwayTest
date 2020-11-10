//
//  SearchActionBinder.swift
//  HeadwayTest
//
//  Created by Kseniia Poternak on 10.11.2020.
//

import Foundation

final class SearchActionBinder: ViewControllerBinder {
    unowned let viewController: SearchViewController
    private let driver: SearchDriverProtocol
    
    init(viewController: SearchViewController, driver: SearchDriverProtocol) {
        self.viewController = viewController
        self.driver = driver
        bind()
    }
    
    func dispose() { }
    
    func bindLoaded() {
        let select = viewController
            .selectedIndex
            .asDriver(onError: SearchResultItem())
        
        let watchedRepos = viewController
            .selectedIndexes
            .asDriver(onError: [SearchResultItem()])
        
        let query = viewController.searchTextField.rx.text.orEmpty
        
        viewController.bag.insert(
            select
                .drive(onNext: driver.select),
            watchedRepos
                .drive(onNext: driver.save),
            query
                .bind(onNext: driver.search),
            viewController.historyButton.rx.tap
                .bind(onNext: driver.showWatchedRepos)
        )
    }
}
