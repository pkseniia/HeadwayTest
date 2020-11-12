//
//  NavigationBinder.swift
//  HeadwayTest
//
//  Created by Kseniia Poternak on 10.11.2020.
//

import UIKit
import RxSwift
import RxCocoa

final class NavigationBinder<Prop, Transition, ViewController>: ViewControllerBinder
where Transition: Transitioning,
      Transition.Prop == Prop,
      ViewController: UIViewController,
      ViewController: DisposeContainer {
    
    unowned let viewController: ViewController
    private let transition: Transition
    private let driver: Driver<Prop>
    
    init(viewController: ViewController,
         transition: Transition,
         driver: Driver<Prop>) {
        self.viewController = viewController
        self.transition = transition
        self.driver = driver
        
        bind()
    }
    
    func dispose() { }
    
    func bindLoaded() {
        driver
            .drive(onNext: transition.perform)
            .disposed(by: viewController.bag)
    }
}

typealias NavigationPushBinder<Prop, ViewController> = NavigationBinder<Prop, NavigationPushTransition<Prop>, ViewController> where ViewController: UIViewController, ViewController: DisposeContainer

typealias NavigationPopBinder<ViewController> = NavigationBinder<Void, NavigationPopTransition, ViewController> where ViewController: UIViewController, ViewController: DisposeContainer

typealias DismissBinder<ViewController> = NavigationBinder<Void, DismissTransition, ViewController> where ViewController: UIViewController, ViewController: DisposeContainer

extension NavigationBinder: StaticFactory {
    typealias ViewControllerFactory<Prop> = (Prop) -> UIViewController?
    
    enum Factory {
        static func present(viewController: ViewController,
                            driver: Driver<Prop>,
                            animated: Bool = true,
                            sourceViewFactory: (() -> UIView)? = nil,
                            factory: @escaping ViewControllerFactory<Prop>) -> NavigationBinder<Prop, PresentTransition<Prop>, ViewController> {
            let transition = PresentTransition(isAnimated: animated,
                                               viewController: viewController,
                                               sourceViewFactory: sourceViewFactory,
                                               presentedFactory: factory)
            return NavigationBinder<Prop, PresentTransition<Prop>, ViewController>(viewController: viewController,
                                                                                   transition: transition,
                                                                                   driver: driver)
        }
        
        static func push(viewController: ViewController,
                         driver: Driver<Prop>,
                         animated: Bool = true,
                         factory: @escaping ViewControllerFactory<Prop>) -> NavigationPushBinder<Prop, ViewController> {
            let transition = NavigationPushTransition(isAnimated: animated,
                                                      viewController: viewController,
                                                      presentedFactory: factory)
            return NavigationPushBinder<Prop, ViewController>(viewController: viewController,
                                                              transition: transition,
                                                              driver: driver)
        }
        
        static func dismiss(viewController: ViewController,
                            driver: Driver<Void>,
                            animated: Bool = true) -> DismissBinder<ViewController> {
            let transition = DismissTransition(isAnimated: animated, viewController: viewController)
            return DismissBinder(viewController: viewController,
                                 transition: transition,
                                 driver: driver)
        }
        
        static func pop(viewController: ViewController,
                        driver: Driver<Void>,
                        animated: Bool = true) -> NavigationPopBinder<ViewController> {
            let transition = NavigationPopTransition(isAnimated: animated, viewController: viewController)
            return NavigationPopBinder(viewController: viewController,
                                       transition: transition,
                                       driver: driver)
        }
    }
}
