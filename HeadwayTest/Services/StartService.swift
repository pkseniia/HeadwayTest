//
//  StartService.swift
//  HeadwayTest
//
//  Created by Kseniia Poternak on 10.11.2020.
//

import UIKit

class StartService {
    
    static let shared = StartService()

    func start(in window: UIWindow) {

        let searchViewController = createSearchNavigationController()
        window.rootViewController = searchViewController
        window.makeKeyAndVisible()
        
        if !Date().checkIfGitHubAPIDeprecated() {
            let loginViewController = createLoginViewController()
            searchViewController.present(loginViewController, animated: true, completion: nil)
        }
    }
    
    private func createLoginViewController() -> UIViewController {
        let viewController = LoginViewController.Factory.build
        viewController.modalPresentationStyle = .overCurrentContext
        return viewController
    }
    
    private func createSearchNavigationController() -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: SearchViewController.Factory.build)
        return navigationController
    }
}
