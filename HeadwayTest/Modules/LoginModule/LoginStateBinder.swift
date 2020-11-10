//
//  LoginStateBinder.swift
//  HeadwayTest
//
//  Created by Kseniia Poternak on 10.11.2020.
//

import UIKit

final class LoginStateBinder: ViewControllerBinder {
    private let driver: LoginDriverProtocol
    unowned let viewController: LoginViewController
    
    init(viewController: LoginViewController, driver: LoginDriverProtocol) {
        self.driver = driver
        self.viewController = viewController
        bind()
    }
    
    func dispose() { }
    
    func bindLoaded() {
        viewController.bag.insert(
            viewController.rx.viewWillAppear
                .bind(onNext: { [weak self] in self?.viewWillAppear($0) }),
            driver.state
                .drive(onNext: { [weak self] in self?.applyState($0) })
        )
    }
    
    private func viewWillAppear(_ animated: Bool) {
        viewController.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    private func applyState(_ state: LoginViewState) {
        let isEnabled = state != .disabled
        viewController.loginButton.isEnabled = isEnabled
        viewController.loginButton.alpha = isEnabled ? 1 : 0.3
    }
}
