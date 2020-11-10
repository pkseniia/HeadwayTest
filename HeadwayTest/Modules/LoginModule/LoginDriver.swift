//
//  LoginDriver.swift
//  HeadwayTest
//
//  Created by Kseniia Poternak on 10.11.2020.
//

import RxSwift
import RxCocoa

enum LoginViewState {
    case success
    case failure
    case loading
    case disabled
    case enabled
}

protocol LoginDriverProtocol: class {
    var state: Driver<LoginViewState> { get }
    var userName: String { get set }
    var password: String { get set }
    func login()
}

final class LoginDriver: LoginDriverProtocol {
    private let activityIndicator = ActivityIndicator()
    private let stateRelay = PublishRelay<LoginViewState>()
    
    private let api: GitHubAPIProvider
    
    let bag = DisposeBag()
    
    var state: Driver<LoginViewState> { stateRelay.asDriver() }
    
    var userName: String = "" {
        didSet { validateCredentials() }
    }
    var password: String = "" {
        didSet { validateCredentials() }
    }
    
    private var areCredentialsValid: Bool {
        userName.count > 0 && password.count >= 4
    }
    
    init(api: GitHubAPIProvider) {
        self.api = api
        bind()
    }
    
    func login() {
        api.login(username: userName, password: password)
            .trackActivity(activityIndicator)
            .map({ $0 ? .success : .failure })
//            .catchError({ error in }) 🐰
            .bind(onNext: stateRelay.accept)
            .disposed(by: bag)
    }
    
    private func bind() {
        activityIndicator
            .filter({ $0 })
            .map({ _ in LoginViewState.loading })
            .drive(onNext: stateRelay.accept)
            .disposed(by: bag)
    }
    
    private func validateCredentials() {
        stateRelay.accept(areCredentialsValid ? .enabled : .disabled)
    }
}

extension LoginDriver: StaticFactory {
    enum Factory {
        static var build: LoginDriverProtocol {
            LoginDriver(api: GitHubAPIService.Factory.build)
        }
    }
}
