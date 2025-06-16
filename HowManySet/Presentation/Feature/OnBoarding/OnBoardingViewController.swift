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
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        /// 각 UIView 초기 상태
        onboardingView.isHidden = false
        nicknameInputView.isHidden = true
    }
}

private extension OnBoardingViewController {
    func setupUI() {
        setAppearance()
        setActions()
        setDelegates()
        setViewHierarchy()
        setConstraints()
    }
    
    func setAppearance() {
        view.backgroundColor = UIColor(named: "Background")
    }
    
    func setActions() {
        nicknameInputView.nextButton.addTarget(self, action: #selector(nicknameInputViewNextButtonAction), for: .touchUpInside)
    }
    
    func setDelegates() {
        // TODO: NicknameInputView.textField.delegate = self
    }
    
    func setViewHierarchy() {
        view.addSubviews(nicknameInputView, onboardingView)
    }
    
    func setConstraints() {
        onboardingView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        nicknameInputView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
}
