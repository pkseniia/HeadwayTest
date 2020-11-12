//
//  LoginActionBinder.swift
//  HeadwayTest
//
//  Created by Kseniia Poternak on 10.11.2020.
//

import Foundation

final class LoginActionBinder: ViewControllerBinder {
    private let driver: LoginDriverProtocol
    unowned let viewController: LoginViewController
    
    init(viewController: LoginViewController, driver: LoginDriverProtocol) {
        self.driver = driver
        self.viewController = viewController
        bind()
    }
    
    func dispose() { }
    
    func bindLoaded() {
        let userName = viewController.usernameTextField.rx.text.map({ $0 ?? "" })
        let password = viewController.passwordTextField.rx.text.map({ $0 ?? "" })
        
        viewController.bag.insert(
            userName.bind(onNext: { [unowned self] in self[keyPath: \.driver.userName] = $0 }),
            password.bind(onNext: { [unowned self] in self[keyPath: \.driver.password] = $0 }),
            viewController.loginButton.rx.tap.bind(onNext: driver.login)
        )
    }
}
