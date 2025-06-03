//
//  OnBoardingViewController.swift
//  HowManySet
//
//  Created by 정근호 on 6/3/25.
//

import UIKit
import SnapKit

final class OnBoardingViewController: UIViewController {
    
    private var reactor: OnBoardingViewReactor
    
    init(reactor: OnBoardingViewReactor) {
        self.reactor = reactor
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
