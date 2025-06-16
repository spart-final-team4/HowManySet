//
//  OnBoardingViewController.swift
//  HowManySet
//
//  Created by GO on 6/3/25.
//

import UIKit
import ReactorKit
import RxSwift
import RxCocoa

final class OnBoardingViewController: UIViewController {
    
    // MARK: - Properties
    
    private weak var coordinator: OnBoardingCoordinatorProtocol?
    
    private var reactor: OnBoardingViewReactor
    
    private let onboardingView = OnboardingView()
    
    private let nicknameInputView = NicknameInputView()
    
    init(reactor: OnBoardingViewReactor, coordinator: OnBoardingCoordinatorProtocol) {
        self.reactor = reactor
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
