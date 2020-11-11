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
        viewController.usernameTextField.style(with: AppConstants.Login.namePlaceholder)
        viewController.passwordTextField.style(with: AppConstants.Login.passwordPlaceholder)
        viewController.loginButton.setTitle(AppConstants.Login.signIn, for: .normal)
        viewController.loginButton.cornerRadius = viewController.loginButton.frame.height / 2.5
    }
    
    private func applyState(_ state: LoginViewState) {
        let isEnabled: Bool
        let alpha: CGFloat
        switch state {
        case .success, .loading, .enabled:
            isEnabled = true
            alpha = 1
        case .disabled:
            isEnabled = false
            alpha = 0.3
        case .failure(let error):
            isEnabled = true
            alpha = 1
            
            let errorModel = ErrorModel(status: .login, error: error)
            viewController.showAlert(title: errorModel?.title, message: errorModel?.message, style: .alert,
                                     actions: [AlertAction.action(title: AppConstants.Buttons.ok, style: .destructive)])
                .subscribe(onNext: { _ in })
                .disposed(by: bag)
        }
        viewController.loginButton.isEnabled = isEnabled
        viewController.loginButton.alpha = alpha
    }
}
