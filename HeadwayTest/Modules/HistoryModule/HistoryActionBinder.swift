//
//  HistoryActionBinder.swift
//  HeadwayTest
//
//  Created by Kseniia Poternak on 10.11.2020.
//

import Foundation

final class HistoryActionBinder: ViewControllerBinder {
    unowned let viewController: HistoryViewController
    private let driver: HistoryDriverProtocol
    
    init(viewController: HistoryViewController,
         driver: HistoryDriverProtocol) {
        self.viewController = viewController
        self.driver = driver
        bind()
    }
    
    func dispose() { }
    
    func bindLoaded() {
        let select = viewController
            .selectedIndex
            .asDriver(onError: SearchResultItem())

        viewController.bag.insert(
            viewController.closeButton.rx.tap
                .bind(onNext: driver.close),
            
            select
                .drive(onNext: driver.select)
        )
    }
}
