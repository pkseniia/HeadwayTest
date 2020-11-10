//
//  ViewControllerBinder.swift
//  HeadwayTest
//
//  Created by Kseniia Poternak on 10.11.2020.
//

import UIKit
import RxSwift
import RxViewController

protocol Binding {
    func bind()
}

protocol ViewControllerBinder: Disposable {
    associatedtype DisposeViewControllerContainer: UIViewController, DisposeContainer
    
    var viewController: DisposeViewControllerContainer { get }
    func bindLoaded()
}

extension ViewControllerBinder {
    var bag: DisposeBag {
        viewController.bag
    }
}

extension ViewControllerBinder where Self: AnyObject {
    func bind() {
        viewController.rx.viewDidLoad
            .subscribe(onNext: { [weak self] in self?.bindLoaded() })
            .disposed(by: viewController.bag)
    }
    
    var binded: Self {
        bind()
        return self
    }
}
