//
//  HistoryViewController.swift
//  HeadwayTest
//
//  Created by Kseniia Poternak on 10.11.2020.
//

import UIKit
import RxSwift
import SafariServices

final class HistoryViewController: DisposeViewController, Storyboarded {
    
    private var dataSource: [SearchResultItem] = []
    private let selectedIndexSubject = PublishSubject<SearchResultItem>()
    
    var selectedIndex: Observable<SearchResultItem> {
        return selectedIndexSubject.asObservable()
    }
    
    @IBOutlet private(set) var tableView: UITableView!
    @IBOutlet private(set) var closeButton: UIButton!
}


extension HistoryViewController: StaticFactory {
    enum Factory {
        static func build(repositories: [SearchResultItem]?) -> HistoryViewController {
            let viewController = HistoryViewController.instantiate()
            let driver = HistoryDriver.Factory.build(repositories: repositories)
            let actionBinder = HistoryActionBinder(viewController: viewController, driver: driver)
            let stateBinder = HistoryStateBinder(viewController: viewController, driver: driver)
            let navigationBinder = DismissBinder<HistoryViewController>.Factory
                .dismiss(viewController: viewController, driver: driver.didClose)
            let navigationBinder2 = NavigationPushBinder<SearchResultItem, HistoryViewController>.Factory
                .present(viewController: viewController,
                      driver: driver.didSelect,
                      factory: repositorySavaryViewController)
            
            viewController.bag.insert(
                stateBinder,
                actionBinder,
                navigationBinder,
                navigationBinder2
            )
            
            return viewController
        }
        
        private static func repositorySavaryViewController(_ item: SearchResultItem) -> UIViewController {
            return SFSafariViewController(url: URL(string: item.url)!)
        }
    }
}


extension HistoryViewController: UITableViewDataSource, UITableViewDelegate {
    func setDataSource(_ dataSource: [SearchResultItem]) {
        self.dataSource = dataSource
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultItemTableViewCell.identifier,
                                                 for: indexPath) as! SearchResultItemTableViewCell
        cell.configure(withRepoItem: dataSource[indexPath.row], selectedItems: [])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexSubject.onNext(dataSource[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
