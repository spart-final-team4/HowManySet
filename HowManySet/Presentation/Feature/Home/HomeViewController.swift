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
    
    private let homeText = "홈"
    
    var disposeBag = DisposeBag()
    
    /// HomePagingCardView들을 저장하는 List
    private var pagingCardViewContainer = [HomePagingCardView]()
    /// 페이징 뷰가 들어갈 콘텐트 뷰의 너비 제약조건
    private var contentViewWidthConstraint: Constraint?
    
    private var currentPage = 0
    private var previousPage = 0
    
    // MARK: - UI Components
    private lazy var titleLabel = UILabel().then {
        $0.text = homeText
        $0.font = .systemFont(ofSize: 36, weight: .bold)
    }
    
    private lazy var topTimerHStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 16
        $0.isHidden = true
    }
    
    private lazy var workoutTimeLabel = UILabel().then {
        $0.font = .monospacedDigitSystemFont(ofSize: 36, weight: .bold)
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
    }
    
    private lazy var routineNameLabel = UILabel().then {
        $0.textColor = .textSecondary
        $0.font = .systemFont(ofSize: 14, weight: .semibold)
    }
    
    private lazy var routineNumberLabel = UILabel().then {
        $0.textColor = .textSecondary
        $0.font = .systemFont(ofSize: 14, weight: .semibold)
    }
    
    private lazy var routineStartCardView = HomeRoutineStartCardView().then {
        $0.layer.cornerRadius = 20
    }

    // TODO: UI 나오면 주석 해제 후 수정
//    private lazy var buttonHStackView = UIStackView().then {
//        $0.axis = .horizontal
//        $0.distribution = .equalSpacing
//        $0.alignment = .center
//        $0.isHidden = true
//    }
//    
//    private lazy var stopButton = UIButton().then {
//        $0.layer.cornerRadius = 40
//        $0.backgroundColor = .roundButtonBG
//        $0.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 32), forImageIn: .normal)
//        $0.setImage(UIImage(systemName: "stop.fill"), for: .normal)
//        $0.tintColor = .pauseButton
//    }
//    
//    private lazy var forwardButton = UIButton().then {
//        $0.layer.cornerRadius = 40
//        $0.backgroundColor = .roundButtonBG
//        $0.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 32), forImageIn: .normal)
//        $0.setImage(UIImage(systemName: "forward.end.fill"), for: .normal)
//        $0.tintColor = .white
//    }
    
    // MARK: - 페이징 스크롤 뷰 관련
    private lazy var pagingScrollView = UIScrollView().then {
        $0.showsHorizontalScrollIndicator = false
        $0.isPagingEnabled = true
        $0.isHidden = true
    }
    
    private lazy var pageController = UIPageControl().then {
        $0.currentPage = 0
        $0.numberOfPages = 0
        $0.hidesForSinglePage = true
        $0.isHidden = true
    }
    
    private lazy var pagingScrollContentView = UIView()
    
    
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
        bindUIEvents()
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
            routineStartCardView,
            pagingScrollView,
            pageController,
//            buttonHStackView
        )
        
        topTimerHStackView.addArrangedSubviews(workoutTimeLabel, pauseButton, topRoutineInfoVStackView)
        topRoutineInfoVStackView.addArrangedSubviews(routineNameLabel, routineNumberLabel)
//        buttonHStackView.addArrangedSubviews(stopButton, forwardButton)
        
        pagingScrollView.addSubview(pagingScrollContentView)
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
        
        pagingScrollView.snp.makeConstraints {
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.height.equalToSuperview().multipliedBy(0.47)
            self.contentViewWidthConstraint = $0.width.equalTo(view.snp.width).multipliedBy(1).constraint
        }
        
        pagingScrollContentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalToSuperview()
        }
        
        pageController.snp.makeConstraints {
            $0.top.equalTo(routineStartCardView.snp.bottom).offset(16)
            $0.centerX.equalToSuperview()
        }
        
