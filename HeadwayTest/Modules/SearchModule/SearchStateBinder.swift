//
//  SearchStateBinder.swift
//  HeadwayTest
//
//  Created by Kseniia Poternak on 10.11.2020.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

final class SearchStateBinder: ViewControllerBinder {
    
    unowned let viewController: SearchViewController
    private let driver: SearchDriverProtocol
    
    init(viewController: SearchViewController,
         driver: SearchDriverProtocol) {
        self.viewController = viewController
        self.driver = driver
        bind()
    }
    
    func dispose() { }
    
    func bindLoaded() {
        viewController.tableView.register(SearchResultItemTableViewCell.cellNib,
                                          forCellReuseIdentifier: SearchResultItemTableViewCell.identifier)
        viewController.bag.insert(
            viewController.rx.viewWillAppear
                .bind(onNext: { [weak self] in self?.viewWillAppear($0) }),
            driver.state
                .drive(onNext: { [weak self] in self?.apply(state: $0) }),
            viewController.tableView.rx.reachedBottom()
                .bind(onNext: { [weak self] in self?.driver.addPage() })
        )
    }
    
    private func viewWillAppear(_ animated: Bool) {
        viewController.tableView.tableFooterView = UIView()
        viewController.navigationController?.setNavigationBarHidden(true, animated: false)
        viewController.searchTextField.style(with: "Search")
    }
    
    private func apply(state: SearchState) {
        switch state {
        case let .searchResults(repositories):
            viewController.setDataSource(repositories)
        case let .showWatchedRepos(repositories):
            let historyViewController = HistoryViewController.Factory.build(repositories: repositories)
            viewController.present(historyViewController, animated: true, completion: nil)
        case .failure(let error):
            let errorModel = ErrorModel(status: .search, error: error)
            viewController.showAlert(title: errorModel?.title, message: errorModel?.message, style: .alert,
                                     actions: [AlertAction.action(title: "Ok", style: .destructive)])
                .subscribe(onNext: { _ in })
                .disposed(by: bag)
            viewController.view.endEditing(true)
        default: break
        }
    }
}

extension SearchStateBinder: StaticFactory {
    enum Factory {
        static func build(_ viewController: SearchViewController, driver: SearchDriverProtocol) -> SearchStateBinder {
            return SearchStateBinder(viewController: viewController, driver: driver)
        }
    }
}
