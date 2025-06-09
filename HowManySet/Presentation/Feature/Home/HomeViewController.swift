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
    
    private lazy var topTimerHStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 16
        $0.alpha = 0
    }
    
    private lazy var workoutTimeLabel = UILabel().then {
        $0.text = "00:00"
        $0.font = .systemFont(ofSize: 36, weight: .bold)
    }
    
    private lazy var pauseButton = UIButton().then {
        $0.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 20), forImageIn: .normal)
        $0.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        $0.tintColor = .white
    }
    
    private lazy var topRoutineInfoVStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 8
        $0.alignment = .trailing
        $0.alpha = 0
    }
    
    private lazy var routineNameLabel = UILabel().then {
        $0.text = "등 운동"
        $0.textColor = .textSecondary
        $0.font = .systemFont(ofSize: 14, weight: .semibold)
    }
    
    private lazy var routineNumberLabel = UILabel().then {
        $0.text = "1 / 5"
        $0.textColor = .textSecondary
        $0.font = .systemFont(ofSize: 14, weight: .semibold)
    }
    
    private lazy var routineStartCardView = HomeRoutineStartCardView().then {
        $0.layer.cornerRadius = 20
    }
    
    private lazy var pagingCardView = HomePagingCardView().then {
        $0.layer.cornerRadius = 20
        $0.isUserInteractionEnabled = false
        $0.alpha = 0
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
        $0.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 32), forImageIn: .normal)
        $0.setImage(UIImage(systemName: "stop.fill"), for: .normal)
        $0.tintColor = .pauseButton
    }
    
    private lazy var forwardButton = UIButton().then {
        $0.layer.cornerRadius = 40
        $0.backgroundColor = .roundButtonBG
        $0.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 32), forImageIn: .normal)
        $0.setImage(UIImage(systemName: "forward.end.fill"), for: .normal)
        $0.tintColor = .white
    }
    
    // MARK: - Initializer
    init(reactor: HomeViewReactor, coordinator: HomeCoordinatorProtocol) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
        self.coordinator = coordinator
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print(#function)
        
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
            topTimerHStackView,
            topRoutineInfoVStackView,
            routineStartCardView,
            pageController,
            buttonHStackView,
            pagingCardView
        )
        
        topTimerHStackView.addArrangedSubviews(workoutTimeLabel, pauseButton)
        topRoutineInfoVStackView.addArrangedSubviews(routineNameLabel, routineNumberLabel)
        buttonHStackView.addArrangedSubviews(stopButton, forwardButton)
    }
    
    func setConstraints() {
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.bottom.equalTo(routineStartCardView.snp.top).offset(-32)
        }
        
        topTimerHStackView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.bottom.equalTo(routineStartCardView.snp.top).offset(-32)
        }
        
        topRoutineInfoVStackView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.bottom.equalTo(routineStartCardView.snp.top).offset(-32)
        }
        
        routineStartCardView.snp.makeConstraints {
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.height.equalToSuperview().multipliedBy(0.47)
        }
        
        pagingCardView.snp.makeConstraints {
            $0.edges.equalTo(routineStartCardView)
        }
        
        pageController.snp.makeConstraints {
            $0.top.equalTo(routineStartCardView.snp.bottom).offset(16)
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
                
        routineStartCardView.alpha = 0
        
        pagingCardView.isUserInteractionEnabled = true
        pagingCardView.alpha = 1
        
        [topTimerHStackView, topRoutineInfoVStackView, pageController, buttonHStackView].forEach {
            $0.alpha = 1
        }
        
        titleLabel.alpha = 0
        
    }
}

// MARK: - Rx Methods
extension HomeViewController {
    func bind(reactor: HomeViewReactor) {
        
        print(#function)
        
        // Action
        routineStartCardView.routineSelectButton.rx.tap
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
