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
    
    private lazy var buttonHStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 16
        $0.alignment = .trailing
        $0.isHidden = true
    }
    
    private lazy var stopButton = UIButton().then {
        $0.layer.cornerRadius = 22
        $0.backgroundColor = .roundButtonBG
        $0.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 16), forImageIn: .normal)
        $0.setImage(UIImage(systemName: "stop.fill"), for: .normal)
        $0.tintColor = .pauseButton
    }
    
    private lazy var forwardButton = UIButton().then {
        $0.layer.cornerRadius = 22
        $0.backgroundColor = .roundButtonBG
        $0.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 16), forImageIn: .normal)
        $0.setImage(UIImage(systemName: "forward.end.fill"), for: .normal)
        $0.tintColor = .white
    }
    
    private lazy var routineStartCardView = HomeRoutineStartCardView().then {
        $0.layer.cornerRadius = 20
    }
    
    private lazy var restInfoView = RestInfoView(frame: .zero, homeViewReactor: self.reactor!).then {
        $0.backgroundColor = .cardBackground
        $0.layer.cornerRadius = 20
        $0.isHidden = true
    }
    
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
            buttonHStackView,
            routineStartCardView,
            pagingScrollView,
            pageController,
            restInfoView
        )
        
        topTimerHStackView.addArrangedSubviews(workoutTimeLabel, pauseButton)
        
        buttonHStackView.addArrangedSubviews(stopButton, forwardButton)
        
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
        
        buttonHStackView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.bottom.equalTo(routineStartCardView.snp.top).offset(-32)
        }
        
        stopButton.snp.makeConstraints {
            $0.width.height.equalTo(44)
        }
        
        forwardButton.snp.makeConstraints {
            $0.width.height.equalTo(44)
        }
        
        routineStartCardView.snp.makeConstraints {
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.height.equalToSuperview().multipliedBy(0.45)
        }
        
        pagingScrollView.snp.makeConstraints {
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalToSuperview().multipliedBy(0.45)
        }
        
        pagingScrollContentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalToSuperview()
        }
        
        pageController.snp.makeConstraints {
            $0.top.equalTo(routineStartCardView.snp.bottom).offset(16)
            $0.centerX.equalToSuperview()
        }
        
        restInfoView.snp.makeConstraints {
            $0.top.equalTo(pageController.snp.bottom).offset(16)
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.centerX.equalToSuperview()
            $0.height.equalToSuperview().multipliedBy(0.15)
        }
    }
    
    /// 운동 시작 시 표현되는 뷰 설정
    func showStartRoutineUI() {
        
        routineStartCardView.isHidden = true
        
        [topTimerHStackView, buttonHStackView, pageController, pagingScrollView, restInfoView].forEach {
            $0.isHidden = false
        }
        
        titleLabel.alpha = 0
    }
    
    /// 스크롤 뷰 기준으로 레이아웃 재설정
    func remakeOtherViewsWithScrollView() {
        
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
        
        buttonHStackView.snp.remakeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.bottom.equalTo(pagingScrollView.snp.top).offset(-32)
        }
        
        pageController.snp.remakeConstraints {
            $0.top.equalTo(pagingScrollView.snp.bottom).offset(16)
            $0.centerX.equalToSuperview()
        }
    }
    
    // MARK: -  운동 카드뷰들 생성, 레이아웃 적용, Binding
    func configureRoutineCardViews(cardStates: [WorkoutCardState]) {
        
        // 기존 카드뷰 컨테이너 제거
        pagingCardViewContainer.forEach { $0.removeFromSuperview() }
        pagingCardViewContainer.removeAll()
        
        let screenWidth = UIScreen.main.bounds.width
        let cardInset: CGFloat = 20
        let cardWidth = screenWidth - (cardInset * 2)
        
        for (i, cardState) in cardStates.enumerated() {
            
            let pagingCardViewReactor = HomePagingCardViewReactor(initialCardState: cardState)
            
            guard let reactor = self.reactor else { return }
            pagingCardViewReactor.homeViewAction
                .bind(to: reactor.action)
                .disposed(by: disposeBag)
            
            let cardView = HomePagingCardView(frame: .zero, reactor: pagingCardViewReactor).then {
                $0.layer.cornerRadius = 20
            }
                        
            // 레이아웃 설정
            pagingScrollContentView.addSubview(cardView)
            
            cardView.snp.makeConstraints {
                $0.top.bottom.equalToSuperview()
                $0.width.equalTo(cardWidth)
                $0.leading.equalToSuperview()
                    .offset(cardInset + CGFloat(i) * screenWidth)
            }
                        
            // 뷰 저장하는 리스트에 append
            pagingCardViewContainer.append(cardView)
            
//            // 각 새로 생성된 cardView에 대한 setCompleteButton들 Binding
//            cardView.setCompleteButton.rx.tap
//                .throttle(.milliseconds(1000), scheduler: MainScheduler.instance)
//                .do(onNext: { debugPrint("세트 완료 버튼 클릭") })
//                .observe(on: MainScheduler.instance)
//                .map { Reactor.Action.setCompleteButtonClicked }
//                .bind(to: self.reactor!.action)
//                .disposed(by: disposeBag)
        }
        
        remakeOtherViewsWithScrollView()
        
        if let lastCard = pagingCardViewContainer.last {
            pagingScrollContentView.snp.makeConstraints {
                // 첫 번째에 leading+20을 했으니 여기서 trailing+20 추가
                $0.trailing.equalTo(lastCard.snp.trailing).offset(cardInset)
            }
        }
        
        pageController.numberOfPages = cardStates.count
        
        print(pagingCardViewContainer.count)
        
        handlePageChanged()
    }
    
    // MARK: - Animation
    /// 페이징 시 애니메이션 및 내부 콘텐츠 offset 수정
    func handlePageChanged(currentPage: Int = 0) {
        
        let previousPage = currentPage - 1
        let nextPage = currentPage + 1
        
        let offsetX = Int(UIScreen.main.bounds.width) * currentPage
        
        pagingScrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
        
        // 애니메이션
        if pagingCardViewContainer.indices.contains(currentPage) {
            
            let currentCard = self.pagingCardViewContainer[currentPage]
            
            UIView.animate(withDuration: 0.1) {
                currentCard.transform = .identity
                currentCard.alpha = 1
            }
        }
        
        // 이전/다음 카드: 살짝 축소 + 흐리게
        if previousPage >= 0,
           pagingCardViewContainer.indices.contains(previousPage) {
            
            let previousCard = self.pagingCardViewContainer[previousPage]
            
            UIView.animate(withDuration: 0.1) {
                
                previousCard.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                previousCard.alpha = 0.8
            }
        }
        
        
        if nextPage <= pagingCardViewContainer.count - 1,
           pagingCardViewContainer.indices.contains(nextPage){
            
            let nextCard = self.pagingCardViewContainer[nextPage]
            
            UIView.animate(withDuration: 0.1) {
                
                nextCard.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                nextCard.alpha = 0.8
            }
            
        }
        
        // 이전 페이지 업데이트
        self.previousPage = currentPage
        // 현재 페이지 업데이트
        self.currentPage = currentPage
        print("currentPage: \(self.currentPage)")
        
        print(previousPage, currentPage, nextPage)
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

        forwardButton.rx.tap
            .observe(on: MainScheduler.instance)
            .map { Reactor.Action.forwardButtonClicked }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        
        // MARK: - State
        // 초기 뷰 현재 날짜 표시
        reactor.state.map { $0.isWorkingout }
            .filter { !$0 }
            .observe(on: MainScheduler.instance)
            .bind { [weak self] _ in
                guard let self else { return }
                self.routineStartCardView.todayDateLabel.text = reactor.currentState.date.toDateLabel()
            }.disposed(by: disposeBag)
        
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
        
        // 운동 시간 업데이트
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
            .filter { $0 }
            .observe(on: MainScheduler.instance)
            .bind(onNext: { [weak self] isWorkingout in
                guard let self else { return }
            
                if isWorkingout {
                    // 내부 카드 뷰들 세팅
                    self.configureRoutineCardViews(cardStates: reactor.currentState.workoutCardStates)
                }
            })
            .disposed(by: disposeBag)
        
        // 휴식일때 휴식 프로그레스바 및 휴식시간 설정
        reactor.state.map { $0.isResting }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind(onNext: { [weak self] isResting in
                guard let self else { return }
                self.pagingCardViewContainer.forEach {
                    if isResting,
                       reactor.currentState.restTime != 0,
                       reactor.currentState.restSecondsRemaining != 0 {
                        
                        self.restInfoView.setWaterUI()
                        $0.showRestUI()
                        
                        /// 현재 남은 휴식 시간
                        let restSecondsRemaining = reactor.currentState.restSecondsRemaining
                        /// 프로그레스바 구현에 쓰이는 초기 휴식 시작 시간
                        let restStartTime = reactor.currentState.restStartTime
                        
                        $0.remaingRestTimeLabel.text = Int(restSecondsRemaining).toRestTimeLabel()
                        
                        if let totalTime = restStartTime, totalTime > 0 {
                            let elapsed = Float(totalTime) - Float(restSecondsRemaining)
                            $0.restProgressBar.setProgress(max(min(elapsed / Float(totalTime), 1), 0), animated: true)
                        }
                        
                    } else {
                        self.restInfoView.setRestUI()
                        $0.showExerciseUI()
                        $0.restProgressBar.setProgress(0, animated: false)
                        
                    }
                }
            }).disposed(by: disposeBag)
        
        reactor.state.map { $0.isWorkoutPaused }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind(with: self) { view, isWorkoutPaused in
                let buttonImageName: String = isWorkoutPaused ? "play.fill" : "pause.fill"
                view.pauseButton.setImage(UIImage(systemName: buttonImageName), for: .normal)
            }.disposed(by: disposeBag)
        
        reactor.state.map { $0.currentExerciseCompleted }
            .distinctUntilChanged()
            .filter { $0 }
            .observe(on: MainScheduler.instance)
            .bind { [weak self] _ in
                guard let self else { return }
                self.pagingCardViewContainer.remove(at: reactor.currentState.exerciseIndex)
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
                    self.handlePageChanged(currentPage: newPage)
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
            .bind(onNext: { [weak self] currentPage in
                guard let self else { return }
                self.handlePageChanged(currentPage: currentPage)
            })
            .disposed(by: disposeBag)
    }
}
