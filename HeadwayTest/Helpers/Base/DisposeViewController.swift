//
//  DisposeViewController.swift
//  HeadwayTest
//
//  Created by Kseniia Poternak on 10.11.2020.
//

import UIKit
import RxSwift

protocol DisposeContainer {
    var bag: DisposeBag { get }
}

class DisposeViewController: UIViewController, DisposeContainer {
    let bag = DisposeBag()
}
