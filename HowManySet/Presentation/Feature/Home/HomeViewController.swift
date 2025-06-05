//
//  MainViewController.swift
//  HowManySet
//
//  Created by 정근호 on 5/30/25.
//

import UIKit
import SnapKit

final class HomeViewController: UIViewController {
    
    private weak var coordinator: HomeCoordinatorProtocol?

    private let reactor: HomeViewReactor
    
    init(reactor: HomeViewReactor, coordinator: HomeCoordinatorProtocol) {
        self.reactor = reactor
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(#function)
    }


}

