//
//  LogInViewController.swift
//  HowManySet
//
//  Created by 정근호 on 6/3/25.
//

import UIKit

final class AuthViewController: UIViewController {
    
    private weak var coordinator: AuthCoordinatorProtocol?
    
    private var reactor: AuthViewReactor
    
    init(reactor: AuthViewReactor, coordinator: AuthCoordinatorProtocol) {
        self.reactor = reactor
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