//        buttonHStackView.snp.makeConstraints {
//            $0.top.equalTo(pageController.snp.bottom).offset(32)
//            $0.horizontalEdges.equalToSuperview().inset(80)
//            $0.centerX.equalToSuperview()
//        }
//        
//        stopButton.snp.makeConstraints {
//            $0.width.height.equalTo(80)
//        }
//        
//        forwardButton.snp.makeConstraints {
//            $0.width.height.equalTo(80)
//        }
    }
    
    /// 운동 시작 시 표현되는 뷰 설정
    func showStartRoutineUI() {
        
        routineStartCardView.isHidden = true
        
        [topTimerHStackView, topRoutineInfoVStackView, pageController, pagingScrollView].forEach {
            $0.isHidden = false
        }
        
        titleLabel.alpha = 0
    }
    
    /// 스크롤 뷰 안의 운동 정보 카드 뷰 레이아웃 설정
    func setPagingCardViewsConstraints(cardView: HomePagingCardView) {
        
        titleLabel.snp.remakeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.bottom.equalTo(pagingScrollView.snp.top).offset(-32)
        }
        
        topTimerHStackView.snp.remakeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.bottom.equalTo(pagingScrollView.snp.top).offset(-32)
        }
        
        topRoutineInfoVStackView.snp.remakeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.bottom.equalTo(pagingScrollView.snp.top).offset(-32)
        }
        
        pageController.snp.remakeConstraints {
            $0.top.equalTo(pagingScrollView.snp.bottom).offset(16)
            $0.centerX.equalToSuperview()
        }
    }
    
    func configureRoutineCardViews(cardStates: [WorkoutCardState]) {
        
        for (i, cardState) in cardStates.enumerated() {
            
            let cardView = HomePagingCardView(frame: .zero, reactor: HomePagingCardViewReactor(initialCardState: cardState)).then {
                $0.layer.cornerRadius = 20
            }
            
            pagingCardViewContainer.append(cardView)
            pagingScrollContentView.addSubview(cardView)
            
            cardView.snp.makeConstraints {
                $0.verticalEdges.equalToSuperview()
                $0.leading.equalToSuperview().offset(CGFloat(i) * UIScreen().bounds.width)
            }
            
            cardView.showExerciseUI()
            
            setPagingCardViewsConstraints(cardView: cardView)
        }
        
        pagingScrollContentView.snp.makeConstraints {
            $0.width.equalTo(UIScreen.main.bounds.width * CGFloat(cardStates.count))
        }
        
        contentViewWidthConstraint?.update(offset: UIScreen().bounds.width * CGFloat(cardStates.count))
        
        print(pagingCardViewContainer.count)
    }
    
    /// 페이징 후 스크롤 이동, 배경 처리, 레이아웃 조정
    func handlePageChanged(to currentPage: Int) {
                
        let offsetX = Int(pagingScrollView.frame.width) * currentPage
        pagingScrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
        
        // 이전 페이지 업데이트
        self.previousPage = currentPage
        // 현재 페이지 업데이트
        self.currentPage = currentPage
        print("currentPage: \(self.currentPage)")
    }
}

