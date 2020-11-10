//
//  SearchViewController.swift
//  HeadwayTest
//
//  Created by Kseniia Poternak on 10.11.2020.
//

import UIKit
import RxSwift
import SafariServices

final class SearchViewController: DisposeViewController, Storyboarded {
    @IBOutlet private(set) var searchTextField: UITextField!
    @IBOutlet private(set) var tableView: UITableView!
    @IBOutlet private(set) var historyButton: UIButton!
    
    private var dataSource: [SearchResultItem] = []
    private var selectedRepos = [SearchResultItem]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    private let selectedIndexSubject = PublishSubject<SearchResultItem>()
    private let selectedIndexesSubject = PublishSubject<[SearchResultItem]>()
    
    var selectedIndex: Observable<SearchResultItem> {
        return selectedIndexSubject.asObservable()
    }
    
    var selectedIndexes: Observable<[SearchResultItem]> {
        return selectedIndexesSubject.asObservable()
    }
}

extension SearchViewController: StaticFactory {
    enum Factory {
        static var build: SearchViewController {
            let viewController = SearchViewController.instantiate()
            let driver = SearchDriver.Factory.build
            let actionBinder = SearchActionBinder(viewController: viewController, driver: driver)
            let stateBinder = SearchStateBinder.Factory.build(viewController, driver: driver)
            let navigationBinder = NavigationPushBinder<SearchResultItem, SearchViewController>.Factory
                .present(viewController: viewController, driver: driver.didSelect, factory: repositorySavaryViewController)
            
            viewController.bag.insert(
                stateBinder,
                actionBinder,
                navigationBinder
            )
            return viewController
        }
        
        private static func repositorySavaryViewController(_ item: SearchResultItem) -> UIViewController {
            return SFSafariViewController(url: URL(string: item.url)!)
        }
    }
}

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    func setDataSource(_ dataSource: [SearchResultItem]) {
        self.dataSource = dataSource
        tableView.reloadData()
        // 🐰
//        self.dataSource.removeAll()
//        let part1 = PublishSubject<[SearchResultItem]>()
//        let part2 = PublishSubject<[SearchResultItem]>()
//        let concurrentScheduler = ConcurrentDispatchQueueScheduler(qos: .background)
//        Observable.of(part1,part2)
//                  .observeOn(concurrentScheduler)
//                  .merge()
//                  .subscribeOn(MainScheduler())
//                    .subscribe(onNext:{ [weak self] in
//                        self?.dataSource.append(contentsOf: $0)
//                        self?.tableView.reloadData()
//                    })
//            .disposed(by: bag)
//        let customDataSource = dataSource
//        if customDataSource.count > 15 {
//            part1.onNext(Array(customDataSource.dropFirst(15)))
//            part2.onNext(customDataSource)
//        } else {
//            part1.onNext(customDataSource)
//        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultItemTableViewCell.identifier,
                                                 for: indexPath) as! SearchResultItemTableViewCell
        cell.configure(withRepoItem: dataSource[indexPath.row], selectedItems: selectedRepos)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedRepo = dataSource[indexPath.row]
        
        if !selectedRepos.contains(where: { $0.id == selectedRepo.id }) { selectedRepos.append(selectedRepo) }
            
        selectedIndexSubject.onNext(dataSource[indexPath.row])
        selectedIndexesSubject.onNext(selectedRepos)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == dataSource.count - 1 {
            // pagination 🐰
        }
    }
}
