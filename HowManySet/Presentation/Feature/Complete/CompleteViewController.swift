//
//  CompleteViewController.swift
//  HowManySet
//
//  Created by 정근호 on 6/4/25.
//

import UIKit
import SnapKit

final class CompleteViewController: UIViewController {
    
    
    private var reactor: CompleteViewReactor
    
    init(reactor: CompleteViewReactor) {
        self.reactor = reactor
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
