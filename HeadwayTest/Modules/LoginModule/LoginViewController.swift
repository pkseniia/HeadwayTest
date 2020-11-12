//
//  LoginViewController.swift
//  HeadwayTest
//
//  Created by Kseniia Poternak on 10.11.2020.
//

import UIKit
import RxSwift
import RxCocoa

final class LoginViewController: DisposeViewController, Storyboarded {
    @IBOutlet private(set) var usernameTextField: UITextField!
    @IBOutlet private(set) var passwordTextField: UITextField!
    @IBOutlet private(set) var loginButton: UIButton!
}

extension LoginViewController: StaticFactory {
    enum Factory {
        static var build: LoginViewController {
            let viewController = LoginViewController.instantiate()
            let driver = LoginDriver.Factory.build
            let stateBinder = LoginStateBinder(viewController: viewController, driver: driver)
            let actionBinder = LoginActionBinder(viewController: viewController, driver: driver)
            
            let toMainDriver = driver.state.compactMap({ $0 == .success ? () : nil })

            let navigationBinder = DismissBinder<LoginViewController>.Factory
                .dismiss(viewController: viewController, driver: toMainDriver)

            viewController.bag.insert(stateBinder, actionBinder, navigationBinder)
            return viewController
        }
    }
}
