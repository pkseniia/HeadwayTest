//
//  OAuthService.swift
//  HeadwayTest
//
//  Created by Kseniia Poternak on 11.11.2020.
//

import UIKit
import OAuthSwift
import RxSwift
import RxCocoa

protocol OAuthServiceProtocol {
    func loadOAuth()
}

class OAuthService {
    
    private let oauthswift: OAuth2Swift
    unowned let viewController: UIViewController
    private let storage: APIStorage
    
    init(viewController: UIViewController) {
        self.viewController = viewController
        self.storage = UserDefaultsStorage()
        self.oauthswift = OAuth2Swift(
            consumerKey:    AppConstants.OAuthCredentials.clientID,
            consumerSecret: AppConstants.OAuthCredentials.clientSecret,
            authorizeUrl:   AppConstants.OAuthCredentials.authorizeUrl,
            accessTokenUrl: AppConstants.OAuthCredentials.accessTokenUrl,
            responseType:   AppConstants.OAuthCredentials.token
        )
    }
}

extension OAuthService: OAuthServiceProtocol {
    
    func loadOAuth() {
        oauthswift.allowMissingStateCheck = true
        oauthswift.authorizeURLHandler = SafariURLHandler(viewController: viewController, oauthSwift: oauthswift)
        guard let rwURL = URL(string: AppConstants.OAuthCredentials.urlScheme) else { return }
        oauthswift.authorize(withCallbackURL: rwURL, scope: AppConstants.OAuthCredentials.scope, state: "") { [weak self] in
            guard let self = self else { return }
            let results = try? $0.get()
            guard let parameters = results?.parameters else { return }
            let authTokenEntity = AuthTokenEntity(parameters: parameters)
            self.storage.token = authTokenEntity.token
        }
    }
}