// MARK: - Reactor Binding
extension HomeViewController {
    func bind(reactor: HomeViewReactor) {
        
        print(#function)
        
        // MARK: - Action
        // 루틴 시작 버튼 클릭 시
        routineStartCardView.routineSelectButton.rx.tap
            .observe(on: MainScheduler.instance)
            .map { Reactor.Action.routineSelected }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        pauseButton.rx.tap
            .observe(on: MainScheduler.instance)
            .map { Reactor.Action.pauseButtonClicked }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // MARK: - State
        // 운동 시작 시 동작
        reactor.state.map { $0.isWorkingout }
            .distinctUntilChanged()
            .filter { $0 }
            .observe(on: MainScheduler.instance)
            .take(1) // 처음 true 된 시점에만 운동 초기 화면
            .bind(with: self) { view, _ in
                print("--- 운동시작 ---")
                view.showStartRoutineUI()
            }
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.isWorkingout }
            .observe(on: MainScheduler.instance)
            .bind(onNext: { [weak self] isWorkingout in
                guard let self else { return }
                
                if isWorkingout {
                    self.workoutTimeLabel.text = reactor.currentState.workoutTime.toWorkOutTimeLabel()
                }
                
            })
            .disposed(by: disposeBag)
        
        // 텍스트 등 뷰 요소 바인딩
        reactor.state.map { $0.isWorkingout }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind(onNext: { [weak self] isWorkingout in
                guard let self else { return }
                
                // 프로그레스바에 사용될 휴식 시간, 시작시 고정되는 휴식시간, 휴식 중 여부
//                let restSecondsRemaining = reactor.currentState.restSecondsRemaining
//                let restStartTime = reactor.currentState.restStartTime
                
                if isWorkingout {
                    self.routineNameLabel.text = reactor.currentState.workoutRoutine.workouts.first?.name
                    self.routineNumberLabel.text = "\(reactor.currentState.exerciseIndex + 1) / \(reactor.currentState.workoutRoutine.workouts.count)"
                    
                    // 내부 카드 뷰들 세팅
                    self.configureRoutineCardViews(cardStates: reactor.currentState.workoutCardStates)
                }
            })
            .disposed(by: disposeBag)

        // 휴식일때 휴식 프로그레스바 및 휴식시간 설정
        reactor.state.map { $0.isResting }
            .filter { $0 == true }
            .observe(on: MainScheduler.instance)
            .bind(with: self) { view, isResting in
                let pagingCardView = view.pagingCardViewContainer[reactor.currentState.exerciseIndex]
                if isResting {
                    pagingCardView.showRestUI()
                } else {
                    pagingCardView.showExerciseUI()
                    pagingCardView.restProgressBar.setProgress(0, animated: false)
                }
            }.disposed(by: disposeBag)
        
        reactor.state.map { $0.isWorkoutPaused }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind(with: self) { view, isWorkoutPaused in
                let buttonImageName: String = isWorkoutPaused ? "play.fill" : "pause.fill"
                view.pauseButton.setImage(UIImage(systemName: buttonImageName), for: .normal)
            }.disposed(by: disposeBag)
    }
}

// MARK: - Rx Cocoa
private extension HomeViewController {
    
    func bindUIEvents() {
        
        // 스크롤의 감속이 끝났을 때 페이징
        pagingScrollView.rx.didEndDecelerating
            .observe(on: MainScheduler.instance)
            .map { [weak self] _ -> Int in
                guard let self else { return 0 }
                // scrollView 내부 콘텐트가 수평으로 얼마나 스크롤 됐는지 / scrollView가 화면에 차지하는 너비
                let newPage = Int(round(pagingScrollView.contentOffset.x / pagingScrollView.frame.width))
                return newPage
            }
            .do(onNext: { [weak self] newPage in
                guard let self else { return }
                
                // 페이지가 변경 되었을 때만 조정
                if newPage != previousPage {
                    handlePageChanged(to: newPage)
                }
            })
            .bind(to: pageController.rx.currentPage)
            .disposed(by: disposeBag)
        
        
        // 페이징이 되었을 시 동작 (페이지 컨트롤 클릭 시 대응)
        // 기본적으로 페이지 컨트롤 클릭 시 페이지 값이 변경되어 .valueChaned로 구현
        pageController.rx.controlEvent(.valueChanged)
            .observe(on: MainScheduler.instance)
            .map { [weak self] _ -> Int in
                guard let self else { return 0 }
                let currentPage = self.pageController.currentPage
                return currentPage
            }
            .bind(with: self) { view, currentPage in
                view.handlePageChanged(to: currentPage)
            }
            .disposed(by: disposeBag)
    }
}
