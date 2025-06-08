//
//  MainViewController.swift
//  HowManySet
//
//  Created by 정근호 on 5/30/25.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa
import ReactorKit

final class HomeViewController: UIViewController, View {
    
    // MARK: - Properties
    private weak var coordinator: HomeCoordinatorProtocol?
        
    var disposeBag = DisposeBag()
    
    // MARK: - UI Components
    private lazy var titleLabel = UILabel().then {
        $0.text = "홈"
        $0.font = .systemFont(ofSize: 36, weight: .bold)
    }
    
    private lazy var routineStartView = HomeRoutineStartView().then {
        $0.layer.cornerRadius = 20
    }
    
    private lazy var pageController = UIPageControl().then {
        $0.currentPage = 0
        $0.numberOfPages = 5
        $0.hidesForSinglePage = true
        $0.alpha = 0
    }
    
    private lazy var buttonHStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .equalSpacing
        $0.alignment = .center
        $0.alpha = 0
    }
    
    private lazy var stopButton = UIButton().then {
        $0.layer.cornerRadius = 40
        $0.backgroundColor = .roundButtonBG
        $0.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 24), forImageIn: .normal)
        $0.setImage(UIImage(systemName: "stop.fill"), for: .normal)
        $0.tintColor = .white
    }
    
    private lazy var forwardButton = UIButton().then {
        $0.layer.cornerRadius = 40
        $0.backgroundColor = .roundButtonBG
        $0.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 24), forImageIn: .normal)
        $0.setImage(UIImage(systemName: "forward.fill"), for: .normal)
        $0.tintColor = .brand
    }
    
    // MARK: - Initializer
    init(reactor: HomeViewReactor, coordinator: HomeCoordinatorProtocol) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print(#function)
        
        if let reactor = reactor {
            bind(reactor: reactor)
        }
        
        setupUI()
    }
}

// MARK: - UI Methods
private extension HomeViewController {
    func setupUI() {
        setViewHiearchy()
        setConstraints()
    }
    
    func setViewHiearchy() {
        view.addSubviews(
            titleLabel,
            routineStartView,
            pageController,
            buttonHStackView
        )
        
        buttonHStackView.addArrangedSubviews(stopButton, forwardButton)
    }
    
    func setConstraints() {
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.bottom.equalTo(routineStartView.snp.top).offset(-32)
        }
        
        routineStartView.snp.makeConstraints {
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.height.equalToSuperview().multipliedBy(0.47)
        }
        
        pageController.snp.makeConstraints {
            $0.top.equalTo(routineStartView.snp.bottom).offset(16)
            $0.centerX.equalToSuperview()
        }
        
        buttonHStackView.snp.makeConstraints {
            $0.top.equalTo(pageController.snp.bottom).offset(32)
            $0.horizontalEdges.equalToSuperview().inset(80)
            $0.centerX.equalToSuperview()
        }
        
        stopButton.snp.makeConstraints {
            $0.width.height.equalTo(80)
        }
        
        forwardButton.snp.makeConstraints {
            $0.width.height.equalTo(80)
        }
    }
    
    func setStartRoutineUI() {
        [pageController, buttonHStackView].forEach {
            $0.alpha = 1
        }
        
        titleLabel.alpha = 0
        
        routineStartView.setStartRoutineUI()
    }
}

// MARK: - Rx Methods
extension HomeViewController {
    func bind(reactor: HomeViewReactor) {
        
        print(#function)
        
        // Action
        routineStartView.routineSelectButton.rx.tap
            .map { Reactor.Action.routineSelected }
            .bind(with: self, onNext: { view, _ in
                reactor.action.onNext(.routineSelected)
            })
            .disposed(by: disposeBag)
                
        stopButton.rx.tap
            .bind(with: self) { _,_ in
                
            }.disposed(by: disposeBag)
        
        forwardButton.rx.tap
            .bind(with: self) { _,_ in
                
            }.disposed(by: disposeBag)
        
        // State
        reactor.state.map { $0.isWorkingout }
            .bind(with: self) { view, isWorking in
                if isWorking {
                    view.setStartRoutineUI()
                }
            }
            .disposed(by: disposeBag)

    }
}
