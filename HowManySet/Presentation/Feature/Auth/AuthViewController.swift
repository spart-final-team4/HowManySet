//
//  LogInViewController.swift
//  HowManySet
//
//  Created by 정근호 on 6/3/25.
//

import UIKit

final class AuthViewController: UIViewController {
    
    private var reactor: AuthViewReactor
    
    init(reactor: AuthViewReactor) {
        self.reactor = reactor
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
